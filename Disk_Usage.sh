#!/bin/bash

send_alert() {
# This function sends alert mail to system admin abt the disk usage of root

    # echo "Warning: Root partition usage is at ${usage}% on $(hostname) as of $(date)" | \
    # mailx -s "ALERT: / usage at ${usage}%" admin@mail.com
	echo -e "Subject: ALERT: / usage at ${usage}%\nTo: admin@mail.com\n\nWarning: Root partition usage is at ${usage}% on $(hostname) as of $(date)" | \
	msmtp admin@mail.com
}

log_file="/var/log/disk_alert.log"
threshold=80
usage=$(df / | tail -1 | awk '{gsub("%",""); print $5}')

alert="NO"
timestamp=$(date '+%Y-%m-%d %H:%M:%S')

if [ "$usage" -ge "$threshold" ]; then
# We are comparing to variables.
    send_alert
    alert="YES"
fi

echo "[$timestamp] Usage: ${usage}% - Alert Sent: $alert" >> "$log_file"
# Logging log file in to file
