---
tags:
  - security
  - cybersecurity
  - ssh
  - networking
  - linux
  - tool
category: os
status: learning
related: "[[Remote Access Overview]]"
date: 2025-11-24
---
# SSH Basics (Keygen & Auth)
## 📝 One-Sentence Summary
*SSH (Secure Shell) allows for encrypted remote login and command execution, relying on Key-Based Authentication for security rather than simple passwords.*
## 🔑 Key Generation & Permissions
**1. Generate Key Pair:**
```bash
ssh-keygen -t rsa
# Saves to ~/.ssh/id_rsa (Private) and id_rsa.pub (Public)
```
**2. Secure the Keys:**

- **Crucial:** Your private key must be readable _only_ by you.
``` Bash
chmod 600 ~/.ssh/id_rsa
```

**3. Install Public Key:**

- Copy the content of `id_rsa.pub` to the remote server's `~/.ssh/authorized_keys` file.
## ⚙️ Core Command Flags

`ssh [user]@[host] [flags]`

- **`-p <port>`**: Connect to a non-standard port (Default is 22).
    
- **`-i <keyfile>`**: Use a specific identity file (PEM/Key).
    
- **`-v`**: Verbose mode (Debug connection issues).
    
- **`-l <name>`**: Specify login name (alternative to `user@host`).

## 🛡️ Root Access

- **Warning:** Logging in directly as `root` is usually disabled for security.
    
- **Config:** Controlled by `PermitRootLogin` in `/etc/ssh/sshd_config`.
    
- **Fix:** Login as a normal user and use `sudo` or `su`.
## See Also

- [[SSH Advanced]]
    
- [[Privilege Escalation (su vs sudo)]]