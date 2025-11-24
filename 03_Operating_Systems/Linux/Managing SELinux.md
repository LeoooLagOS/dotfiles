---
tags:
  - selinux
  - cli
  - sysadmin
  - linux
  - guide
category: os
status: learning
related: "[[SELinux]]"
date: 2025-11-24
---
# Managing SELinux
## 📝 One-Sentence Summary
*A guide to the command-line tools used to check SELinux status, toggle boolean switches, and manage policy modules.*
## ⚙️ Core Commands
### 1. Status & Modes
* **Check Status:**
    * `getenforce` (Returns: Enforcing, Permissive, or Disabled).
    * `sestatus` (Detailed status view).
* **Enable/Disable (Permanent):**
    1.  Edit `/etc/selinux/config` (or `/etc/sysconfig/selinux`).
    2.  Set `SELINUX=enforcing` (or disabled).
    3.  **Reboot** is required to apply changes.

### 2. Booleans (The Switches)
Booleans allow you to toggle specific features of the policy on/off without writing code.
* **List all Booleans:**
    * `semanage boolean -l | less`
    * *Example Output:* `ftp_home_dir (off, off)`
* **Check specific Boolean:**
    * `getsebool ftpd_anon_write`
* **Change Boolean:**
    * `setsebool ftpd_anon_write on`
    * Use `-P` to make it permanent: `setsebool -P ftpd_anon_write on`

### 3. Policies & Modules
* **List Loaded Modules:**
    * `semodule -l | less`
    * Lists installed policy packages (e.g., `apache`, `ftp`).

## 🔗 Connections & Implementations
* **Troubleshooting:** If a service works in *Permissive* mode but fails in *Enforcing* mode, it is an SELinux issue. Check booleans first.
## See Also
- [[SELinux]]
- [[Vim]]