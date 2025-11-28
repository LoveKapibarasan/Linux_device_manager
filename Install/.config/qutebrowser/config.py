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
 
c.url.start_pages = [f"file://{home}/.config/qutebrowser/index.html"]

# New Tab
c.url.default_page = f"file://{home}/.config/qutebrowser/index.html"

c.content.pdfjs = True # enable to see pdf

# WebGL
c.content.webgl = True
# WARNING: Only --use-gl=angle is supported on this platform.
# Error: Backend texture is not a Vulkan texture
# Disable or Enable Vulkan
c.qt.args = [
    #'ignore-gpu-blocklist',
    #'enable-gpu-rasterization',
    #'enable-unsafe-webgpu',
    #'use-gl=angle',
    #'use-vulkan',
    #'enable-features=Vulkan',
    # Innner HTML
    #'--disable-features=TrustedDOMTypes',
    ### Audio
    #'--autoplay-policy=no-user-gesture-required',
    #'--disable-features=AudioServiceOutOfProcess',
    #'--disable-features=AudioServiceSandbox',
    #'--enable-features=AudioWorkletRealtimeThread',
    #'--disable-blink-features=BlockCredentialedSubresources',
]


c.content.tls.certificate_errors = 'block'

c.content.autoplay = True
# Search Engine
c.url.searchengines = {"DEFAULT": "http://127.0.0.1:8888/search?q={}"}
