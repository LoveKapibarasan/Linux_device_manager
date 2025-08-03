import gi
import threading
from gi.repository import Gtk, GLib
from block_manager import start_combined_loop, UsageManager

class ShutdownApp(Gtk.Window):
    def __init__(self):
        Gtk.Window.__init__(self, title="Shutdown Control App")
        self.set_border_width(10)
        self.set_default_size(300, 100)

        vbox = Gtk.Box(orientation=Gtk.Orientation.VERTICAL, spacing=6)
        self.add(vbox)

        self.label = Gtk.Label(label="残り時間を取得中...")
        vbox.pack_start(self.label, True, True, 0)

        self.usage = UsageManager()
        GLib.timeout_add_seconds(1, self.update_label)

        thread = threading.Thread(target=start_combined_loop, daemon=True)
        thread.start()

    def update_label(self):
        sec = self.usage.seconds_left()
        mins = sec // 60
        rem_sec = sec % 60
        self.label.set_text(f"残り使用可能時間: {mins}分 {rem_sec}秒")
        return True

if __name__ == "__main__":
    gi.require_version("Gtk", "3.0")
    win = ShutdownApp()
    win.connect("destroy", Gtk.main_quit)
    win.show_all()
    Gtk.main()
