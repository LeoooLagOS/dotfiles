---
tags:
  - process
  - linux
  - concept
category: os
status: learning
related: "[[Process]]"
date: 2025-11-23
---
# Daemon
## 📝 One-Sentence Summary
*A Daemon is a background process that runs continuously, waiting to handle requests or perform tasks, rather than being under the direct control of an interactive user.*
## 💡 Analogy
* **Interactive Process:** A **Retail Cashier**. They stand there and wait for you to talk to them. You see them work.
* **Daemon:** The **Night Janitor** or the **Hotel Staff**. You usually don't see them. They work in the background to make sure the lights work, the floors are clean, and the doors are locked.
## 🔑 Key Details
- **Naming Convention:** In Linux, daemons typically end with the letter **'d'**.
    - `sshd` (SSH Daemon)
    - `httpd` (HTTP Web Server Daemon)
    - `crond` (Cron Scheduler Daemon)
    - `systemd` (System Daemon)
- **Behavior:** They usually have no controlling terminal (TTY). They start at boot time (via [[Systemctl]]) and run until shutdown.
- **Parent:** Traditionally, daemons were adopted by the `init` process (PID 1) after their parent process exited to detach them from the terminal.
## See Also
- [[Systemctl]]
- [[Process]]
- [[Cron]]