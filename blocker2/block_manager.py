import time
import subprocess
import json
import os
from datetime import datetime

# ユーザーのホームディレクトリに保存するように変更
USAGE_FILE = os.path.expanduser("~/.shutdown_app_usage.json")
DAILY_LIMIT_SEC = 300 * 60  # 1日の制限時間（秒）

def notify(summary, body):
    """CUI版通知 - コンソールに出力 + システム通知"""
    timestamp = datetime.now().strftime("%H:%M:%S")
    print(f"\n[{timestamp}] 🔔 {summary}: {body}")
    
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
    
    notify("🔒 システム監視開始", "デバイス使用制限が有効になりました")

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

            elif phase == "break":
                if counter == 0:
                    notify("☕ 休憩時間", "20分休憩開始")
                    # 休憩開始時刻を保護されたファイルに記録
                    break_start_file = "/tmp/.break_start_time"
                    try:
                        with open(break_start_file, "w") as f:
                            f.write(str(time.time()))
                        # ファイルを読み取り専用に設定（一般ユーザーが編集不可）
                        os.chmod(break_start_file, 0o444)
                    except Exception as e:
                        notify("⚠️ 警告", f"休憩時刻記録エラー: {str(e)}")
                
                # 休憩時間の経過をチェック
                break_start_file = "/tmp/.break_start_time"
                try:
                    if os.path.exists(break_start_file):
                        with open(break_start_file, "r") as f:
                            break_start_time = float(f.read().strip())
                        
                        elapsed_break_time = time.time() - break_start_time
                        remaining_break_time = (20 * 60) - elapsed_break_time
                        
                        if elapsed_break_time >= 20 * 60:
                            # 20分経過：集中モードに戻る
                            notify("🎯 休憩終了", "集中時間に戻ります")
                            phase = "focus"
                            counter = 0
                            # 休憩時刻ファイルを削除
                            try:
                                os.remove(break_start_file)
                            except:
                                pass
                        else:
                            # 20分未経過：常にサスペンド実行
                            try:
                                notify("💤 システムサスペンド", f"残り休憩時間: {int(remaining_break_time/60)}分{int(remaining_break_time%60)}秒")
                                subprocess.run(["systemctl", "suspend", "--ignore-inhibitors"], check=True)
                            except Exception as e:
                                notify("❌ サスペンド失敗", f"エラー: {str(e)}")
                    else:
                        # ファイルが存在しない場合は再作成
                        counter = 0
                except Exception as e:
                    notify("⚠️ エラー", f"休憩時間管理エラー: {str(e)}")

            usage.add_second()
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
