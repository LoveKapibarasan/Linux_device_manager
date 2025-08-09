import os
import sys
import threading
import time
import signal
from block_manager import UsageManager, start_combined_loop, notify

class ShutdownCUIApp:
    def __init__(self):
        self.running = True
        self.usage = UsageManager()

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
                    notify("強制終了無視", "sudo権限が必要です。強制終了は無視されます。")
                    continue

        except Exception as e:
            notify("予期しないエラー", str(e))
            # エラーが発生しても終了しない
            time.sleep(1)
            if self.running:
                notify("再起動", "🔄 アプリケーションを再起動します...")
                self.run()  # 再帰的に再起動

if __name__ == "__main__":
    app = ShutdownCUIApp()
    while True:
        try:
            app.run()  # blocks until error or intentional exit
        except Exception as e:
            from block_manager import notify
            notify("⚠️ アプリ停止", f"エラー発生: {e}")
        # wait briefly before restart
        time.sleep(1)
        notify("🔄 再起動", "アプリケーションを再起動します…")

