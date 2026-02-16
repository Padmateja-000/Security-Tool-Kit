#!/bin/bash

# Script Name : task_6.sh
# Description : Detects repeated failed SSH login attempts.
#               Blocks offending IPs using iptables.
#               Logs actions to /var/log/suspicious_logins.log.


LOG_FILE="/var/log/suspicious_logins.log"
THRESHOLD=5

# Get IPs with failed password attempts more than 5 times
grep "Failed password" /var/log/secure | awk '{print $(NF-3)}' | sort | uniq -c | \
while read count ip; do
    if [ "$count" -gt "$THRESHOLD" ]; then

        # Checking if its already blocked
        if ! iptables -L INPUT -n | grep -q "$ip"; then
            iptables -A INPUT -s "$ip" -j DROP
            echo "[$(date)] Blocked IP: $ip after $count failed login attempts" >> "$LOG_FILE"
        fi

    fi
done














































what is INPUT there?

ChatGPT said:
Great question!

In the command:

bash
Copy
Edit
iptables -L INPUT -n
🔹 What is INPUT?
INPUT is one of the default built-in chains in the Linux iptables firewall system.

🧱 The three main default chains:
Chain	Purpose
INPUT	Handles incoming traffic to the local machine itself (e.g., SSH, HTTP).
OUTPUT	Handles outgoing traffic from the local machine.
FORWARD	Handles traffic passing through the machine (e.g., routing/NAT).

🔍 So in your example:
bash
Copy
Edit
iptables -L INPUT -n
-L INPUT: List the rules in the INPUT chain.

-n: Show IP addresses and ports as numbers (faster, avoids DNS lookups).

This command is checking what rules are applied to incoming packets to the system — for example, SSH login attempts, pings, web server connections, etc.

✅ Example scenario:
Let’s say your machine runs an SSH server, and someone tries to brute-force login.

Their packets go through the INPUT chain.

You can use iptables rules to:

Allow specific IPs (ACCEPT)

Drop unwanted connections (DROP)

Log suspicious traffic (LOG)

🔒 In your script:
bash
Copy
Edit
iptables -A INPUT -s "$ip" -j DROP
You're saying:
🚫 Drop any incoming packets from this IP ($ip), because it triggered too many failed logins.

If you want, I can show you what the full set of default chains looks like, or how to list your current rules in a cleaner way.



You said:
then thing i dont exactly understand what it exactly is?

ChatGPT said:
Totally fair — the term INPUT in iptables can seem abstract at first. Let’s get very clear on it:

🧩 What is INPUT, exactly?
In iptables, INPUT is a chain (i.e. a list of rules) that governs what happens to incoming network traffic that is destined for your system itself.

In other words:

🔁 INPUT = What to do with traffic coming into your system.

This means packets that:

Are headed to your machine (not through it),

Target a local service like SSH, HTTP, etc.

🔍 Think of it this way:
Your system can see 3 kinds of traffic:

Type of Traffic	Goes Through Chain
Incoming to your system (e.g., SSH to your server)	INPUT
Outgoing from your system (e.g., curl google.com)	OUTPUT
Routed through your system (e.g., if it's a router)	FORWARD

🧠 So when does a packet go to the INPUT chain?
Only when:

It's addressed to your machine, and

It's coming from outside.

✅ Examples:

Someone SSHs into your server → goes through INPUT

Someone visits your local web server (port 80/443) → goes through INPUT

Someone pings your IP → goes through INPUT

❌ Not examples:

Your system initiates an outbound connection → OUTPUT

Your machine is forwarding packets for others (router role) → FORWARD

💡 How it's used in firewalls:
When someone writes:

bash
Copy
Edit
iptables -A INPUT -s 192.168.1.50 -j DROP
They're saying:

"If a packet comes from IP 192.168.1.50 into my system, then drop it."

This effectively blocks access to your system from that IP.

🎨 Visual analogy:
Imagine your Linux system as a house:

INPUT = people coming to your front door

OUTPUT = you sending letters out

FORWARD = people cutting through your backyard (router mode)

INPUT decides who gets to talk to your house at all.

Would you like a visual diagram to see the flow of packets through these chains?