import time
import subprocess
import json
import os
from datetime import datetime
from gi.repository import Notify

USAGE_FILE = "/var/log/shutdown_app_usage.json"
DAILY_LIMIT_SEC = 300 * 60  # 1日の制限時間（秒）

# 通知の初期化
Notify.init("ShutdownApp")

def notify(summary, body):
    n = Notify.Notification.new(summary, body)
    n.show()

# 時間情報を管理するクラス
class UsageManager:
    def __init__(self):
        self._ensure_file()

    def _ensure_file(self):
        if not os.path.exists(USAGE_FILE):
            self._save({"date": self._today(), "seconds": 0})

    def _today(self):
        return datetime.now().strftime("%Y-%m-%d")

    def _load(self):
        with open(USAGE_FILE, "r") as f:
            return json.load(f)

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

# Pomodoro処理本体（1秒単位で制御）
def start_combined_loop():
    usage = UsageManager()
    notified_2min = False
    phase = "focus"
    counter = 0

    while True:
        if usage.seconds_left() <= 120 and not notified_2min:
            notify("警告", "残り2分です。作業を保存してください")
            notified_2min = True

        if usage.is_limit_exceeded():
            try:
                subprocess.run(["systemctl", "poweroff", "--ignore-inhibitors", "-i"], check=True)
            except Exception as e:
                notify("シャットダウン失敗", str(e))
            break

        if phase == "focus":
            if counter == 0:
                notify("集中時間", "50分作業開始")
            counter += 1
            if counter >= 50 * 60:
                phase = "break"
                counter = 0

        elif phase == "break":
            if counter == 0:
                notify("休憩時間", "20分休憩開始")
                try:
                    subprocess.run(["systemctl", "suspend", "--ignore-inhibitors"], check=True)
                except Exception as e:
                    notify("サスペンド失敗", str(e))
            counter += 1
            if counter >= 20 * 60:
                phase = "focus"
                counter = 0

        usage.add_second()
        time.sleep(1)
