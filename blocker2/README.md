# Linux Device Blocker - CUI Version

A productivity-focused system service that automatically manages computer usage time with Pomodoro technique integration and automatic shutdown functionality.

## 🚀 Features

- **Daily Usage Limit**: x-hour daily computer usage limit
- **Pomodoro Timer**: y-minute work sessions followed by z-minute breaks
- **Automatic Shutdown**: System automatically powers off when time limit is reached
- **Notification System**: Desktop notifications + console output + bell sounds
- **Multi-User Support**: Individual services for each system user
- **CUI Interface**: No GUI dependencies, works in any environment
- **System Integration**: Runs as systemd services with automatic startup

## 📋 System Requirements

- Linux with systemd
- Python 3.x
- libnotify-bin (for desktop notifications)
- Root access for installation

## 🛠️ Installation

1. **Clone or download the repository**
   ```bash
   cd /path/to/Linux_device_blocker/blocker2
   ```

2. **Make installation script executable**
   ```bash
   chmod +x setting.sh
   ```

3. **Run installation as root**
   ```bash
   sudo ./setting.sh
   ```

The installation script will:
- Create systemd services for all users
- Install system dependencies
- Copy application files to `/opt/shutdown_cui/`
- Enable and start services automatically

## 📊 Usage

### Service Management

```bash
# Check service status
sudo systemctl status shutdown-cui-<username>.service

# View real-time logs
sudo journalctl -u shutdown-cui-<username>.service -f

# Stop service (if needed)
sudo systemctl stop shutdown-cui-<username>.service

# Start service
sudo systemctl start shutdown-cui-<username>.service

# Disable automatic startup
sudo systemctl disable shutdown-cui-<username>.service
```

### Manual Execution

```bash
# Run manually for testing
python3 shutdown_cui.py

# Run in background
nohup python3 shutdown_cui.py > ~/shutdown_app.log 2>&1 &
```

## ⚡ How It Works

### Time Management
- Tracks daily usage time in `~/.shutdown_app_usage.json`
- Resets automatically at midnight
- Provides real-time countdown display

### Pomodoro Cycle
1. **Work Phase**: 50 minutes of focused work time
2. **Break Phase**: 20 minutes of rest (system suspends automatically)
3. **Repeat**: Cycle continues until daily limit reached

### Notifications
- **Work Start**: "50-minute work session starting"
- **Break Start**: "20-minute break starting" + system suspend
- **2-minute Warning**: "2 minutes remaining. Save your work"
- **Time Up**: Automatic system shutdown

## 🔧 Configuration

### Time Limits
Edit `block_manager.py` to modify time limits:
```python
DAILY_LIMIT_SEC = 300 * 60  # 5 hours in seconds
```

### Pomodoro Timings
Modify work/break durations in `start_combined_loop()` function:
```python
if counter >= 50 * 60:  # Work duration (50 minutes)
if counter >= 20 * 60:  # Break duration (20 minutes)
```

### Notification Settings
Customize notification behavior in `notify()` function:
```python
subprocess.run([
    "notify-send", 
    "--urgency=critical", 
    "--expire-time=5000",  # Display time in milliseconds
    f"{summary}", 
    f"{body}"
])
```

## 📁 File Structure

```
blocker2/
├── setting.sh              # Installation script
├── shutdown_cui.py          # Main CUI application
├── block_manager.py         # Time management and Pomodoro logic
├── requirements.txt         # Python dependencies (currently empty)
└── README.md               # This file
```

## 🔍 Troubleshooting

### Service Not Starting
```bash
# Check service status
sudo systemctl status shutdown-cui-<username>.service

# View detailed logs
sudo journalctl -u shutdown-cui-<username>.service -n 50
```

### Permission Issues
- Ensure `/opt/shutdown_cui/` has correct permissions
- Check that usage file `~/.shutdown_app_usage.json` is writable

### Notification Issues
- Install `libnotify-bin`: `sudo apt install libnotify-bin`
- Check if notification daemon is running in desktop environment

## 🔄 Uninstallation

```bash
# Stop all services
sudo systemctl stop shutdown-cui-*.service

# Disable services
sudo systemctl disable shutdown-cui-*.service

# Remove service files
sudo rm -f /etc/systemd/system/shutdown-cui-*.service

# Remove application directory
sudo rm -rf /opt/shutdown_cui

# Reload systemd
sudo systemctl daemon-reload

# Remove user data (optional)
rm -f ~/.shutdown_app_usage.json
```

## ⚠️ Important Notes

- **Automatic Shutdown**: The system WILL shut down when the time limit is reached
- **Data Safety**: Always save your work when receiving the 2-minute warning
- **System Suspend**: During breaks, the system automatically suspends
- **Multi-User**: Each user has their own time tracking and service instance

## 🤝 Contributing

Feel free to submit issues, feature requests, or pull requests to improve the system.

## 📄 License

This project is open source. Please check the LICENSE file for details.

---

**Note**: This tool is designed to promote healthy computer usage habits. Use responsibly and ensure important work is saved regularly.