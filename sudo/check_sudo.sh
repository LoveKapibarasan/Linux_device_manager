#!/bin/sh

# Set directory where the scripts live
SCRIPT_DIR="/home/${USER}/Linux_device_manager/sudo"
COMMAND_AFTER="./add_sudo.sh"
COMMAND_BEFORE="./remove_sudo.sh"

# Get current hour (00–23) and minute (00–59)
hour=$(date +%H)
minute=$(date +%M)

# Convert to minutes since midnight
now=$((hour * 60 + minute))

# Define boundaries in minutes
start=$((9 * 60))   # 09:00 = 540
end=$((17 * 60))    # 17:00 = 1020

if [ $now -lt $start ]; then
    echo "Before 09:00 → running <>"
    (cd "$SCRIPT_DIR" && $COMMAND_BEFORE)
elif [ $now -ge $start ] && [ $now -lt $end ]; then
    echo "Between 09:00–17:00 → do nothing"
    :
else
    echo "After 17:00 → running remove_sudo.sh"
    (cd "$SCRIPT_DIR" && $COMMAND_AFTER)
fi

