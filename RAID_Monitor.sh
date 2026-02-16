#!/bin/bash

# RAID Device Monitor Script
# Checks RAID status, logs results, and sends alert if degraded or failed arrays found.

# Configurations
ADMIN_EMAIL="admin@example.com"            # Email to send alerts
LOG_FILE="/var/log/raid_monitor.log"       # Log file path
MDADM_CMD="/sbin/mdadm"                     # Path to mdadm command

# Timestamp for logs
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# Function to send alert email
send_alert() {
    local subject="$1"
    local body="$2"
    echo -e "Subject: $subject\nTo: $ADMIN_EMAIL\n\n$body" | msmtp "$ADMIN_EMAIL"
}

# Check if mdadm command exists
if ! command -v $MDADM_CMD &>/dev/null; then
    echo "$TIMESTAMP - ERROR: mdadm command not found at $MDADM_CMD" >> "$LOG_FILE"
    exit 1
fi

# Get RAID status summary
RAID_STATUS=$($MDADM_CMD --detail --scan 2>/dev/null)

if [[ -z "$RAID_STATUS" ]]; then
    echo "$TIMESTAMP - WARNING: No RAID arrays found or unable to scan." >> "$LOG_FILE"
    exit 0
fi

# Check each RAID device status
DEGRADED_DETECTED=0
ALERT_BODY=""

# Extract devices from mdadm --detail --scan output
# Format: ARRAY /dev/mdX metadata=... name=... UUID=...
DEVICES=$(echo "$RAID_STATUS" | awk '{print $2}')

for DEV in $DEVICES; do
    # Get detailed status for the RAID device
    DETAIL=$($MDADM_CMD --detail "$DEV" 2>/dev/null)
    if [[ -z "$DETAIL" ]]; then
        echo "$TIMESTAMP - ERROR: Unable to get details for $DEV" >> "$LOG_FILE"
        continue
    fi
    
    # Look for state info (e.g., "State : clean, degraded, active, failed")
    STATE_LINE=$(echo "$DETAIL" | grep -i 'State :')
    STATE=$(echo "$STATE_LINE" | awk -F':' '{print $2}' | xargs)
    
    # Look for active devices vs total devices
    ACTIVE_LINE=$(echo "$DETAIL" | grep -i 'Active Devices :')
    ACTIVE=$(echo "$ACTIVE_LINE" | awk -F':' '{print $2}' | xargs)
    
    TOTAL_LINE=$(echo "$DETAIL" | grep -i 'Total Devices :')
    TOTAL=$(echo "$TOTAL_LINE" | awk -F':' '{print $2}' | xargs)
    
    # Log the status
    echo "$TIMESTAMP - RAID $DEV state: $STATE (Active: $ACTIVE / Total: $TOTAL)" >> "$LOG_FILE"
    
    # Check for degraded or failed states or if active devices less than total
    if [[ "$STATE" =~ degraded|failed ]] || [[ "$ACTIVE" -lt "$TOTAL" ]]; then
        DEGRADED_DETECTED=1
        ALERT_BODY+="RAID Device: $DEV\nState: $STATE\nActive Devices: $ACTIVE / Total Devices: $TOTAL\n\n"
    fi
done

# Send alert if any degraded arrays detected
if [[ $DEGRADED_DETECTED -eq 1 ]]; then
    SUBJECT="ALERT: RAID Device Degraded or Failed on $(hostname)"
    send_alert "$SUBJECT" "$ALERT_BODY"
    echo "$TIMESTAMP - ALERT SENT: RAID degraded/failure detected." >> "$LOG_FILE"
else
    echo "$TIMESTAMP - All RAID devices healthy." >> "$LOG_FILE"
fi

exit 0
