---
tags:
  - linux
  - monitoring
  - logs
  - file-system
  - concept
category: os
status: learning
related: "[[Linux File System]]"
date: 2025-11-26
---
# Traditional Log Files (/var/log)
## 📝 One-Sentence Summary
*Before systemd, Linux relied on plain-text log files stored in the `/var/log/` directory, managed by the `rsyslog` or `syslog-ng` daemons.*
## 🔑 Key Files Map
Even on modern systemd machines, these files are often still generated for compatibility.
* **`/var/log/messages`** (or `syslog` on Ubuntu): Global system messages. Includes mail, cron, kernel, and auth info. The "Catch-all."
* **`/var/log/secure`** (or `auth.log` on Ubuntu): **Critical Security Log.** Contains authentication attempts (SSH logins, `sudo` usage). Check this for brute-force attacks.
* **`/var/log/cron`**: Logs from the scheduled task daemon (`[[Cron]]`).
* **`/var/log/maillog`**: Logs from the mail server (Postfix/Sendmail).
* **`/var/log/dmesg`**: A text copy of the `[[Kernel Logs]]` boot buffer.

## ⚙️ Log Rotation
Since text files grow forever, a utility called **`logrotate`** runs daily to:
1.  Rename the current file (e.g., `messages` -> `messages.1`).
2.  Compress old files (`messages.2.gz`).
3.  Delete very old files to save disk space.

## 🔗 Connections & Implementations
* **Tools:** Since these are text files, you analyze them using standard tools:
    * `tail -f /var/log/messages` (Watch live).
    * `grep "error" /var/log/syslog`.
    * `less /var/log/secure`.
## See Also
- [[Linux System Logs (Journalctl)]]
- [[Grep]]
- [[File Viewing]]