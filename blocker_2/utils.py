import subprocess
import pwd
import os
import json
from datetime import datetime
import shlex # a Python standard library module for safely splitting and quoting command-line strings.





# Get home dir for ADMIN_USERNAME
USAGE_FILE = "/root/shutdown_cui/usage_file.json"  # root専用ディレクトリに保存


def get_env_for_user(user, var):
    try:
        # ユーザーのGUIセッションのPIDを探す
        pid = subprocess.check_output(
            ["pgrep", "-u", user, "gnome-session"], text=True
        ).splitlines()[0]
    except subprocess.CalledProcessError:
        # GNOME以外のセッションなら fallback
        try:
            pid = subprocess.check_output(
                ["pgrep", "-u", user, "startplasma-x11"], text=True
            ).splitlines()[0]
        except subprocess.CalledProcessError:
            return None  # 見つからなければ None

    # /proc/<pid>/environ から環境変数を読む
    try:
        with open(f"/proc/{pid}/environ", "rb") as f:
            env_data = f.read().decode().split("\0")
        for item in env_data:
            if item.startswith(f"{var}="):
                return item.split("=", 1)[1]
    except Exception:
        return None

    return None



def get_active_user():
    """
    Detect the user of the currently active session.
    Works with systemd-logind (loginctl).
    Returns: username (str) or None
    """
    try:
        # 1. Get the active session ID on seat0 (the main local seat)
        session_id = subprocess.check_output(
            ["loginctl", "show-seat", "seat0", "--property=ActiveSession", "--value"],
            text=True
        ).strip()

        if not session_id:
            return None

        # 2. Get the username for that session
        username = subprocess.check_output(
            ["loginctl", "show-session", session_id, "--property=Name", "--value"],
            text=True
        ).strip()

        return username if username else None

    except subprocess.CalledProcessError:
        return None
def notify(content):
    timestamp = datetime.now().strftime("%H:%M:%S")
    print(f"[{timestamp}]: 🔔 {content}\n")

    try:
        user = get_active_user()
        if not user:
            print(f"[{timestamp}] [ERROR] Active user detection failed")
            return

        display = get_env_for_user(user, "DISPLAY")
        dbus_addr = get_env_for_user(user, "DBUS_SESSION_BUS_ADDRESS")

        if not display or not dbus_addr:
            print(f"[{timestamp}] [ERROR] Could not get DISPLAY/DBUS for {user}")
            return

        # Send notification using the detected environment
        subprocess.run(
            ["sudo", "-u", user, "env",
             f"DISPLAY={display}",
             f"DBUS_SESSION_BUS_ADDRESS={dbus_addr}",
             "notify-send", content],
            check=True
        )

    except Exception as e:
        print(f"[{timestamp}] [ERROR] notify-send失敗: {e}")




def disconnect_wifi():
    try:
        # Use nmcli to disconnect Wi-Fi
        subprocess.run(
            ["nmcli", "radio", "wifi", "off"],
            check=True
        )
        print("Wi-Fi disconnected.")
    except subprocess.CalledProcessError as e:
        print(f"Failed to disconnect Wi-Fi: {e}")

def run_as_admin(command):
    return subprocess.run(command, shell=True).returncode == 0

def run_as_admin_output(command):
    return subprocess.check_output(command, shell=True, text=True)


def shutdown_all_as_admin():
    # Force shutdown, ignore inhibitors
    return run_as_admin("systemctl poweroff -i --force --force")

def suspend_all_as_admin():
    # Force suspend, ignore inhibitors
    return run_as_admin("systemctl suspend -i")

def run_as_admin(command):
    """rootとしてコマンド実行"""
    return subprocess.run(command, shell=True).returncode == 0


def protect_usage_file(today):
    if not os.path.exists(USAGE_FILE):
        os.makedirs(os.path.dirname(USAGE_FILE), exist_ok=True)
        with open(USAGE_FILE, "w") as f:
            json.dump({"date": today, "seconds": 0}, f)
    run_as_admin(f"chown root:root {USAGE_FILE}")
    run_as_admin(f"chmod 600 {USAGE_FILE}")

def update_usage_file(update_data):
    with open(USAGE_FILE, "w") as f:
        json.dump(update_data, f)


def read_usage_file():
    content = run_as_admin_output(f"cat {USAGE_FILE}")
    return json.loads(content)
