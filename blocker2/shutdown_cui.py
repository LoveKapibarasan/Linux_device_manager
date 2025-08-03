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
        
        # シグナルハンドラーを設定
        signal.signal(signal.SIGINT, self.signal_handler)
        signal.signal(signal.SIGTERM, self.signal_handler)
        
        print("=== Shutdown Control App (CUI版) ===")
        print("Ctrl+C で終了")
        print("=" * 40)
    
    def signal_handler(self, signum, frame):
        """シグナル受信時の処理"""
        print("\n終了シグナルを受信しました。アプリケーションを終了します...")
        self.running = False
    
    def update_display(self):
        """時間表示の更新"""
        while self.running:
            sec = self.usage.seconds_left()
            mins = sec // 60
            rem_sec = sec % 60
            hours = mins // 60
            rem_mins = mins % 60
            
            # カーソルを行の先頭に戻して上書き
            timestamp = datetime.now().strftime("%H:%M:%S")
            status_line = f"\r[{timestamp}] 残り使用可能時間: {hours:02d}:{rem_mins:02d}:{rem_sec:02d}"
            print(status_line, end="", flush=True)
            
            time.sleep(1)
    
    def run(self):
        """メインループ"""
        try:
            # バックグラウンドで時間管理スレッドを開始
            control_thread = threading.Thread(target=start_combined_loop, daemon=True)
            control_thread.start()
            
            # 表示更新スレッドを開始
            display_thread = threading.Thread(target=self.update_display, daemon=True)
            display_thread.start()
            
            # メインスレッドは待機
            while self.running:
                time.sleep(0.1)
                
        except KeyboardInterrupt:
            print("\nKeyboardInterrupt: アプリケーションを終了します...")
        finally:
            self.running = False
            print("\nアプリケーションが終了しました。")

if __name__ == "__main__":
    app = ShutdownCUIApp()
    app.run()
