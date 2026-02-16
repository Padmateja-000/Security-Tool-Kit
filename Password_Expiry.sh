#!/bin/bash

# Task 3: Password Expiry Notification

LOG_FILE="/var/log/password_expiry_notify.log"
THRESHOLD=7

# Make sure log file exists
touch "$LOG_FILE"
chmod 644 "$LOG_FILE"

# Loop through user accounts
for user in $(awk -F: '$3 >= 1000 && $3 < 65534 {print $1}' /etc/passwd); do
    # Get expiry info
    expiry=$(chage -l "$user" | grep "Password expires" | cut -d: -f2 | xargs)

    # Skip users without expiry
    if [[ "$expiry" == "never" || -z "$expiry" ]]; then
        continue
    fi

    # Calculate days left
    expiry_date=$(date -d "$expiry" +%s 2>/dev/null)
    today=$(date +%s)
    days_left=$(( (expiry_date - today) / 86400 ))

    if [[ $days_left -ge 0 && $days_left -le $THRESHOLD ]]; then
        email="${user}@mycomp.com"

        echo "Hi $user, your password will expire in $days_left day(s) on $expiry. Please run 'passwd' to change it." | \
        # mail -s "Your Password is Expiring Soon" "$email"
	echo -e "Subject: Your Password is Expiring Soon\nTo: $email\n\nHi $user, your password will expire in $days_left day(s) on $expiry.\ 	Please run 'passwd' to change it." | msmtp "$email"


        echo "$(date): Notified $user ($email), expires on $expiry" >> "$LOG_FILE"
    fi
done
