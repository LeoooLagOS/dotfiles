---
tags:
  - bash
  - configuration
  - linux
  - concept
category: os
status: learning
related: "[[Shell]]"
date: 2025-11-22
---
# Bash Startup Files
## 📝 One-Sentence Summary
*Bash startup files are specific scripts that run automatically when a shell session starts, used to set up the environment (variables, aliases, prompts).*
## 💡 Analogy
* **Login Shell (`.bash_profile`):** Like **arriving at the office**. You swipe your badge, turn on the lights, and adjust your desk chair. You do this once a day.
* **Non-Login Shell (`.bashrc`):** Like **opening a new folder** on your desk. You don't need to re-swipe your badge; you just need your tools ready.
## 🔑 The Execution Hierarchy
The file loaded depends on how you enter the system:
1.  **Login Shell** (SSH login or GUI login):
    - Looks for `~/.bash_profile`, `~/.bash_login`, or `~/.profile` (in that order).
    - *Purpose:* Set environment variables (like PATH) that should be available to *all* child processes.
2.  **Non-Login Interactive Shell** (Opening a new terminal tab):
    - Reads `~/.bashrc`.
    - *Purpose:* Set aliases, prompt customization (`PS1`), and history settings.
## 🔗 Connections & Implementations
* **Common Practice:** Most `.bash_profile` files contain a command to explicitly load `.bashrc` so that your settings apply everywhere.
* **Global Config:** The system-wide equivalents are in `/etc/profile` and `/etc/bashrc`.
## See Also
- [[Shell]]
- [[Shell Scripting]]