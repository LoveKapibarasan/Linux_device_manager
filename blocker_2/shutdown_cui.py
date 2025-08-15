import threading
import time
from block_manager import UsageManager, start_combined_loop
from utils import notify, cancel_shutdown

class ShutdownCUIApp:
    def __init__(self):
        self.usage = UsageManager()

    def run(self):
        try:
            start_combined_loop()  # blocks until killed
        except Exception as e:
            notify(f"Error: {str(e)}")

if __name__ == "__main__":
    app = ShutdownCUIApp()
    app.run()  # blocks until error or intentional exit