#!/bin/bash

# ========================
# Blocking Schedule Script
# ========================

STATE_FILE="/var/tmp/block_schedule_state"
LOG_FILE="/var/log/block_schedule.log"
BLOCK_DURATION=1200   # 20 min
WORK_DURATION=3000    # 50 min

log() {
    echo "$(date): $1" | tee -a "$LOG_FILE"
}

# Init state file if not found
if [[ ! -f "$STATE_FILE" ]]; then
    echo "LAST_EVENT_TIME=$(date +%s)" > "$STATE_FILE"
    echo "PHASE=BLOCK" >> "$STATE_FILE"
    log "Initialized new state: BLOCK phase"
fi

# Read state
source "$STATE_FILE"
NOW=$(date +%s)
current_hour=$(date +%H)
ELAPSED=$((NOW - LAST_EVENT_TIME))

# Shutdown at night (20:00–06:59)
if [[ $current_hour -ge 20 || $current_hour -lt 7 ]]; then
    log "Nighttime detected — shutdown"
    echo "LAST_EVENT_TIME=$NOW" > "$STATE_FILE"
    echo "PHASE=BLOCK" >> "$STATE_FILE"
    shutdown now
    exit 0
fi

# PHASE = BLOCK
if [[ "$PHASE" == "BLOCK" ]]; then
    if [[ $ELAPSED -lt $BLOCK_DURATION ]]; then
        REMAIN=$((BLOCK_DURATION - ELAPSED))
        log "BLOCK phase — $REMAIN sec remaining"
        shutdown now
        exit 0
    else
        log "BLOCK over — switching to WORK"
        echo "LAST_EVENT_TIME=$NOW" > "$STATE_FILE"
        echo "PHASE=WORK" >> "$STATE_FILE"
        exit 0
    fi

# PHASE = WORK
else
    if [[ $ELAPSED -lt $WORK_DURATION ]]; then
        REMAIN=$((WORK_DURATION - ELAPSED))
        log "WORK phase — $REMAIN sec remaining"
        exit 0
    else
        log "WORK over — switching to BLOCK and shutting down"
        echo "LAST_EVENT_TIME=$NOW" > "$STATE_FILE"
        echo "PHASE=BLOCK" >> "$STATE_FILE"
        shutdown now
        exit 0
    fi
fi
