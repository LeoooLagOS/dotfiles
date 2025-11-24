---
tags:
  - sysadmin
  - cli
  - systemd
  - linux
  - tool
category: os
status: learning
related: "[[Systemd Architecture]]"
date: 2025-11-23
---
# Systemctl
## 📝 One-Sentence Summary
*Systemctl is the primary command-line utility for inspecting and controlling the systemd system and service manager.*
## 💡 Analogy
*If [[Systemd Architecture|Systemd]] is the **Smart Home Hub**, then **Systemctl** is the **App on your Phone**. You don't rewire the hub directly; you use the App to say "Turn on lights" or "Schedule AC".*
## ⚙️ Core Commands
* **Service State (Immediate):**
    * `start`: Start a service now.
    * `stop`: Stop a service now.
    * `restart`: Stop and then start.
    * `reload`: Reload config without stopping (if supported).
    * `status`: Check if it is running and see recent logs.
* **Service State (Boot / Persistent):**
    * `enable`: Hook the unit into the boot process (start on boot).
    * `disable`: Unhook the unit (do not start on boot).
* **Configuration:**
    * `daemon-reload`: **Crucial.** You must run this whenever you edit a unit file so systemd sees the changes.
## 🔗 Connections & Implementations
* **Syntax:** `systemctl [command] [unit]`
    * *Example:* `sudo systemctl enable --now httpd` (Enables it for boot AND starts it immediately).
* **Troubleshooting:** The output of `systemctl status` usually contains the last few lines of the log, which is the first place to look for errors.
## See Also
- [[Systemd Unit Files]]
- [[Daemon]]