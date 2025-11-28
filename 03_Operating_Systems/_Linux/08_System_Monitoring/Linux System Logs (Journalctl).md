---
tags:
  - cli
  - systemd
  - monitoring
  - logs
  - linux
  - tool
category: os
status: learning
related: "[[Systemd Architecture]]"
date: 2025-11-26
---
# Linux System Logs (Journalctl)
## 📝 One-Sentence Summary
*`journalctl` is the command-line utility used to query the centralized, structured, binary logs collected by the `systemd-journald` service.*
## 💡 Analogy
* **Old Logs (`/var/log`):** A **Stack of Notebooks**. To find something, you have to read through them page by page (`grep`). If the ink smudges (corruption), you lose data.
* **Journald:** A **SQL Database**. You don't "read" it linearly; you run queries. "Show me only errors," "Show me logs from yesterday," "Show me logs from the Web Server." It is fast and indexed.
## 🔑 Key Details
- **The Daemon:** `systemd-journald` collects logs from the kernel, boot process, standard output/error of services, and syslog.
- **The Format:** Binary. You cannot read raw journal files with `cat` or `nano`. You *must* use `journalctl`.
- **Volatility:** By default on some distros, the journal is stored in `/run/log/journal` (RAM), meaning it clears on reboot unless configured to persist in `/var/log/journal`.

## ⚙️ Core Commands (The Cheat Sheet)
* **View All (Pager):** `journalctl`
* **Filter by Service (Unit):**
    * `journalctl -u httpd` (Show only Apache logs).
* **Filter by Time:**
    * `journalctl --since "1 hour ago"`
    * `journalctl --since "2023-01-01 12:00:00" --until "2023-01-01 13:00:00"`
* **Filter by Priority (Log Level):**
    * `journalctl -p err` (Show Errors, Criticals, and Alerts).
* **Context & Help:**
    * `journalctl -x` (Adds explanatory text to errors—very useful for beginners).
    * `journalctl -b` (Show logs from the current **Boot** only).
* **Follow (Live Tail):**
    * `journalctl -f` (Watch logs in real-time).

## 🔗 Connections & Implementations
* **Troubleshooting:** The combo `journalctl -u [service] -xe` is the standard "Why did my service fail?" command.
* **Cleaning:** Vacuuming old logs: `journalctl --vacuum-time=2d`.
## See Also
- [[Systemd Architecture]]
- [[Traditional Log Files]]
- [[Linux Kernel Logs]]