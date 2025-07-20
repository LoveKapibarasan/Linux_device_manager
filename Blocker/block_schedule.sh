#!/bin/bash

# ========================
# Blocking Schedule Script
# ========================

STATE_FILE="/var/tmp/block_schedule_state"
LOG_FILE="/var/log/block_schedule.log"

# Logging function
log() {
    echo "$(date): $1" | tee -a "$LOG_FILE"
}

# Load block state
if [[ -f "$STATE_FILE" ]]; then
    source "$STATE_FILE"
else
    BLOCK_REMAINING=1200  # Start with 20-minute block (in seconds)
    echo "BLOCK_REMAINING=$BLOCK_REMAINING" > "$STATE_FILE"
    log "Initial block state set: 20 minutes"
fi

# Nighttime enforcement
current_hour=$(date +%H)
if [[ $current_hour -ge 20 || $current_hour -lt 7 ]]; then
    log "Nighttime detected — shutting down immediately"
    shutdown now
    exit 0
fi

# Main loop
while true; do
    current_hour=$(date +%H)

    if [[ $current_hour -ge 20 || $current_hour -lt 7 ]]; then
        log "Nighttime during loop — shutting down"
        shutdown now
        exit 0
    fi

    if [[ $BLOCK_REMAINING -gt 0 ]]; then
        log "Blocking in progress — $BLOCK_REMAINING seconds remaining"
        echo "BLOCK_REMAINING=1200" > "$STATE_FILE"
        log "Shutdown to enforce blocking"
        shutdown now
        exit 0
    else
        log "Unblocked: Starting 50 minutes of work"
        sleep $((50 * 60))  # 50 minutes work time

        BLOCK_REMAINING=1200
        echo "BLOCK_REMAINING=1200" > "$STATE_FILE"
        log "Work period ended — initiating blocking phase"
        shutdown now
        exit 0
    fi
done
