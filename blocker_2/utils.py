import subprocess
import pwd
import os
import re
import json
from datetime import datetime
import shlex # a Python standard library module for safely splitting and quoting command-line strings.
import platform
import psutil
import getpass
from typing import TypedDict
from datetime import date, datetime

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))

USAGE_FILE = os.path.join(SCRIPT_DIR, "usage_file.json")

def get_logged_in_users():
    """
    Returns a list of usernames currently logged in (systemd-logind).
    """
    try:
        os_name = platform.system()
        if "Windows" in os_name:
            return [getpass.getuser()]
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
    os_name = platform.system()
    for user in get_logged_in_users():
        try:
            if "Windows" in os_name:
                home = os.path.expanduser("~")
            else:
                home = pwd.getpwnam(user).pw_dir
            log_file = os.path.join(home, "notify.log")
            with open(log_file, "a") as f:
                f.write(message + "\n")

        except Exception as e:
            print(f"Failed to write log for {user}: {e}")

def shutdown_all():
    if not is_ntp_synced():
        return

    os_name = platform.system()

    try:
        if "Windows" in os_name:
            subprocess.run(["shutdown", "/s", "/t", "0"], check=True)

        else:
            notify(f"Default Linux shutdown for : {os_name}")
            subprocess.run(["systemctl", "poweroff", "-i"], check=True)
    except Exception as e:
        notify(f"Failed shutdown_all: {e}")

def suspend_all():
    if not is_ntp_synced():
        return

    os_name = platform.system()

    try:
        if "Windows" in os_name:
            # Windows のサスペンドは subprocess で動かないことがあるので psutil を使用
            psutil.suspend()
        else:
            notify(f"Default suspend for: {os_name}")
            subprocess.run(["systemctl", "suspend"], check=True)

    except Exception as e:
        notify(f"Suspend failed: {e}")

           

def cancel_shutdown():
    try:
        os_name = platform.system()
        if os_name == "Windows":
            # /a = abort shutdown
            subprocess.run(["shutdown", "/a"], check=False)
        else:
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
        os_name = platform.system()
        if "Windows" in os_name:
            # Delete all
            subprocess.run(["icacls", USAGE_FILE, "/inheritance:r"], check=False)
            subprocess.run(["icacls", USAGE_FILE, "/remove:g", "Users"], check=False)

            # Administrator + SYSTEM: F
            subprocess.run(["icacls", USAGE_FILE, "/grant:r", "Administrator:(F)"], check=False)
            subprocess.run(["icacls", USAGE_FILE, "/grant:r", "SYSTEM:(F)"], check=False)
            return
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
    except Exception as e:
        notify(f"Unknown error happened at read_usage_file(): {e}")
        return {"date": None, "seconds": 0}


def is_ntp_synced() -> bool:
    # timedatectl show --property=NTPSynchronized --value
    # date
    try:
        os_name = platform.system()
        if "Windows" in os_name:
            out = subprocess.check_output(
                ["w32tm", "/query", "/status"],
                text=True,
                stderr=subprocess.DEVNULL  # ノイズを避ける
            ).lower()
            for line in out.splitlines():
                if "stratum" in line:
                    try:
                        notify("stratum is found.")
                        value = int(line.split(":")[1].strip())
                        notify(f"Info: value ={value}")
                        return value < 16
                    except Exception as e:
                        notify(f"Unknown error happened at is_ntp_synced(): {e}")
                        return False
            return False
        else:
            out = subprocess.check_output(
                ["timedatectl", "show", "--property=NTPSynchronized", "--value"],
                text=True
            ).strip()
            return "y" in out.lower()
    except Exception as e:
        notify(f"Error at is_ntp_synced{e}")
        return False

