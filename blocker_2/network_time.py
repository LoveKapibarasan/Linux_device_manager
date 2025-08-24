import time
import json
import subprocess
from datetime import datetime, timedelta
from datetime import time as dtime
from zoneinfo import ZoneInfo

from utils import notify, shutdown_all_as_admin, suspend_all_as_admin, protect_usage_file, read_usage_file, update_usage_file

# === Time Unit Constants ===
SECOND = 1
MINUTE = 60 * SECOND
HOUR = 60 * MINUTE

TIMEZONE = "Europe/Berlin"
TIME_API_URL = f"https://worldtimeapi.org/api/timezone/{TIMEZONE}"

# === ネット時刻補正 ===
_delta = None  # timedelta補正

def _fetch_net_time():
    """curlでネット時刻を取得（成功ならdatetime、失敗ならNone）"""
    try:
        out = subprocess.check_output(
            ["curl", "-sS", "--max-time", "5", TIME_API_URL],
            text=True
        )
        data = json.loads(out)
        if "datetime" in data:
            return datetime.fromisoformat(data["datetime"]).astimezone(ZoneInfo(TIMEZONE))
        elif "unixtime" in data:
            return datetime.fromtimestamp(data["unixtime"], ZoneInfo(TIMEZONE))
    except Exception:
        return None

def now():
    """ネット時刻で一度補正し、その後は system clock + delta で返す"""
    global _delta
    tz = ZoneInfo(TIMEZONE)

    if _delta is None:
        while True:
            net_time = _fetch_net_time()
            if net_time:
                sys_time = datetime.now(tz)
                _delta = net_time - sys_time
                notify(f"✅ ネット時刻同期完了: {net_time} (delta={_delta})")
                break
            notify("🌐 ネット未接続/時刻取得失敗 → 30秒後に再試行中（全処理停止）")
            time.sleep(30)

    return datetime.now(tz) + _delta

# === Config ===
CONFIG = {
    "weekday": {
        "DAILY_LIMIT_HOURS": 9,
        "WARN_MIN": 2,
        "POMODORO_START": 55,           # xx:55 ~ xx:00 はブロック
        "BLOCK_START": dtime(20, 0),    # 20:00
        "BLOCK_END": dtime(7, 0),       # 07:00
    },
    "weekend": {
        "DAILY_LIMIT_HOURS": 4,
        "WARN_MIN": 2,
        "POMODORO_START": 50,
        "BLOCK_START": dtime(20, 0),
        "BLOCK_END": dtime(7, 0),
    },
}

def _profile_for(nowdt: datetime) -> str:
    return "weekend" if nowdt.weekday() >= 5 else "weekday"

def _cfg(nowdt: datetime) -> dict:
    return CONFIG[_profile_for(nowdt)]

def daily_limit_sec(nowdt: datetime) -> int:
    return _cfg(nowdt)["DAILY_LIMIT_HOURS"] * HOUR

def warn_sec(nowdt: datetime) -> int:
    return _cfg(nowdt)["WARN_MIN"] * MINUTE

def pomodoro_start_minute(nowdt: datetime) -> int:
    return _cfg(nowdt)["POMODORO_START"]

def block_window(nowdt: datetime) -> tuple[dtime, dtime]:
    c = _cfg(nowdt)
    return c["BLOCK_START"], c["BLOCK_END"]

# === UsageManager ===
class UsageManager:
    def __init__(self):
        protect_usage_file(self._today())

    def _today(self):
        return now().strftime("%Y-%m-%d")

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

    def is_limit_exceeded(self):
        data = self._load()
        if data["date"] != self._today():
            protect_usage_file(self._today())
            return False
        return max(0, daily_limit_sec(now()) - data.get("seconds", 0)) <= 0

    def notify_remaining_time(self):
        data = self._load()
        if data["date"] != self._today():
            notify("Usage file is reset, no data available.")
            return daily_limit_sec(now())
        remaining = max(0, daily_limit_sec(now()) - data.get("seconds", 0))
        if remaining <= warn_sec(now()):
            notify(f"⚠️残り時間: {remaining // MINUTE}分")
        return remaining

# === Check functions ===
def is_pomodoro_block_time():
    return now().minute >= pomodoro_start_minute(now())

def is_block_time():
    nowt = now().time()
    start, end = block_window(now())
    if start < end:
        return start <= nowt < end
    else:
        return nowt >= start or nowt < end

def is_notified():
    return (now().minute % 5 == 0) and (now().second in (0, 1))

# === Main Loop ===
def start_combined_loop():
    usage = UsageManager()
    while True:
        try:
            if is_block_time() or usage.is_limit_exceeded():
                bs, be = block_window(now())
                if is_notified():
                    notify(f"Now in {bs.strftime('%H:%M')}~{be.strftime('%H:%M')}")
                try:
                    shutdown_all_as_admin()
                except Exception as e:
                    notify(f"❌Shutdown failed {str(e)}")
                time.sleep(1)
                return

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
