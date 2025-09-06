from block_manager import start_loop
from utils import notify, cancel_shutdown

def run():
    try:
        # delete pending shutdown tasks for rasberrypi
        cancel_shutdown()
        start_loop()
    except Exception as e:
        notify(f"Error: {str(e)}")

if __name__ == "__main__":
    run()