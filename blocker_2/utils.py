import subprocess
import os
import re
import json
from datetime import datetime
import time
import shlex # a Python standard library module for safely splitting and quoting command-line strings.
import platform
import getpass
import sys
from typing import TypedDict
from datetime import date, datetime

def get_base_dir():
    if getattr(sys, 'frozen', False):
        return os.path.dirname(os.path.dirname(sys.executable))
    else:
        return os.path.dirname(os.path.abspath(__file__))

SCRIPT_DIR = get_base_dir()
USAGE_FILE = os.path.join(SCRIPT_DIR, "usage_file.json")

LOG_FILE = os.path.join(os.path.expanduser("~"), "notify.log")

if platform.system() != "Windows":
    import pwd

def notify(content):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    message = f"[{timestamp}] {content}"

    print(message, flush=True)

    try:
        with open(LOG_FILE, "a") as f:
            f.write(message + "\n")
    except Exception as e:
        print(f"Failed to write log: {e}")

def shutdown_all():
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
    os_name = platform.system()
    try:
        if "Windows" in os_name:
            # 現在のセッションを取得
            result = subprocess.run(
                ["query", "session"], capture_output=True, text=True
            )
            sessions = result.stdout.strip().splitlines()

            # 自分のセッションIDを特定
            current_session_id = None
            for line in sessions[1:]:  # 1行目はヘッダ
                parts = line.split()
                if "Active" in parts:
                    current_session_id = parts[2]  # セッションIDは3列目
                    break

            if current_session_id:
                subprocess.run(["logoff", current_session_id], check=True)
            else:
                notify("No active session found to log off.")

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
    try:
        os_name = platform.system()
        if "Windows" in os_name:
            try:
                # Check service status
                status_result = subprocess.run(
                    ["sc", "query", "w32time"],
                    capture_output=True, text=True, check=False
                )

                # If service is not running, start it
                if "Stratum" not in status_result.stdout:
                    notify("Windows Time service is not running. Starting it...")
                    subprocess.run(
                        ["powershell", "-Command", "Start-Service w32time"],
                        check=False
                    )
                    time.sleep(3)  # Give it time to start

                    # Force a resync after starting
                    subprocess.run(["w32tm", "/resync", "/force"], check=False)
                    time.sleep(2)

            except Exception as e:
                notify(f"Error starting w32time service: {e}")
                return False

            # Now query the status
            result = subprocess.run(
                ["w32tm", "/query", "/status"],
                capture_output=True, text=True, check=False  # Use check=False
            )
            out = result.stdout
            for line in out.splitlines():
                if "Stratum" in line:
                    try:
                        notify("stratum is found.")
                        value_str = line.split(":")[1].strip().split()[0]  # remove :0(unspecified)
                        value = int(value_str)
                        notify(f"Info: value = {value}")
                        if value <= 0 or value >= 16:
                            subprocess.run(["w32tm", "/resync", "/force"], check=False)
                            return False
                        else:
                            return 0 < value < 16
                    except Exception as e:
                        notify(f"Unknown error happened at is_ntp_synced(): {e}")
                        return False
            notify("is_ntp_synced returns False.")
            return False
        else:
            out = subprocess.check_output(
                ["timedatectl", "show", "--property=NTPSynchronized", "--value"],
                text=True
            ).strip()
            return "y" in out.lower()
    except Exception as e:
        notify(f"Error at is_ntp_synced: {e}")
        return False

