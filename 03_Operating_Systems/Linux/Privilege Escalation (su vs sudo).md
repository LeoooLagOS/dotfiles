---
tags:
  - sudo
  - cli
  - security
  - linux
  - concept
category: os
status: learning
related: "[[User and Group Management]]"
date: 2025-11-24
---
# Privilege Escalation (su vs sudo)
## 📝 One-Sentence Summary
*The distinction between `su` (Switch User), which starts a new shell as another user, and `sudo` (SuperUser Do), which runs a single command with elevated privileges.*
## 💡 Analogy
* **`su` (Switch User):** Like **handing over your keys**. You give someone your keys (password), and they drive your car (account) until they get out.
* **`sudo` (SuperUser Do):** Like **using a VIP pass**. You show *your own* pass (your password) to the bouncer, and he lets you into the VIP area for one specific task.
## 🔑 Key Details
### 1. `su` (Substitute/Switch User)
* **Action:** Switches your active shell to another user's account.
* **Password Required:** The **TARGET** user's password.
* **Common Commands:**
    * `su lagos`: Switch to user 'lagos'.
    * `su - lagos`: Switch to 'lagos' **AND** load their environment variables (like PATH).
    * `su`: Switch to **Root** (requires root password).

### 2. `sudo` (SuperUser DO)
* **Action:** Runs a command with the security privileges of another user (usually root).
* **Password Required:** The **CURRENT** user's password.
* **Common Commands:**
    * `sudo ifconfig`: Run a root-only command.
    * `sudo su`: Switch to root using *your* password (bypassing the need to know the root password).
## 🔗 Connections & Implementations
* **Root Account:** In many modern systems (like Ubuntu), the root account is disabled by default (no password set), so `su` (alone) won't work. You *must* use `sudo su`.
* **Configuration:** Who is allowed to use `sudo` is defined in the `/etc/sudoers` file, edited via `[[Visudo]]`.
## See Also
- [[Visudo]]
- [[Linux Users and Groups]]
- [[User and Group Management]]