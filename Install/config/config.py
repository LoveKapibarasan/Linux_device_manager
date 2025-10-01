# Load autoconfig.yml (GUI changes)
config.load_autoconfig()

# Allow full clipboard access on HTTPS pages
config.set("content.javascript.clipboard", "access", "https://*")

c.tabs.show = "never"
