import time
import json
import subprocess
from datetime import datetime
from datetime import time as dtime
from utils import notify, shutdown_all_as_admin,suspend_all_as_admin, protect_usage_file, read_usage_file, update_usage_file

# === Pomodoro/Blocker Timing Settings  ===

# === Time Unit Constants ===
SECOND = 1
MINUTE = 60 * SECOND
HOUR = 60 * MINUTE


CONFIG = {
    "weekday": {
        "DAILY_LIMIT_HOURS": 9,
        "WARN_MIN": 2,
        "POMODORO_START": 55,           # xx:50 ~ xx:00 is block
        "BLOCK_START": dtime(20, 0),    # 20:00
        "BLOCK_END": dtime(7, 0),       # 07:00
    },
    "weekend": {
        "DAILY_LIMIT_HOURS": 4,         # <-- change if you want different on Sat/Sun
        "WARN_MIN": 2,
        "POMODORO_START": 50,
        "BLOCK_START": dtime(20, 0),
        "BLOCK_END": dtime(7, 0),
    },
}

def _profile_for(now: datetime | None = None) -> str:
    now = now or datetime.now()
    # Monday=0 ... Sunday=6; weekend is 5,6
    return "weekend" if now.weekday() >= 5 else "weekday"

def _cfg(now: datetime | None = None) -> dict:
    return CONFIG[_profile_for(now)]

def daily_limit_sec(now: datetime | None = None) -> int:
    return _cfg(now)["DAILY_LIMIT_HOURS"] * HOUR

def warn_sec(now: datetime | None = None) -> int:
    return _cfg(now)["WARN_MIN"] * MINUTE

def pomodoro_start_minute(now: datetime | None = None) -> int:
    return _cfg(now)["POMODORO_START"]

def block_window(now: datetime | None = None) -> tuple[dtime, dtime]:
    c = _cfg(now)
    return c["BLOCK_START"], c["BLOCK_END"]

# 時間情報を管理するクラス
class UsageManager:
    def __init__(self):
        protect_usage_file(self._today())

    def _today(self):
        return datetime.now().strftime("%Y-%m-%d")

    def _load(self):
        try:
            data = read_usage_file() 
            if "date" not in data:
                data["date"] = self._today()
                data["seconds"] = data.get("seconds", 0)
                self._save(data)
            return data
        except Exception as e:
            notify(f"Because of an error, usage file is reset: {str(e)}")
            data = {"date": self._today(), "seconds": 0}
            self._save(data)
            return data


    def _save(self, data):
        update_usage_file(data)

    def add_second(self):
        data = self._load()
        if data["date"] != self._today():
            data = {"date": self._today(), "seconds": 0}
        data["seconds"] = data.get("seconds", 0) + 1
        self._save(data)

    # Check if the usage limit is exceeded
    def is_limit_exceeded(self):
        data = self._load()
        if data["date"] != self._today():
            protect_usage_file(self._today())
            return False
        return max(0, daily_limit_sec() - data.get("seconds", 0)) <= 0

    def notify_remaining_time(self):
        data = self._load()
        if data["date"] != self._today():
            notify("Usage file is reset, no data available.")
            return daily_limit_sec()
        remaining = max(0, daily_limit_sec() - data.get("seconds", 0))
        if remaining <= warn_sec():
            notify(f"⚠️残り時間: {remaining // MINUTE}分")
        return remaining



# Pomodoro like block
def is_pomodoro_block_time():
    now_minute = datetime.now().minute
    return now_minute >= pomodoro_start_minute()

# Check if the current time is within the blocking duration
def is_block_time():
    now = datetime.now().time()
    start, end = block_window()
    if start < end:
        return start <= now < end
    else:
        return now >= start or now < end

def is_notified():
    current_minute = datetime.now().minute
    current_second = datetime.now().second
    return current_minute % 5 == 0 and current_second in (0, 1)

def start_combined_loop():
    usage = UsageManager()
    while True:
        try:
            # Night blocking time check
            if is_block_time() or usage.is_limit_exceeded():
                bs, be = block_window()
                if is_notified():
                    notify(f"Now in {bs.strftime('%H:%M')}~{be.strftime('%H:%M')}")
                try:
                    shutdown_all_as_admin()
                except Exception as e:
                    notify(f"❌Shutdown failed {str(e)}")
                time.sleep(1)
                return

            # Pomodoro block time check
            if is_pomodoro_block_time():
                if is_notified():
                    notify("⏰Pomodoro block time detected, blocking now")
                try:
                    suspend_all_as_admin()
                except Exception as e:
                    notify(f"❌Suspend failed {str(e)}")
                time.sleep(1)
                return

            usage.add_second()

            if is_notified():
                usage.notify_remaining_time()
            time.sleep(1)
        except Exception as e:
            notify(f"⚠️Error happens: {str(e)}")
            time.sleep(1)
            continue
