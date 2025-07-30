#!/bin/bash
# File: /opt/uptime-tracker/track_uptime.sh

LOGFILE="/var/log/uptime_today.log"
MAX_SECONDS=$((5 * 60 * 60))  # 5 hours
WARNING_THRESHOLD=$((MAX_SECONDS - 600)) # 10 minutes before shutdown

# Load last total
if [ -f "$LOGFILE" ]; then
    TOTAL=$(cat "$LOGFILE")
else
    TOTAL=0
fi

# Add time since last run
INCREMENT=60  # 1 minute
TOTAL=$((TOTAL + INCREMENT))
echo $TOTAL > "$LOGFILE"

# Warn if close to shutdown
if [ "$TOTAL" -eq "$WARNING_THRESHOLD" ]; then
    export DISPLAY=:0
    export XAUTHORITY=$(ls /run/user/*/gdm/Xauthority 2>/dev/null | head -n1)
    notify-send "Warning" "System will shut down in 10 minutes due to usage limit"
fi

# Shutdown if exceeded
if [ "$TOTAL" -ge "$MAX_SECONDS" ]; then
    shutdown -h now
fi
