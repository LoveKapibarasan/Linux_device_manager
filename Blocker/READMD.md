 
# Block Schedule Daemon

A Linux self-control script that enforces:
- 20-minute blocking periods
- 50-minute work periods
- Complete shutdown between 20:00 and 07:00

## Features

- Remembers shutdown time across reboots
- Shuts down system to enforce breaks
- Runs as a systemd daemon with automatic intervals

## 🛠️ Installation

1. Copy the script:

```bash
sudo cp block_schedule.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/block_schedule.sh
```

2. Create systemd service:

```ini
[Unit]
Description=Blocking Schedule Daemon
After=network.target

[Service]
ExecStart=/usr/local/bin/block_schedule.sh
Type=oneshot
```

Save it as:

```bash
sudo nano /etc/systemd/system/block-schedule.service
```

3. Create systemd timer:

```ini
[Unit]
Description=Run block_schedule.sh every 2 minutes

[Timer]
OnBootSec=1min
OnUnitActiveSec=2min

[Install]
WantedBy=timers.target
```

Save it as:

```bash
sudo nano /etc/systemd/system/block-schedule.timer
```

4. Enable and start the timer:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now block-schedule.timer
```

## 🧪 Verify

Check logs:

```bash
journalctl -u block-schedule.service
cat /var/log/block_schedule.log
```

## 📁 State File

Location: `/var/tmp/block_schedule_state`

Contents:
- `LAST_EVENT_TIME`: Unix timestamp of last event
- `PHASE`: "WORK" or "BLOCK"

## 🔒 Nighttime Shutdown

Automatically shuts down the system during:

- `20:00` to `06:59` daily

This ensures enforced digital rest during nighttime hours.
