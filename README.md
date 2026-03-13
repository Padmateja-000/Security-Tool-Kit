# 🖥️ SYSWATCH

**SYSWATCH** is a lightweight **Linux system health monitoring tool written in Bash**.

It monitors **Disk usage, Memory usage, CPU load, and SSH login activity**, logs system events, and sends **email alerts** when system thresholds are exceeded.

This tool is designed for **system administrators, DevOps engineers, and Linux users** who want a simple monitoring solution without heavy software.

---

# ✨ Features

- 📊 Disk Usage Monitoring
- 🧠 Memory Usage Monitoring
- ⚙️ CPU Usage Monitoring
- 🔐 SSH Failed Login Detection
- 📧 Email Alerts using `msmtp`
- 📝 System Event Logging
- ⚡ Lightweight Bash Script
- ⚙️ Configurable Thresholds

---

# 📂 Project Structure

```
syswatch/
│
├── syswatch.sh       # Main monitoring script
├── syswatch.conf     # Optional configuration file
└── README.md         # Project documentation
```

---

# ⚙️ Requirements

SYSWATCH requires the following tools installed on your Linux system:

- Bash
- `df`
- `free`
- `top`
- `grep`
- `awk`
- `msmtp` (for sending email alerts)

Install `msmtp` (Ubuntu/Debian):

```bash
sudo apt install msmtp
```

---

# 🚀 Installation

Clone the repository:

```bash
git clone https://github.com/yourusername/syswatch.git
```

Navigate into the project directory:

```bash
cd syswatch
```

Make the script executable:

```bash
chmod +x syswatch.sh
```

(Optional) Move it to system path:

```bash
sudo mv syswatch.sh /usr/local/bin/syswatch
```

---

# 📋 Usage

### Check Disk Usage

```bash
syswatch disk
```

### Check Memory Usage

```bash
syswatch memory
```

### Check CPU Usage

```bash
syswatch cpu
```

### Check Failed SSH Login Attempts

```bash
syswatch ssh
```

### Run All Checks

```bash
syswatch all
```

### Show Version

```bash
syswatch --version
```

### Help Menu

```bash
syswatch --help
```

---

# ⚙️ Configuration

SYSWATCH supports a configuration file:

```
/etc/syswatch.conf
```

Example configuration:

```bash
DISK_WARN=80
DISK_CRIT=90

MEM_WARN=75
MEM_CRIT=90

CPU_WARN=75
CPU_CRIT=90

ALERT_EMAIL="admin@mail.com"
```

This allows you to **customize thresholds and alert email settings**.

---

# 📝 Logging

All alerts and events are logged to:

```
/var/log/syswatch.log
```

Example log entry:

```
[2026-03-13 10:30:21] WARNING: Memory usage at 82%
```

---

# ⏰ Automation with Cron

You can schedule SYSWATCH to run automatically.

Edit cron jobs:

```bash
crontab -e
```

Example: run every 10 minutes

```
*/10 * * * * /usr/local/bin/syswatch all
```

---

# 📧 Email Alerts

SYSWATCH sends alerts using **msmtp**.

Example alert:

```
Subject: SYSWATCH [CRITICAL] Alert

CRITICAL: CPU usage at 95%
```

Make sure **msmtp is configured correctly** on your system.

---

# 🔒 Security Monitoring

SYSWATCH scans SSH logs for failed login attempts.

Supported log locations:

- `/var/log/auth.log` (Debian / Ubuntu)
- `/var/log/secure` (CentOS / RHEL)

If **10 or more failed attempts** are detected, a warning alert is generated.

---

# 🛠️ Future Improvements

- Slack / Discord alerts
- JSON log output
- Web dashboard
- Docker monitoring
- Network monitoring
- Systemd service integration

---

# 🤝 Contributing

Contributions are welcome!

1. Fork the repository
2. Create a new branch
3. Commit your changes
4. Open a pull request

---

# 📜 License

This project is licensed under the **MIT License**.

---

# 👨‍💻 Author

Developed by **Sangeetham Padma Teja**

GitHub:  
https://github.com/Padmateja-000
