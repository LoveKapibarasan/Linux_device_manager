import time
import subprocess
import json
import os
from datetime import datetime

USAGE_FILE = os.path.expanduser("~/.shutdown_app_usage.json")
# ファイルがなければ作成し、sudoユーザー(root)以外編集禁止 (root:root 644)
import stat
if not os.path.exists(USAGE_FILE):
    try:
        with open(USAGE_FILE, "w") as f:
            f.write('{}')
        os.chmod(USAGE_FILE, 0o644)
        os.chown(USAGE_FILE, 0, 0)
    except Exception as e:
        print(f"USAGE_FILE作成・権限設定エラー: {e}")


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


LOG_FILE_PATH = os.path.expanduser("~/.shutdown_cui.log")

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
    except Exception as e:
        err_msg = f"[{timestamp}] [ERROR] ログ書き込み失敗: {e}\n"
        print(err_msg)
        try:
            with open(LOG_FILE_PATH, "a") as f:
                f.write(err_msg)
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

    def _today(self):
        return datetime.now().strftime("%Y-%m-%d")

    def _load(self):
        try:
            with open(USAGE_FILE, "r") as f:
                data = json.load(f)
            # 'date'キーがなければ初期化
            if "date" not in data:
                data["date"] = self._today()
                data["seconds"] = data.get("seconds", 0)
                self._save(data)
            return data
        except (json.JSONDecodeError, FileNotFoundError):
            # ファイルが空・壊れている・存在しない場合は初期化
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

# Pomodoro処理本体（1秒単位で制御）- 保護モード
def start_combined_loop():
    """保護モード付きメインループ"""
    usage = UsageManager()
    notified_2min = False
    phase = "focus"
    counter = 0
    
    # 起動時に状態復元を試行
    state_file = "/tmp/.pomodoro_state"
    try:
        if os.path.exists(state_file):
            with open(state_file, "r") as f:
                state_data = json.load(f)
            
            restored_phase = state_data.get("phase", "focus")
            restored_counter = state_data.get("counter(経過時間)", 0)
            phase_start_timestamp = state_data.get("phase_start_timestamp", time.time())
            
            # 経過時間を計算
            elapsed_since_phase_start = time.time() - phase_start_timestamp
            current_counter = restored_counter + int(elapsed_since_phase_start)
            
            if restored_phase == "focus":
                if current_counter >= FOCUS_SEC:
                    # FOCUS_MINUTES分経過済み - 休憩フェーズに移行
                    phase = "break"
                    counter = 0
                    notify("🔄 状態復元", "集中時間終了 - 休憩フェーズに移行")
                else:
                    # 集中時間継続
                    phase = "focus"
                    counter = current_counter
                    remaining_min = int((FOCUS_SEC - counter) / MINUTE)
                    notify("🔄 状態復元", f"集中時間継続 - 残り{remaining_min}分")
            
            elif restored_phase == "break":
                if current_counter >= BREAK_SEC:
                    # BREAK_MINUTES分経過済み - 集中フェーズに移行
                    phase = "focus"
                    counter = 0
                    notify("🔄 状態復元", "休憩時間終了 - 集中フェーズに移行")
                else:
                    # 休憩時間継続
                    phase = "break"
                    counter = current_counter
                    remaining_min = int((BREAK_SEC - counter) / MINUTE)
                    notify("🔄 状態復元", f"休憩時間継続 - 残り{remaining_min}分")
                    # 休憩中なら即座にサスペンド
                    try:
                        # サスペンド前に状態を保存
                        state_data = {
                            "phase": phase,
                            "counter(経過時間)": counter,
                            "phase_start_timestamp": time.time() - counter
                        }
                        with open(state_file, "w") as f:
                            json.dump(state_data, f)
                        os.chmod(state_file, 0o600)  # 所有ユーザーのみ読み書き可
                        
                        notify("💤 システムサスペンド", f"残り休憩時間: {remaining_min}分")
                        subprocess.run(["systemctl", "suspend", "--ignore-inhibitors"], check=True)
                    except Exception as e:
                        notify("❌ サスペンド失敗", f"エラー: {str(e)}")
    except Exception as e:
        notify("⚠️ 警告", f"状態復元エラー（初期値で開始）: {str(e)}")
    
    notify("🔒 システム監視開始", "デバイス使用制限が有効になりました")

    # 定期ログ出力用カウンター
    log_counter = 0

    def is_block_time():
        now = datetime.now().time()
        # 20:00~23:59 or 00:00~07:00 の間はTrue
        if BLOCKDURATION_START < BLOCKDURATION_END:
            return BLOCKDURATION_START <= now < BLOCKDURATION_END
        else:
            return now >= BLOCKDURATION_START or now < BLOCKDURATION_END

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
            if usage.seconds_left() <= WARN_2MIN_BEFORE_SEC and not notified_2min:
                notify("⚠️ 警告", f"残り{WARN_2MIN_BEFORE_SEC//60}分です。作業を保存してください")
                notified_2min = True

            if usage.is_limit_exceeded():
                notify("🔴 時間制限", "使用時間が上限に達しました。シャットダウンします。")
                try:
                    subprocess.run(["systemctl", "poweroff", "--ignore-inhibitors", "-i"], check=True)
                except Exception as e:
                    notify("❌ シャットダウン失敗", f"エラー: {str(e)}")
                break

            if phase == "focus":
                if counter == 0:
                    notify("🎯 集中時間", f"{FOCUS_MINUTES}分作業開始")
                # 休憩2分前に通知
                if counter == FOCUS_SEC - WARN_2MIN_BEFORE_SEC:
                    notify("⏰ 休憩2分前", f"まもなく休憩時間です。作業を保存してください")
                counter += 1
                if counter >= FOCUS_SEC:
                    phase = "break"
                    counter = 0
                    notify("☕ 休憩時間", f"{BREAK_MINUTES}分休憩開始")

            elif phase == "break":
                if counter == 0:
                    # 休憩開始時はすぐにサスペンド
                    try:
                        # サスペンド前に状態を保存
                        state_data = {
                            "phase": phase,
                            "counter(経過時間)": counter,
                            "phase_start_timestamp": time.time()
                        }
                        with open(state_file, "w") as f:
                            json.dump(state_data, f)
                        os.chmod(state_file, 0o600)  # 実行ユーザーのみ読み書き可
                        notify("💤 システムサスペンド", "休憩時間のためサスペンドします")
                        subprocess.run(["systemctl", "suspend", "--ignore-inhibitors"], check=True)
                    except Exception as e:
                        notify("❌ サスペンド失敗", f"エラー: {str(e)}")
                
                # breakフェーズでは時刻ベースで判定
                try:
                    with open(state_file, "r") as f:
                        current_state = json.load(f)
                    phase_start = current_state.get("phase_start_timestamp", time.time())
                    elapsed_time = time.time() - phase_start

                    if elapsed_time >= BREAK_SEC:
                        phase = "focus"
                        counter = 0
                        notify("🎯 休憩終了", "集中時間に戻ります")
                    else:
                        counter = int(elapsed_time)
                except:
                    notify("⚠️ 警告", f"休憩時間の状態取得に失敗。集中時間に戻ります:{str(e)}")
                    phase = "focus"

            # 毎秒状態を保存
            state_file = "/tmp/.pomodoro_state"
            try:
                # phase_start_timestampを決定
                phase_start_timestamp = time.time() - counter
                if os.path.exists(state_file):
                    try:
                        with open(state_file, "r") as f:
                            existing_data = json.load(f)
                        if existing_data.get("phase") == "break":
                            phase_start_timestamp = existing_data.get("phase_start_timestamp", phase_start_timestamp)
                    except Exception as e:
                        notify("⚠️ 警告", f"ステートファイル読み込みエラー - 新規作成します:{str(e)}")

                state_data = {
                    "phase": phase,
                    "counter(経過時間)": counter,
                    "phase_start_timestamp": phase_start_timestamp
                }
                with open(state_file, "w") as f:
                    json.dump(state_data, f)
                # sudo以外編集禁止 (root:root 644)
                os.chmod(state_file, 0o600)  # 所有ユーザーのみ読み書き可
            except Exception as e:
                notify("⚠️ 警告", f"ステート保存エラー: {str(e)}")

            usage.add_second()

            # LOG_INTERVAL_SECごとに状況をログ出力（一般ユーザー向け）
            log_counter += 1
            if log_counter >= LOG_INTERVAL_SEC:
                log_counter = 0
                remaining_daily = usage.seconds_left()
                daily_hours = remaining_daily // HOUR
                daily_mins = (remaining_daily % HOUR) // MINUTE
                
                if phase == "focus":
                    focus_remaining = FOCUS_SEC - counter
                    focus_mins = focus_remaining // MINUTE
                    focus_secs = focus_remaining % MINUTE
                    notify("📊 現在状況", f"集中時間残り: {focus_mins}分{focus_secs}秒 | 1日残り: {daily_hours}時間{daily_mins}分")
                else:
                    # breakフェーズでは時刻ベースで計算
                    try:
                        with open(state_file, "r") as f:
                            current_state = json.load(f)
                        phase_start = current_state.get("phase_start_timestamp", time.time())
                        elapsed_time = time.time() - phase_start
                        break_remaining = BREAK_SEC - elapsed_time
                        if break_remaining > 0:
                            break_mins = int(break_remaining // MINUTE)
                            break_secs = int(break_remaining % MINUTE)
                            notify("📊 現在状況", f"休憩時間残り: {break_mins}分{break_secs}秒 | 1日残り: {daily_hours}時間{daily_mins}分")
                    except Exception as e:
                        notify("📊 現在状況", f"休憩中 | 1日残り: {daily_hours}時間{daily_mins}分:{str(e)}")
            time.sleep(1)

        except KeyboardInterrupt:
            # キーボード割り込みを無視
            notify("🚫 KeyboardInterrupt検出", "保護モードのため終了を拒否しました")
            continue
        except Exception as e:
            # その他のエラーもキャッチして継続
            notify("⚠️ エラー発生", f"処理を継続します: {str(e)}")
            time.sleep(1)
            continue
