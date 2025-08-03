# Linux Device Blocker - CUI Version (Protected Mode)

A productivity-focused system service that automatically manages computer usage time with Pomodoro technique integration, automatic shutdown functionality, and advanced protection against unauthorized termination.

## 🔒 Security Features

- **Signal Blocking**: Intercepts and blocks common termination signals (SIGINT, SIGTERM, SIGHUP, etc.)
- **Auto-Recovery**: Automatically restarts on unexpected errors with `Restart=always`
- **Tamper Detection**: Monitors and logs unauthorized termination attempts
- **Sudo-Only Exit**: Only users with sudo privileges can terminate the service
- **User-Accessible Logging**: Creates `~/.shutdown_cui.log` for regular user monitoring

## 🚀 Core Features

- **Daily Usage Limit**: 5-hour daily computer usage limit
- **Pomodoro Timer**: 50-minute work sessions followed by 20-minute breaks
- **Automatic Shutdown**: System automatically powers off when time limit is reached
- **Notification System**: Desktop notifications + console output + bell sounds
- **Multi-User Support**: Individual services for each system user
- **CUI Interface**: No GUI dependencies, works in any environment
- **System Integration**: Runs as systemd services with automatic startup
- **Real-time Logging**: User-accessible log files for monitoring system activity

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

# View real-time logs (requires sudo)
sudo journalctl -u shutdown-cui-<username>.service -f

# View logs for regular users
# Method 1: Application log file (accessible by user)
tail -f ~/.shutdown_cui.log

# Method 2: View recent application logs
cat ~/.shutdown_cui.log | tail -20

# Method 3: Monitor system messages
dmesg | grep -i shutdown

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

### Protection Mode Settings
The application runs in protected mode by default:
- **Sudo-Only Termination**: Only users with sudo privileges can stop the service
- **Signal Blocking**: Ctrl+C, SIGTERM, SIGHUP, SIGUSR1, SIGUSR2 and other signals are intercepted and blocked
- **Tamper Detection**: Multiple termination attempts trigger security notifications
- **Process Protection**: Service configured with `Restart=always` for automatic recovery
- **User Log Access**: Activity logged to `~/.shutdown_cui.log` for user monitoring

### Log Monitoring
**Real-time log monitoring for regular users:**
```bash
# View current log contents
cat ~/.shutdown_cui.log

# Monitor logs in real-time
tail -f ~/.shutdown_cui.log

# View recent log entries
tail -20 ~/.shutdown_cui.log
```

**Log entries include:**
- Protection mode activation/deactivation
- Unauthorized termination attempts
- Signal reception events
- System errors and recovery actions

**To force stop the application:**
```bash
# Only works with sudo privileges
sudo pkill -f shutdown_cui.py

# Or stop the systemd service
sudo systemctl stop shutdown-cui-<username>.service
```

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
├── setting.sh              # Installation script with protected mode setup
├── shutdown_cui.py          # Main CUI application with protection features
├── block_manager.py         # Time management, Pomodoro logic, and error handling
├── requirements.txt         # Python dependencies (currently empty)
└── README.md               # This documentation file

Generated Files:
├── ~/.shutdown_app_usage.json    # Daily usage time tracking
├── ~/.shutdown_cui.log           # User-accessible activity log
└── /opt/shutdown_cui/            # System installation directory
    ├── shutdown_cui.py           # System copy of main application
    └── block_manager.py          # System copy of manager module

Systemd Services:
└── /etc/systemd/system/
    └── shutdown-cui-<username>.service  # Individual user services
```

## 🔍 Troubleshooting

### Service Not Starting
```bash
# Check service status
sudo systemctl status shutdown-cui-<username>.service

# View detailed logs (requires sudo)
sudo journalctl -u shutdown-cui-<username>.service -n 50

# View user-accessible logs
cat ~/.shutdown_cui.log
tail -f ~/.shutdown_cui.log

# Force restart if needed
sudo systemctl kill --signal=SIGKILL shutdown-cui-<username>.service
sudo systemctl start shutdown-cui-<username>.service
```

### Protection Mode Issues
```bash
# Expected behavior: Regular users cannot terminate
pkill -f shutdown_cui.py
# Should show: "Operation not permitted"

# Proper termination (requires sudo)
sudo pkill -f shutdown_cui.py
sudo systemctl stop shutdown-cui-<username>.service

# Check protection logs
grep "終了リクエスト" ~/.shutdown_cui.log
```

# Real-time log monitoring for regular users
tail -f /var/log/syslog | grep shutdown-cui
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
- **System Suspend**: During breaks, the system automatically suspends until 20 minutes have passed
- **Break Time Management**: Uses protected timestamp file `/tmp/.break_start_time` (read-only for users)
- **Multi-User**: Each user has their own time tracking and service instance
- **Protection Active**: Service cannot be terminated without sudo privileges
- **Log Monitoring**: Check `~/.shutdown_cui.log` for activity monitoring

## ✅ Implementation Status

### Completed Features
- ✅ **GUI to CUI Conversion**: Fully converted from GTK GUI to terminal-based interface
- ✅ **Protection Mode**: Advanced protection against unauthorized termination
- ✅ **Multi-Signal Blocking**: Intercepts SIGINT, SIGTERM, SIGHUP, SIGUSR1, SIGUSR2
- ✅ **User-Accessible Logging**: `~/.shutdown_cui.log` for regular user monitoring
- ✅ **Systemd Integration**: Auto-restart with `Restart=always` configuration
- ✅ **Sudo-Only Termination**: Requires administrative privileges to stop
- ✅ **Pomodoro Timer**: 50-minute work / 20-minute break cycles
- ✅ **Time Tracking**: Daily usage limit with JSON persistence
- ✅ **Notification System**: Desktop notifications + console output + bell sounds
- ✅ **Multi-User Support**: Individual services for each system user

### Security Validation
- ✅ **Protection Test**: `pkill -f shutdown_cui.py` → "Operation not permitted"
- ✅ **Service Resilience**: Automatic restart on unexpected termination
- ✅ **Log Recording**: All security events properly logged
- ✅ **Signal Handling**: Proper sudo privilege checking before termination

## 🤝 Contributing

Feel free to submit issues, feature requests, or pull requests to improve the system.

## 📄 License

This project is open source. Please check the LICENSE file for details.

---

**Note**: This tool is designed to promote healthy computer usage habits. Use responsibly and ensure important work is saved regularly.