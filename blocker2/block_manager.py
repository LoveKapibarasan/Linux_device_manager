import time
import subprocess
import json
import os
import pwd
from datetime import datetime
from datetime import time as dtime

USAGE_FILE = os.path.expanduser("~/.shutdown_app_usage.json")

# === Pomodoro/Blocker Timing Settings  ===

# === Time Unit Constants ===
SECOND = 1
MINUTE = 60 * SECOND
HOUR = 60 * MINUTE

# === Pomodoro/Blocker Timing Settings  ===

DAILY_LIMIT_HOURS = 9
DAILY_LIMIT_SEC = DAILY_LIMIT_HOURS * HOUR
WARN_MIN = 2
WARN_SEC = WARN_MIN * MINUTE

# NIGHT BLOCKING TIME (Forced Block)
BLOCK_DURATION_START = dtime(20, 0)  # 20:00
BLOCK_DURATION_END = dtime(7, 0)    # 07:00

def get_active_user():
    try:
        # Get the active user from loginctl
        user = subprocess.check_output(
            ["loginctl", "show-user", "--property=Name", 
             subprocess.check_output(["loginctl", "list-users", "--no-legend"])
             .decode().split()[0]]
        ).decode().strip().split("=")[1]
        return user
    except Exception:
        return None

def notify(summary, body):
    timestamp = datetime.now().strftime("%H:%M:%S")
    print(f"\n[{timestamp}] 🔔 {summary}: {body}")
    # temporary switch to get active user
    try:
        user = get_active_user()
        if not user:
            print(f"[{timestamp}] [ERROR] Active user detection failed")
            return
        uid = pwd.getpwnam(user).pw_uid
        subprocess.run([
            "su", "-", user, "-c",
            f"DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/{uid}/bus "
            f"notify-send --urgency=critical --expire-time=5000 '{summary}' '{body}'"
        ], check=False)

    except Exception as e:
        print(f"[{timestamp}] [ERROR] notify-send失敗: {e}")


# 時間情報を管理するクラス
class UsageManager:
    def __init__(self):
        if not os.path.exists(USAGE_FILE):
            with open(USAGE_FILE, "w") as f:
                json.dump({"date": self._today(), "seconds": 0}, f)

    def _today(self):
        return datetime.now().strftime("%Y-%m-%d")

    def _load(self):
        try:
            with open(USAGE_FILE, "r") as f:
                data = json.load(f)
            if "date" not in data:
                data["date"] = self._today()
                data["seconds"] = data.get("seconds", 0)
                self._save(data)
            return data
        except (json.JSONDecodeError, FileNotFoundError):
            data = {"date": self._today(), "seconds": 0}
            self._save(data)
            return data

    def _save(self, data):
        with open(USAGE_FILE, "w") as f:
            json.dump(data, f)

    def add_second(self):
        data = self._load()
        if data["date"] != self._today():
            data = {"date": self._today(), "seconds": 0}
        data["seconds"] = data.get("seconds", 0) + 1
        self._save(data)

    def seconds_left(self):
        data = self._load()
        if data["date"] != self._today():
            return DAILY_LIMIT_SEC
        return max(0, DAILY_LIMIT_SEC - data.get("seconds", 0))

    def is_limit_exceeded(self):
        return self.seconds_left() <= 0


# 固定時間制ポモドーロ: 毎時00~50分のみ使用可、55~00分はブロック
def is_pomodoro_block_time():
    now = datetime.now()
    minute = now.minute
    # 55分～59分と00分はブロック
    return (minute >= 55 or minute < 1)

def is_block_time():
    now = datetime.now().time()
    if BLOCK_DURATION_START < BLOCK_DURATION_END:
        return BLOCK_DURATION_START <= now < BLOCK_DURATION_END
    else:
        return now >= BLOCK_DURATION_START or now < BLOCK_DURATION_END

def start_combined_loop():
    usage = UsageManager()
    notified_block = False
    notify("🔒 システム監視開始", "デバイス使用制限が有効になりました（固定時間制）")
    while True:
        try:
            # 夜間強制ブロック
            if is_block_time():
                notify("⏰ 強制ブロック時間", f"現在は{BLOCK_DURATION_START.strftime('%H:%M')}~{BLOCK_DURATION_END.strftime('%H:%M')}の間です。シャットダウンします。")
                shutdown_success = False
                error_msgs = []
                try:
                    subprocess.run(["systemctl", "poweroff", "--ignore-inhibitors", "-i"], check=True)
                    shutdown_success = True
                except Exception as e:
                    error_msgs.append(f"systemctl poweroff失敗: {str(e)}")
                if not shutdown_success:
                    try:
                        subprocess.run(["shutdown", "-h", "now"], check=True)
                        shutdown_success = True
                    except Exception as e2:
                        error_msgs.append(f"shutdown -h now失敗: {str(e2)}")
                if not shutdown_success:
                    notify("❌ シャットダウン失敗", "エラー: " + "; ".join(error_msgs))
                break

            # 固定時間制ポモドーロブロック
            if is_pomodoro_block_time():
                if not notified_block:
                    notify("⏰ ポモドーロブロック", "毎時55分～00分は使用禁止です。サスペンドします。")
                    notified_block = True
                try:
                    subprocess.run(["systemctl", "suspend"], check=True)
                except Exception as e:
                    notify("❌ サスペンド失敗", f"エラー: {str(e)}")
                break
            else:
                notified_block = False

            usage.add_second()

            time.sleep(1)

        except KeyboardInterrupt:
            notify("🚫 KeyboardInterrupt検出", "保護モードのため終了を拒否しました")
            continue
        except Exception as e:
            notify("⚠️ エラー発生", f"処理を継続します: {str(e)}")
            time.sleep(1)
            continue
