import os

### Arguments List
# qutebrowser: https://qutebrowser.org/doc/help/settings.html#qt.args
# Chromium flags: https://peter.sh/experiments/chromium-command-line-switches/
###

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

c.content.pdfjs = True # enable to see pdf

# WebGL
c.content.webgl = True
# WARNING: Only --use-gl=angle is supported on this platform.
# Vulkanを有効化
c.qt.args = [
    'ignore-gpu-blocklist',
    'enable-gpu-rasterization',
    'enable-unsafe-webgpu',
    'use-gl=angle',
    'use-vulkan',
    'enable-features=Vulkan',
    # Innner HTML
    '--disable-features=TrustedDOMTypes',
]


c.content.tls.certificate_errors = 'block'

c.content.autoplay = True
