# Daily Uptime Shutdown Tracker for Linux

This system automatically shuts down your Linux PC if daily usage exceeds **4 hours**. It tracks uptime only while the PC is powered on and resets the counter at midnight.

---

## Features

* 🕒 Tracks uptime in 1-minute intervals
* 🔔 Sends a warning 10 minutes before shutdown
* ⏱️ Shuts down the system after 4 hours of daily use
* 🔄 Resets the timer automatically every midnight

---

## Installation Steps

### 1. Copy the script

Save the script to:

```
sudo mkdir -p /opt/uptime-tracker
sudo cp track_uptime.sh /opt/uptime-tracker/track_uptime.sh
```

Make it executable:

```bash

sudo chmod +x /opt/uptime-tracker/track_uptime.sh
```

### 2. Create the systemd service

File: `/etc/systemd/system/uptime-tracker.service`

```ini
[Unit]
Description=Track uptime and shutdown after 4h

[Service]
Type=oneshot
ExecStart=/opt/uptime-tracker/track_uptime.sh
```

### 3. Create the systemd timer

File: `/etc/systemd/system/uptime-tracker.timer`

```ini
[Unit]
Description=Run uptime tracker every minute

[Timer]
OnBootSec=1min
OnUnitActiveSec=1min
Unit=uptime-tracker.service
Persistent=true

[Install]
WantedBy=timers.target
```

Enable and start the timer:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now uptime-tracker.timer
```

### 4. Reset counter daily at midnight

Edit root's crontab:

```bash
sudo crontab -e
```

Add:

```cron
0 0 * * * echo 0 > /var/log/uptime_today.log
```

---

## Notes

* Warning uses `notify-send` and requires desktop session environment (`DISPLAY`, `XAUTHORITY`) to be accessible.
* Shutdown is done via `shutdown -h now`, which requires root permissions.
* Adjust `INCREMENT` and thresholds in the script if needed.

---

## Logs

* Uptime state is saved in:

  ```
  /var/log/uptime_today.log
  ```

---

## Uninstall

```bash
sudo systemctl disable --now uptime-tracker.timer
sudo rm /etc/systemd/system/uptime-tracker.*
sudo rm -rf /opt/uptime-tracker
sudo rm /var/log/uptime_today.log
```
