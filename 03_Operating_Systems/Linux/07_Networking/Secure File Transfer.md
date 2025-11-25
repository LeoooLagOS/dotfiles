---
tags:
  - tool
  - linux
  - networking
  - storage
  - ssh
category: os
status: learning
related: "[[SSH Basics]]"
date: 2025-11-24
---
# Secure File Transfer (SCP & SFTP)
## 📝 One-Sentence Summary
*SCP and SFTP are protocols that use the encrypted SSH tunnel to transfer files safely between local and remote systems.*
## ⚙️ SCP (Secure Copy)
* **Syntax:** `scp [source] [destination]`
* **Push (Local to Remote):**
    `scp file.txt user@remote:/folder/`
* **Pull (Remote to Local):**
    `scp user@remote:/folder/file.txt .`
* **Server to Server:**
    `scp user@remote1:/file root@remote2:/dest/`

## ⚙️ SFTP (Secure FTP)
* **Differences:** Unlike SCP (which is a simple copy), SFTP is interactive. It supports directory listing, removing files, and resuming transfers.
* **Usage:** `sftp user@remote`

## 🛡️ Locking Users (Chroot SFTP)
To allow a user to transfer files *without* giving them shell access:
1.  **Edit `/etc/ssh/sshd_config`:**
    ```text
    Match User transfer_user
        ForceCommand internal-sftp
        PasswordAuthentication yes
        ChrootDirectory /var/sftp
        PermitTunnel no
        X11Forwarding no
    ```
2.  **Restart:** `systemctl restart sshd`
* **Result:** The user is trapped in `/var/sftp` and can only transfer files.

## See Also
- [[SSH Basics]]
- [[Linux Permissions]]