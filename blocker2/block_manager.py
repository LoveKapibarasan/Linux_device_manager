import time
import subprocess
import json
import os
from datetime import datetime

# ユーザーのホームディレクトリに保存するように変更
USAGE_FILE = os.path.expanduser("~/.shutdown_app_usage.json")
DAILY_LIMIT_SEC = 300 * 60  # 1日の制限時間（秒）

def notify(summary, body):
    """CUI版通知 - コンソールに出力 + システム通知 + ユーザーログ"""
    timestamp = datetime.now().strftime("%H:%M:%S")
    print(f"\n[{timestamp}] 🔔 {summary}: {body}")
    
    # ユーザーアクセス可能なログファイルにも出力
    try:
        user_log_file = os.path.expanduser("~/.shutdown_cui.log")
        with open(user_log_file, "a") as f:
            f.write(f"[{timestamp}] {summary}: {body}\n")
    except:
        pass
    
    # システム通知を試行
    try:
        subprocess.run([
            "notify-send", 
            "--urgency=critical", 
            "--expire-time=5000",
            f"{summary}", 
            f"{body}"
        ], check=False, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    except:
        pass  # 失敗しても無視
    
    # さらに目立つようにベルを鳴らす
    try:
        print("\a", end="", flush=True)  # ベル音
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
                if current_counter >= 50 * 60:
                    # 50分経過済み - 休憩フェーズに移行
                    phase = "break"
                    counter = 0
                    notify("🔄 状態復元", "集中時間終了 - 休憩フェーズに移行")
                else:
                    # 集中時間継続
                    phase = "focus"
                    counter = current_counter
                    remaining_min = int((50 * 60 - counter) / 60)
                    notify("🔄 状態復元", f"集中時間継続 - 残り{remaining_min}分")
            
            elif restored_phase == "break":
                if current_counter >= 20 * 60:
                    # 20分経過済み - 集中フェーズに移行
                    phase = "focus"
                    counter = 0
                    notify("🔄 状態復元", "休憩時間終了 - 集中フェーズに移行")
                else:
                    # 休憩時間継続
                    phase = "break"
                    counter = current_counter
                    remaining_min = int((20 * 60 - counter) / 60)
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
                        os.chmod(state_file, 0o644)
                        os.chown(state_file, 0, 0)
                        
                        notify("💤 システムサスペンド", f"残り休憩時間: {remaining_min}分")
                        subprocess.run(["systemctl", "suspend", "--ignore-inhibitors"], check=True)
                    except Exception as e:
                        notify("❌ サスペンド失敗", f"エラー: {str(e)}")
    except Exception as e:
        notify("⚠️ 警告", f"状態復元エラー（初期値で開始）: {str(e)}")
    
    notify("🔒 システム監視開始", "デバイス使用制限が有効になりました")

    # 定期ログ出力用カウンター（5分毎）
    log_counter = 0

    while True:
        try:
            if usage.seconds_left() <= 120 and not notified_2min:
                notify("⚠️ 警告", "残り2分です。作業を保存してください")
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
                    notify("🎯 集中時間", "50分作業開始")
                counter += 1
                if counter >= 50 * 60:
                    phase = "break"
                    counter = 0
                    notify("☕ 休憩時間", "20分休憩開始")

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
                        os.chmod(state_file, 0o644)
                        os.chown(state_file, 0, 0)
                        
                        notify("💤 システムサスペンド", "休憩時間のためサスペンドします")
                        subprocess.run(["systemctl", "suspend", "--ignore-inhibitors"], check=True)
                    except Exception as e:
                        notify("❌ サスペンド失敗", f"エラー: {str(e)}")
                
                # breakフェーズでは時刻ベースで判定
                if os.path.exists(state_file):
                    try:
                        with open(state_file, "r") as f:
                            current_state = json.load(f)
                        phase_start = current_state.get("phase_start_timestamp", time.time())
                        elapsed_time = time.time() - phase_start
                        
                        if elapsed_time >= 20 * 60:
                            phase = "focus"
                            counter = 0
                            notify("🎯 休憩終了", "集中時間に戻ります")
                        else:
                            counter = int(elapsed_time)
                    except:
                        counter += 1
                else:
                    counter += 1

            # 毎秒状態を保存
            state_file = "/tmp/.pomodoro_state"
            try:
                # phase_start_timestampを決定
                if phase == "focus":
                    # focusモードでは常にcounter基準で計算
                    phase_start_timestamp = time.time() - counter
                else:
                    # breakモードでは既存のtimestampを保持
                    phase_start_timestamp = time.time() - counter
                    if os.path.exists(state_file):
                        try:
                            with open(state_file, "r") as f:
                                existing_data = json.load(f)
                            if existing_data.get("phase") == "break":
                                phase_start_timestamp = existing_data.get("phase_start_timestamp", phase_start_timestamp)
                        except:
                            pass
                
                state_data = {
                    "phase": phase,
                    "counter(経過時間)": counter,
                    "phase_start_timestamp": phase_start_timestamp
                }
                with open(state_file, "w") as f:
                    json.dump(state_data, f)
                # sudo以外編集禁止 (root:root 644)
                os.chmod(state_file, 0o644)
                os.chown(state_file, 0, 0)  # root:root
            except Exception as e:
                notify("⚠️ 警告", f"ステート保存エラー: {str(e)}")

            usage.add_second()
            
            # 5分毎に状況をログ出力（一般ユーザー向け）
            log_counter += 1
            if log_counter >= 300:  # 5分 = 300秒
                log_counter = 0
                remaining_daily = usage.seconds_left()
                daily_hours = remaining_daily // 3600
                daily_mins = (remaining_daily % 3600) // 60
                
                if phase == "focus":
                    focus_remaining = (50 * 60) - counter
                    focus_mins = focus_remaining // 60
                    focus_secs = focus_remaining % 60
                    notify("📊 現在状況", f"集中時間残り: {focus_mins}分{focus_secs}秒 | 1日残り: {daily_hours}時間{daily_mins}分")
                else:
                    # breakフェーズでは時刻ベースで計算
                    try:
                        with open(state_file, "r") as f:
                            current_state = json.load(f)
                        phase_start = current_state.get("phase_start_timestamp", time.time())
                        elapsed_time = time.time() - phase_start
                        break_remaining = (20 * 60) - elapsed_time
                        if break_remaining > 0:
                            break_mins = int(break_remaining // 60)
                            break_secs = int(break_remaining % 60)
                            notify("📊 現在状況", f"休憩時間残り: {break_mins}分{break_secs}秒 | 1日残り: {daily_hours}時間{daily_mins}分")
                    except:
                        notify("📊 現在状況", f"休憩中 | 1日残り: {daily_hours}時間{daily_mins}分")
            
            time.sleep(1)
            
        except KeyboardInterrupt:
            # キーボード割り込みを無視
            notify("🚫 終了試行検出", "保護モードのため終了を拒否しました")
            continue
        except Exception as e:
            # その他のエラーもキャッチして継続
            notify("⚠️ エラー発生", f"処理を継続します: {str(e)}")
            time.sleep(1)
            continue
