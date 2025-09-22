import subprocess
import pwd
import os
import re
import json
from datetime import datetime
import shlex # a Python standard library module for safely splitting and quoting command-line strings.
import platform
from typing import TypedDict
from datetime import date, datetime


USAGE_FILE = "/opt/shutdown_cui/usage_file.json"

def get_logged_in_users():
    """
    Returns a list of usernames currently logged in (systemd-logind).
    """
    try:
        out = subprocess.check_output(
            ["loginctl", "list-users", "--no-legend"],
            text=True
        ).strip().splitlines()

        users = []
        for line in out:
            parts = line.split()
            if len(parts) >= 2:
                users.append(parts[1])  # username
        return users
    except subprocess.CalledProcessError:
        return []

def notify(content):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    message = f"[{timestamp}] {content}"

    print(message, flush=True)  

    for user in get_logged_in_users():
        try:
            home = pwd.getpwnam(user).pw_dir
            log_file = os.path.join(home, "notify.log")
            with open(log_file, "a") as f:
                f.write(message + "\n")
            os.chmod(log_file, 0o744)

        except KeyError:
            print(f"[ERROR] User {user} not found in passwd database")
        except Exception as e:
            print(f"[ERROR] Failed to write log for {user}: {e}")

def shutdown_all():
    if is_ntp_synced():
        try:
            subprocess.run(["systemctl", "poweroff", "-i"], check=True)# --force --force
        except Exception as e:
            notify(f"Failed shutdown_all: {e}")

def suspend_all():
    if is_ntp_synced():
        try:
            subprocess.run(["systemctl", "suspend", "-i"], check=True)
        except subprocess.CalledProcessError:
            notify("Suspend failed, falling back to kill_sway.")
            kill_sway()

def cancel_shutdown():
    try:
        subprocess.run(["shutdown", "-c"], check=False) # check = False(Ignore command failule message)
        notify("Pending shutdowns cancelled.")
    except Exception as e:
        notify(f"Failed to cancel shutdown: {e}")


def protect_usage_file(today: date | datetime) -> None:
    try:
        if not os.path.exists(USAGE_FILE):
            os.makedirs(os.path.dirname(USAGE_FILE), exist_ok=True)
            with open(USAGE_FILE, "w") as f:
                json.dump({"date": today.isoformat(), "seconds": 0}, f)
        subprocess.run(["chown", "root:root", USAGE_FILE])
        subprocess.run(["chmod", "600", USAGE_FILE])
    except Exception as e:
        notify(f"Failed protect_usage_file: {e}")

class UsageData(TypedDict):
    date: str
    seconds: int

def update_usage_file(update_data: UsageData) -> None:
    try: 
        with open(USAGE_FILE, "w") as f:
            json.dump(update_data, f)
    except Exception as e:
        notify(f"Failed update_usage_file.: {e}")

def read_usage_file():
    try:
        with open(USAGE_FILE) as f:
            return json.load(f)
    except (FileNotFoundError, json.JSONDecodeError):
        notify("Unknown error happened ad read_usage_file()")
        return {"date": None, "seconds": 0}


def is_ntp_synced() -> bool:
    # timedatectl show --property=NTPSynchronized --value
    # date
    try:
        out = subprocess.check_output(
            ["timedatectl", "show", "--property=NTPSynchronized", "--value"],
            text=True
        ).strip()
        return "y" in out.lower()
    except Exception as e:
        notify(f"Error at is_ntp_synced{e}")
        return False

def kill_sway():
    try:
        result = subprocess.run(
            ["pgrep", "sway"],
            stdout=subprocess.PIPE,
            stderr=subprocess.DEVNULL,
            text=True
        )
        if result.returncode == 0:
            subprocess.run(["pkill", "-9", "sway"])
            notify("sway is killed")
    except Exception as e:
        notify(f"Error: {e}")


def get_interface_state(interface="eth0"):
    """
    ip link show の 'state' 部分を見て up / down を返す
    """
    try:
        result = subprocess.run(
            ["ip", "link", "show", interface],
            capture_output=True, text=True, check=True
        )
        output = result.stdout

        # "state UP" or "state DOWN" を抜き出す
        match = re.search(r"state (\w+)", output)
        if match:
            state = match.group(1).lower()
            if state == "up":
                return "up"
            elif state == "down":
                return "down"
            else:
                return state  # UNKNOWN, DORMANT など他の可能性
        else:
            return None
    except subprocess.CalledProcessError:
        return None

def block_eth(interface="eth0"):
    try:
        subprocess.run(["sudo", "ip", "link", "set", interface, "down"], check=True)
        print(f"{interface} has been blocked (down).")
    except subprocess.CalledProcessError as e:
        print(f"Error: {e}")


def unblock_eth(interface="eth0"):
    try:
        subprocess.run(["sudo", "ip", "link", "set", interface, "up"], check=True)
        print(f"{interface} has been unblocked (up).")
    except subprocess.CalledProcessError as e:
        print(f"Error: {e}")

def toggle_eth(do_up, interface="eth0"):
    state = get_interface_state(interface)

    if do_up is True:
        # 強制で up
        if state != "up":
            print(f"{interface} → unblocking (up)...")
            unblock_eth(interface)
        else:
            print(f"{interface} is already UP.")
    elif do_up is False:
        # 強制で down
        if state != "down":
            print(f"{interface} → blocking (down)...")
            block_eth(interface)
        else:
            print(f"{interface} is already DOWN.")



