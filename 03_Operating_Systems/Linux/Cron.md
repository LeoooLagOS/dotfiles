---
tags:
  - daemon
  - scheduling
  - automation
  - linux
  - tool
category: os
status: learning
related: "[[Daemon]]"
date: 2025-11-23
---
# Cron (and Crond)
## 📝 One-Sentence Summary
*Cron is a time-based job scheduler daemon (`crond`) that executes commands or scripts automatically at specified intervals defined in configuration files called "crontabs".*
## 🔑 Key Details
- **The Daemon (`crond`):** The background process that wakes up every minute to check if there are any jobs to run. It is typically started from `/etc/init.d` or as a systemd service.
- **Storage Locations:**
    - **`/var/spool/cron`**: Stores per-user crontab files (named after the user, e.g., `/var/spool/cron/lagos`). **Do not edit these directly.**
    - **`/etc/cron.d/`**: Directory for system-wide cron snippets.
    - **`/etc/anacrontab`**: For jobs that run on systems that might be turned off (laptops).
## ⚙️ Core Commands
* **Edit your jobs:** `crontab -e` (Opens the default editor).
* **List your jobs:** `crontab -l`
* **Edit another user's jobs:** `crontab -u username -e` (Requires root).
## 📅 Syntax (The "Star" Notation)
Format: `m h dom mon dow command`

| Field   | Meaning      | Range                  |
| :------ | :----------- | :--------------------- |
| **m**   | Minute       | 0-59                   |
| **h**   | Hour         | 0-23                   |
| **dom** | Day of Month | 1-31                   |
| **mon** | Month        | 1-12                   |
| **dow** | Day of Week  | 0-7 (0 & 7 are Sunday) |

* **Example:** `30 08 * * 1 /home/lagos/backup.sh`
    * *Translation:* "Run backup.sh at 08:30 AM every Monday."
## 🔗 Connections & Implementations
* **Logging:** Cron output is often mailed to the user or logged in `/var/log/cron`.
* **Shortcuts:** `@reboot`, `@daily`, `@hourly` can replace the 5 stars.
## See Also
- [[Systemctl]]
- [[Shell Scripting]]