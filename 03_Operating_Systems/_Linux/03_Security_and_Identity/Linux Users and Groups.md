---
tags:
  - sysadmin
  - security
  - concept
  - linux
category: os
status: learning
related: "[[Linux File System]]"
date: 2025-11-22
---
# Linux Users and Groups
## 📝 One-Sentence Summary
*Linux is a multi-user system that manages access through unique User IDs (UIDs) and Group IDs (GIDs), storing account details in plain text but keeping passwords encrypted in a restricted file.*
## 💡 Analogy
* **User:** An **Employee** with a specific ID badge.
* **Group:** A **Department** (e.g., "HR", "IT"). If you belong to the "IT" group, you get access to the server room.
* **`/etc/passwd`:** The **Company Directory**. Anyone can pick it up and see who works there and what their office number (UID) is.
* **`/etc/shadow`:** The **Safe**. It contains the actual sensitive data (password hashes) and only the Security Chief (Root) has the key.
## 🔑 Key Files
- **`/etc/passwd`:** Contains user account information. **Readable by everyone.**
    - *Format:* `username:x:UID:GID:Comment:Home_Dir:Shell`
- **`/etc/shadow`:** Contains encrypted passwords and expiry info. **Readable only by root.**
- **`/etc/group`:** Defines the groups and which users belong to them.
## ⚙️ Core Commands
| Command       | Action                     | Example                                      |
| :------------ | :------------------------- | :------------------------------------------- |
| **`useradd`** | Create a new user          | `useradd -m -s /bin/bash lagos`              |
| **`passwd`**  | Set/Change password        | `passwd lagos`                               |
| **`usermod`** | Modify user (add to group) | `usermod -aG sudo lagos` (Add to sudo group) |
| **`userdel`** | Delete user                | `userdel -r lagos` (Remove home dir too)     |
| **`id`**      | Show current user info     | `id`                                         |
## 🔗 Connections & Implementations
* **Root (UID 0):** The superuser. The system administrator with unlimited power.
* **System Users:** Accounts used by services (like `www-data` for web servers) usually have UIDs < 1000 and no login shell (`/bin/false`).
## See Also
- [[Linux Permissions]]
- [[Visudo]]