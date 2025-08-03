import os
import sys
import threading
import time
import signal
from datetime import datetime
from block_manager import UsageManager, start_combined_loop

class ShutdownCUIApp:
    def __init__(self):
        self.running = True
        self.usage = UsageManager()
        # ログファイルの設定
        self.log_file = os.path.expanduser("~/.shutdown_cui.log")
        # ログファイルがなければ作成（パーミッションも明示）
        try:
            with open(self.log_file, "a", encoding="utf-8") as f:
                pass
        except Exception as e:
            print(f"ログファイル作成エラー: {e}")

    
    def log_message(self, message):
        """ユーザーアクセス可能なログファイルに記録"""
        try:
            timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            log_entry = f"[{timestamp}] {message}\n"
            with open(self.log_file, "a", encoding="utf-8") as f:
                f.write(log_entry)
        except Exception as e:
            print(f"ログ記録エラー: {e}")

    def signal_handler(self, signum, frame):
        """シグナル受信時の処理 - sudo権限チェック"""
        message = f"⚠️ 終了リクエストが検出されました (シグナル: {signum})"
        print(f"\n{message}")
        print("このアプリケーションはsudo権限でのみ終了できます。")
        self.log_message(message)

        # sudo権限のチェック
        if not self.check_sudo_permission():
            deny_message = "❌ sudo権限が必要です。終了が拒否されました。"
            print(deny_message)
            print("終了するには: sudo pkill -f shutdown_cui.py")
            self.log_message(deny_message)
            return

        success_message = "✅ sudo権限が確認されました。アプリケーションを終了します..."
        print(success_message)
        self.log_message(success_message)
        self.running = False

    def check_sudo_permission(self):
        """sudo権限があるかチェック"""
        try:
            # sudoコマンドでID確認を試行
            import subprocess
            result = subprocess.run(
                ["sudo", "-n", "id"], 
                capture_output=True, 
                text=True, 
                timeout=1
            )
            return result.returncode == 0
        except:
            return False

    def run(self):
        """メインループ - 保護モード"""
        try:
            # バックグラウンドで時間管理スレッドを開始
            control_thread = threading.Thread(target=start_combined_loop, daemon=True)
            control_thread.start()

            # メインスレッドは保護モードで待機
            consecutive_interrupts = 0
            while self.running:
                try:
                    time.sleep(0.1)
                except KeyboardInterrupt:
                    print("sudo権限が必要です。強制終了は無視されます。")
                    continue

        except Exception as e:
            print(f"\n❌ 予期しないエラー: {e}")
            print("保護モードを維持します...")
            # エラーが発生しても終了しない
            time.sleep(1)
            if self.running:
                print("🔄 アプリケーションを再起動します...")
                self.run()  # 再帰的に再起動
        finally:
            if self.running:
                print("\n🔒 保護モードが維持されています。")
            else:
                print("\n✅ 正常に終了しました。")

if __name__ == "__main__":
    app = ShutdownCUIApp()
    app.run()
