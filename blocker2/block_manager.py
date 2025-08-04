import time
import subprocess
import json
import os
from datetime import datetime
import stat

USAGE_FILE = os.path.expanduser("~/.shutdown_app_usage.json")
LOG_FILE_PATH = os.path.expanduser("~/.shutdown_cui.log")

def ensure_root_owned_644(path):
    try:
        os.chmod(path, 0o644)
        os.chown(path, 0, 0)
    except Exception:
        pass

# USAGE_FILEの初期化と権限設定
if not os.path.exists(USAGE_FILE):
    try:
        with open(USAGE_FILE, "w") as f:
            f.write('{}')
        ensure_root_owned_644(USAGE_FILE)
    except Exception as e:
        try:
            from block_manager import notify
            notify("USAGE_FILE作成・権限設定エラー", str(e))
        except:
            pass
else:
    ensure_root_owned_644(USAGE_FILE)

# LOG_FILE_PATHの初期化と権限設定
if not os.path.exists(LOG_FILE_PATH):
    try:
        with open(LOG_FILE_PATH, "a") as f:
            pass
        ensure_root_owned_644(LOG_FILE_PATH)
    except Exception as e:
        try:
            from block_manager import notify
            notify("LOG_FILE作成・権限設定エラー", str(e))
        except:
            pass
else:
    ensure_root_owned_644(LOG_FILE_PATH)


# === Pomodoro/Blocker Timing Settings (Global) ===

# === Time Unit Constants ===
SECOND = 1
MINUTE = 60 * SECOND
HOUR = 60 * MINUTE

# === Pomodoro/Blocker Timing Settings (Global) ===

LOG_INTERVAL_SEC = 5 * MINUTE  # 5分ごとにログ出力
FOCUS_MINUTES = 50
BREAK_MINUTES = 20
DAILY_LIMIT_HOURS = 5
FOCUS_SEC = FOCUS_MINUTES * MINUTE
BREAK_SEC = BREAK_MINUTES * MINUTE
DAILY_LIMIT_SEC = DAILY_LIMIT_HOURS * HOUR
WARN_2MIN_BEFORE_SEC = 2 * MINUTE

# 強制ブロック時間帯（夜間矯正）
from datetime import time as dtime
BLOCKDURATION_START = dtime(20, 0)  # 20:00
BLOCKDURATION_END = dtime(7, 0)    # 07:00


def set_log_file_path(path):
    global LOG_FILE_PATH
    LOG_FILE_PATH = path

def notify(summary, body):
    """CUI版通知 - コンソールに出力 + システム通知 + ユーザーログ"""
    timestamp = datetime.now().strftime("%H:%M:%S")
    print(f"\n[{timestamp}] 🔔 {summary}: {body}")
    try:
        with open(LOG_FILE_PATH, "a") as f:
            f.write(f"[{timestamp}] {summary}: {body}\n")
        ensure_root_owned_644(LOG_FILE_PATH)
    except Exception as e:
        err_msg = f"[{timestamp}] [ERROR] ログ書き込み失敗: {e}\n"
        try:
            with open(LOG_FILE_PATH, "a") as f:
                f.write(err_msg)
            ensure_root_owned_644(LOG_FILE_PATH)
        except:
            pass

    # システム通知を試行 (DBUS_SESSION_BUS_ADDRESSをセット)
    try:
        env = os.environ.copy()
        if "DBUS_SESSION_BUS_ADDRESS" not in env or not env["DBUS_SESSION_BUS_ADDRESS"]:
            # ユーザーのgnome-sessionやplasmashell等からDBUSアドレスを取得
            try:
                user = os.environ.get("SUDO_USER") or os.environ.get("USER") or os.getlogin()
                # gnome-session優先
                pid = subprocess.check_output([
                    "pgrep", "-u", user, "gnome-session"
                ]).decode().strip().split('\n')[0]
                with open(f"/proc/{pid}/environ", "rb") as f:
                    envs = f.read().split(b'\0')
                for e in envs:
                    if e.startswith(b"DBUS_SESSION_BUS_ADDRESS="):
                        env["DBUS_SESSION_BUS_ADDRESS"] = e.split(b"=",1)[1].decode()
                        break
            except Exception as e_dbus:
                # 取得失敗時はエラーログを出す
                err_msg = f"[{timestamp}] [ERROR] DBUS_SESSION_BUS_ADDRESS取得失敗: {e_dbus}\n"
                print(err_msg)
                try:
                    with open(LOG_FILE_PATH, "a") as f:
                        f.write(err_msg)
                except:
                    pass
        subprocess.run([
            "notify-send",
            "--urgency=critical",
            "--expire-time=5000",
            f"{summary}",
            f"{body}"
        ], check=False, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, env=env)
    except Exception as e:
        # エラーも同じログファイルに出す
        err_msg = f"[{timestamp}] [ERROR] notify-send失敗: {e}\n"
        print(err_msg)
        try:
            with open(LOG_FILE_PATH, "a") as f:
                f.write(err_msg)
        except:
            pass


# 時間情報を管理するクラス
class UsageManager:
    def __init__(self):
        self._ensure_file()

    def _ensure_file(self):
        if not os.path.exists(USAGE_FILE):
            self._save({"date": self._today(), "seconds": 0})
        else:
            ensure_root_owned_644(USAGE_FILE)

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
        ensure_root_owned_644(USAGE_FILE)

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
    if BLOCKDURATION_START < BLOCKDURATION_END:
        return BLOCKDURATION_START <= now < BLOCKDURATION_END
    else:
        return now >= BLOCKDURATION_START or now < BLOCKDURATION_END

def start_combined_loop():
    usage = UsageManager()
    notified_block = False
    notify("🔒 システム監視開始", "デバイス使用制限が有効になりました（固定時間制）")
    log_counter = 0
    while True:
        try:
            # 夜間強制ブロック
            if is_block_time():
                notify("⏰ 強制ブロック時間", f"現在は{BLOCKDURATION_START.strftime('%H:%M')}~{BLOCKDURATION_END.strftime('%H:%M')}の間です。シャットダウンします。")
                try:
                    subprocess.run(["systemctl", "poweroff", "--ignore-inhibitors", "-i"], check=True)
                except Exception as e:
                    notify("❌ シャットダウン失敗", f"エラー: {str(e)}")
                break

            # 固定時間制ポモドーロブロック
            if is_pomodoro_block_time():
                if not notified_block:
                    notify("⏰ ポモドーロブロック", "毎時55分～00分は使用禁止です。シャットダウンします。")
                    notified_block = True
                try:
                    subprocess.run(["systemctl", "poweroff", "--ignore-inhibitors", "-i"], check=True)
                except Exception as e:
                    notify("❌ シャットダウン失敗", f"エラー: {str(e)}")
                break
            else:
                notified_block = False

            usage.add_second()

            # LOG_INTERVAL_SECごとに状況をログ出力
            log_counter += 1
            if log_counter >= LOG_INTERVAL_SEC:
                log_counter = 0
                remaining_daily = usage.seconds_left()
                daily_hours = remaining_daily // HOUR
                daily_mins = (remaining_daily % HOUR) // MINUTE
                notify("📊 現在状況", f"1日残り: {daily_hours}時間{daily_mins}分")
            time.sleep(1)

        except KeyboardInterrupt:
            notify("🚫 KeyboardInterrupt検出", "保護モードのため終了を拒否しました")
            continue
        except Exception as e:
            notify("⚠️ エラー発生", f"処理を継続します: {str(e)}")
            time.sleep(1)
            continue
