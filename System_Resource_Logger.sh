#!/bin/bash

# Task 31: System Resource Spike Logger

LOG_FILE="/var/log/resource_spike.log"
CPU_THRESHOLD=80
MEM_THRESHOLD=75

# Create log file if it doesn't exist
touch "$LOG_FILE"
chmod 644 "$LOG_FILE"

# Get system usage
cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8}' | cut -d. -f1)
mem_usage=$(free | awk '/Mem:/ {printf "%.0f", ($3/$2)*100 }')

timestamp=$(date "+%Y-%m-%d %H:%M:%S")

# Check if either CPU or MEM usage exceeds threshold
if [[ "$cpu_usage" -ge "$CPU_THRESHOLD" || "$mem_usage" -ge "$MEM_THRESHOLD" ]]; then
    echo "$timestamp - High Resource Usage Detected" >> "$LOG_FILE"
    echo "CPU Usage: ${cpu_usage}%" >> "$LOG_FILE"
    echo "Memory Usage: ${mem_usage}%" >> "$LOG_FILE"
    echo "Top 5 Processes by CPU and Memory:" >> "$LOG_FILE"
    echo "-----------------------------------" >> "$LOG_FILE"
    ps -eo pid,comm,%cpu,%mem --sort=-%cpu | head -n 6 >> "$LOG_FILE"
    echo "-----------------------------------" >> "$LOG_FILE"
    echo "" >> "$LOG_FILE"
fi
