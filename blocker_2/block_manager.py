import time
import json
import subprocess
import os
from datetime import datetime
from datetime import time as dtime
from utils import notify, shutdown_all, suspend_all,  protect_usage_file, read_usage_file, update_usage_file, is_ntp_synced, get_base_dir

# === Time Unit Constants ===
UNIT = 60

def load_config(path="config.json"):
    base_dir = get_base_dir()
    full_path = os.path.join(base_dir, path)
    notify(f"Config file is read from {full_path}")
    with open(full_path, "r", encoding="utf-8") as f:
        config = json.load(f)
    # "HH:MM" → datetime.time
    for key in ["weekday", "weekend"]:
        for tkey in ["BLOCK_START", "BLOCK_END"]:
            hh, mm = map(int, config[key][tkey].split(":"))
            config[key][tkey] = dtime(hh, mm)
    return config

class UsageManager:
    def __init__(self):
        # Order
        self.is_ntp_synced_cache = False
        self.is_notify_remaining_time_cache = False
        self.config = load_config()
        self.profile = self._load_profile()
        protect_usage_file(self._get_now().date())

    def _load(self):
        try:
            data = read_usage_file() 
            if "date" not in data:
                data["date"] = self._get_now().date().isoformat()
                data["seconds"] = data.get("seconds", 0)
                update_usage_file(data)
            if data["date"] != self._get_now().date().isoformat():
                protect_usage_file(self._get_now().date())
                return 0
            return data.get("seconds", 0)
        except Exception as e:
            notify(f"Because of an error, usage file is reset: {str(e)}")
            protect_usage_file(self._get_now().date())
            return 0
    
    def _get_now(self) -> datetime:
        if self.is_ntp_synced_cache:
            return datetime.now()
        # Busy wait until NTP is synced
        while True:
            if is_ntp_synced():
                self.is_ntp_synced_cache = True
                return datetime.now()
            notify("Waiting NTP..")
            time.sleep(60)

    def _load_profile(self):
        try:
            now = self._get_now()
            if now.weekday() < 5:  # 0=Monday, 4=Friday
                return self.config["weekday"]
            else:
                return self.config["weekend"]
        except Exception as e:
            notify(f"Unknown error at load_profile: {str(e)}")
    
    def _daily_limit_sec(self):
        hours = self.profile["DAILY_LIMIT_HOURS"]
        return hours * UNIT * UNIT
    
    def _pomodoro_start(self):
        start_minute = self.profile["POMODORO_START"]
        return start_minute

    def _night_block_time(self):
        start_hour = self.profile["BLOCK_START"]
        end_hour = self.profile["BLOCK_END"]
        return start_hour, end_hour

    def is_limit_exceeded(self) -> bool:
        return self._daily_limit_sec() - self._load() <= 0

    def is_pomodoro_block_time(self) -> bool:
        return self._get_now().minute > self._pomodoro_start()

    def is_night_block_time(self) -> bool:
        start, end = self._night_block_time()
        now = self._get_now().time()

        if start < end:
            # 例: 20:00 → 23:00
            return start <= now <= end
        else:
            # 例: 20:00 → 翌07:00
            return now >= start or now <= end

    def is_notified(self) -> bool:
        return self._get_now().minute % 10 == 0

    def notify_remaining_time(self):
        used = self._load()
        remain = self._daily_limit_sec() - used
        minutes = max(remain // 60, 0)
        notify(f"Remaining: {minutes} minutes")


    def add_minutes(self):
        seconds = self._load()
        new_data = {}
        new_data["date"] = self._get_now().date().isoformat() # iso format
        new_data["seconds"] = seconds + 5
        update_usage_file(new_data)
        time.sleep(5)

def start_loop():
    while True:
        try:
            # Night blocking time check
            if usage.is_night_block_time() or usage.is_limit_exceeded():
                try:
                    notify("shutdown time")
                    shutdown_all()
                except Exception as e:
                    notify(f"Shutdown failed {str(e)}")
                    return

            # Pomodoro block time check
            if usage.is_pomodoro_block_time():
                try:
                    notify("suspend time")
                    suspend_all()
                except Exception as e:
                    notify(f"Suspend failed {str(e)}")
                    return
            
            if usage.is_notified():
                if not usage.is_notify_remaining_time_cache:
                    usage.notify_remaining_time()
                    usage.is_notify_remaining_time_cache = True
            else:
                usage.is_notify_remaining_time_cache = False
            usage.add_minutes()

        except Exception as e:
            notify(f"Error happens: {str(e)}")
            return