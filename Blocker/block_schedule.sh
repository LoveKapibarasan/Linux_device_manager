#!/bin/bash

# ========================
# Blocking Schedule Script
# ========================

STATE_FILE="/var/tmp/block_schedule_state"
LOG_FILE="/var/log/block_schedule.log"
BLOCK_DURATION=1200   # 20 minutes
WORK_DURATION=3000    # 50 minutes
NOTIFY_BEFORE_SHUTDOWN=180  # 3 minutes

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') — $1" | tee -a "$LOG_FILE"
}

mkdir -p "$(dirname "$LOG_FILE")"

# Initialize state file if not found
if [[ ! -f "$STATE_FILE" ]]; then
    NOW=$(date +%s)
    cat > "$STATE_FILE" <<EOF
LAST_EVENT_TIME=$NOW
PHASE=BLOCK
LAST_SHUTDOWN_TIME=
NOTIFIED=0
EOF
    log "Initialized new state file — entering BLOCK phase"
fi

# Load state
source "$STATE_FILE"
NOW=$(date +%s)
CURRENT_HOUR=$(date +%H)
ELAPSED=$((NOW - LAST_EVENT_TIME))

# Show how long since shutdown if available
if [[ -n "$LAST_SHUTDOWN_TIME" ]]; then
    SHUTDOWN_ELAPSED=$((NOW - LAST_SHUTDOWN_TIME))
    log "Time since last shutdown: $SHUTDOWN_ELAPSED seconds"
fi

# Nighttime shutdown (20:00–06:59)
if [[ $CURRENT_HOUR -ge 20 || $CURRENT_HOUR -lt 7 ]]; then
    log "Nighttime detected — initiating shutdown"
    {
        echo "LAST_EVENT_TIME=$NOW"
        echo "PHASE=BLOCK"
        echo "LAST_SHUTDOWN_TIME=$NOW"
        echo "NOTIFIED=0"
    } > "$STATE_FILE"
    shutdown now
    exit 0
fi

# PHASE: BLOCK
if [[ "$PHASE" == "BLOCK" ]]; then
    if (( ELAPSED < BLOCK_DURATION )); then
        REMAIN=$((BLOCK_DURATION - ELAPSED))

        # Send notification if within 3 minutes and not already notified
        if (( REMAIN <= NOTIFY_BEFORE_SHUTDOWN )) && [[ "$NOTIFIED" == "0" ]]; then
            DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus \
                notify-send "⚠️ System will shut down in $REMAIN seconds!" "Block time is ending soon."

            log "Sent 3-minute shutdown warning (REMAIN=$REMAIN)"

            {
                echo "LAST_EVENT_TIME=$LAST_EVENT_TIME"
                echo "PHASE=BLOCK"
                echo "LAST_SHUTDOWN_TIME=$LAST_SHUTDOWN_TIME"
                echo "NOTIFIED=1"
            } > "$STATE_FILE"
        fi

        log "In BLOCK phase — $REMAIN seconds remaining. Initiating shutdown."
        {
            echo "LAST_EVENT_TIME=$LAST_EVENT_TIME"
            echo "PHASE=BLOCK"
            echo "LAST_SHUTDOWN_TIME=$NOW"
            echo "NOTIFIED=$NOTIFIED"
        } > "$STATE_FILE"
        shutdown now
        exit 0
    else
        log "BLOCK phase complete — switching to WORK"
        {
            echo "LAST_EVENT_TIME=$NOW"
            echo "PHASE=WORK"
            echo "LAST_SHUTDOWN_TIME="
            echo "NOTIFIED=0"
        } > "$STATE_FILE"
        exit 0
    fi

# PHASE: WORK
elif [[ "$PHASE" == "WORK" ]]; then
    if (( ELAPSED < WORK_DURATION )); then
        REMAIN=$((WORK_DURATION - ELAPSED))
        log "In WORK phase — $REMAIN seconds remaining"
        exit 0
    else
        log "WORK phase complete — switching to BLOCK and shutting down"
        {
            echo "LAST_EVENT_TIME=$NOW"
            echo "PHASE=BLOCK"
            echo "LAST_SHUTDOWN_TIME=$NOW"
            echo "NOTIFIED=0"
        } > "$STATE_FILE"
        shutdown now
        exit 0
    fi

# PHASE: Unknown
else
    log "ERROR: Unknown phase '$PHASE'. Resetting to BLOCK."
    {
        echo "LAST_EVENT_TIME=$NOW"
        echo "PHASE=BLOCK"
        echo "LAST_SHUTDOWN_TIME=$NOW"
        echo "NOTIFIED=0"
    } > "$STATE_FILE"
    shutdown now
    exit 1
fi
