import os
# Load autoconfig.yml (GUI changes)
config.load_autoconfig()

# Allow full clipboard access on HTTPS pages
config.set("content.javascript.clipboard", "access", "https://*")

c.tabs.show = "never"

# ホームディレクトリを自動解決
home = os.path.expanduser("~")

# 起動時に開くページ
c.url.start_pages = [f"file://{home}/Linux_device_manager/Install/config/index.html"]

# 新しいタブを開いたときのデフォルトページも設定する場合
c.url.default_page = f"file://{home}/Linux_device_manager/Install/config/index.html"
