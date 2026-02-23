#!/bin/bash

# ================================
#          SYSWATCH v1.0
#   Linux Health Monitoring Tool
# ================================

VERSION="1.0"
LOG_FILE="/var/log/syswatch.log"
CONFIG_FILE="/etc/syswatch.conf"

# Default Thresholds
DISK_WARN=80
DISK_CRIT=90
MEM_WARN=75
MEM_CRIT=90
CPU_WARN=75
CPU_CRIT=90
ALERT_EMAIL="admin@mail.com"

# Load config if exists
if [ -f "$CONFIG_FILE" ]; then
    source "$CONFIG_FILE"
fi

# ---------- Utility Functions ----------

log_event() {
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $1" >> "$LOG_FILE"
}

send_alert() {
    severity="$1"
    message="$2"

    echo -e "Subject: SYSWATCH [$severity] Alert\nTo: $ALERT_EMAIL\n\n$message" | msmtp "$ALERT_EMAIL"
}

print_banner() {
    echo "====================================="
    echo "        SYSWATCH v$VERSION"
    echo "   Linux Health Monitoring Tool"
    echo "====================================="
}

print_help() {
    echo "Usage: syswatch {disk | memory | cpu | ssh | all | --version }"
}

# ---------- Monitoring Functions ----------

check_disk() {
    print_banner
    echo "Checking Disk Usage..."

    df -h --output=target,pcent | tail -n +2 | while read mount usage; do
        percent=$(echo $usage | tr -d '%')

        if [ "$percent" -ge "$DISK_CRIT" ]; then
            msg="CRITICAL: $mount usage at $percent%"
            echo "$msg"
            log_event "$msg"
            send_alert "CRITICAL" "$msg"
        elif [ "$percent" -ge "$DISK_WARN" ]; then
            msg="WARNING: $mount usage at $percent%"
            echo "$msg"
            log_event "$msg"
            send_alert "WARNING" "$msg"
        else
            echo "$mount OK ($percent%)"
        fi
    done
}

check_memory() {
    print_banner
    echo "Checking Memory Usage..."

    mem_percent=$(free | awk '/Mem:/ {printf("%.0f"), $3/$2 * 100}')

    if [ "$mem_percent" -ge "$MEM_CRIT" ]; then
        msg="CRITICAL: Memory usage at $mem_percent%"
        echo "$msg"
        log_event "$msg"
        send_alert "CRITICAL" "$msg"
    elif [ "$mem_percent" -ge "$MEM_WARN" ]; then
        msg="WARNING: Memory usage at $mem_percent%"
        echo "$msg"
        log_event "$msg"
        send_alert "WARNING" "$msg"
    else
        echo "Memory OK ($mem_percent%)"
    fi
}

check_cpu() {
    print_banner
    echo "Checking CPU Usage..."

    cpu_percent=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' | cut -d'.' -f1)

    if [ "$cpu_percent" -ge "$CPU_CRIT" ]; then
        msg="CRITICAL: CPU usage at $cpu_percent%"
        echo "$msg"
        log_event "$msg"
        send_alert "CRITICAL" "$msg"
    elif [ "$cpu_percent" -ge "$CPU_WARN" ]; then
        msg="WARNING: CPU usage at $cpu_percent%"
        echo "$msg"
        log_event "$msg"
        send_alert "WARNING" "$msg"
    else
        echo "CPU OK ($cpu_percent%)"
    fi
}

check_ssh_logs() {
    print_banner
    echo "Checking Failed SSH Login Attempts..."

    LOG_SOURCE="/var/log/secure"
    if [ -f "/var/log/auth.log" ]; then
        LOG_SOURCE="/var/log/auth.log"
    fi

    failed_attempts=$(grep "Failed password" "$LOG_SOURCE" | wc -l)

    if [ "$failed_attempts" -ge 10 ]; then
        msg="WARNING: $failed_attempts failed SSH login attempts detected"
        echo "$msg"
        log_event "$msg"
        send_alert "WARNING" "$msg"
    else
        echo "SSH Logs OK ($failed_attempts failed attempts)"
    fi
}

check_all() {
    check_disk
    check_memory
    check_cpu
    check_ssh_logs
}

# ---------- Argument Handling ----------

case "$1" in
    disk)
        check_disk
        ;;
    memory)
        check_memory
        ;;
    cpu)
        check_cpu
        ;;
    ssh)
        check_ssh_logs
        ;;
    all)
        check_all
        ;;
    --version)
        echo "SYSWATCH version $VERSION"
        ;;
    --help)
        print_help
        ;;
    *)
        echo "for help use --help"
        ;;
esac
