---
tags:
  - concept
  - linux
  - advanced
  - security
category: os
status: learning
related: "[[Permissions]]"
date: 2025-11-24
---
# Special Permissions (SUID, SGID, Sticky Bit)
## 📝 One-Sentence Summary
*Special permissions allow files to be executed with the privileges of the owner (SUID/SGID) or restrict deletion in shared directories (Sticky Bit).*
## 🔑 The Three Special Bits
In Octal notation, these form a 4th digit placed *before* the standard permissions (e.g., `1777`).

### 1. Sticky Bit (Octal 1000)
* **Symbol:** `t` (at the end: `rwxrwxrw**t**`)
* **Function:** Used on shared directories (like `/tmp`). It ensures that **only the file owner** (or root) can delete a file, even if the directory has 777 permissions.
* **Analogy:** A **Community Bulletin Board**. Everyone can post a flyer, but you can't tear down someone else's flyer—only your own.
* **Command:** `chmod +t /var/tmp` or `chmod 1777 /var/tmp`

### 2. SGID (Set Group ID) (Octal 2000)
* **Symbol:** `s` (in group slot: `rwxr-**s**r-x`)
* **Function:**
    * *On Files:* The program runs with the permissions of the **Group**, not the user running it.
    * *On Folders:* Any new file created inside inherits the **Folder's Group**, not the User's primary group.
* **Command:** `chmod 2555 /shared_folder`

### 3. SUID (Set User ID) (Octal 4000)
* **Symbol:** `s` (in owner slot: `rwx**s**r-xr-x`)
* **Function:** When executed, the program runs with the privileges of the **File Owner** (usually root), not the user running it.
* **Analogy:** **The King's Signet Ring.** Whoever holds the ring (runs the file) speaks with the King's authority temporarily.
* **Example:** The `passwd` command needs SUID to edit `/etc/shadow`.
* **Command:** `chmod 4555 /usr/bin/my_command`

## See Also
- [[Permissions]]
- [[Linux Users and Groups]]