---
tags:
  - users
  - cli
  - sysadmin
  - linux
  - guide
category: os
status: learning
related: "[[Linux Users and Groups]]"
date: 2025-11-24
---
# User and Group Management
## 📝 One-Sentence Summary
*A practical guide to the command-line tools used to create, modify, delete, and inspect user and group accounts in Linux.*
## 🔑 Account Parameters
Before managing them, understand what defines them:
* **User Parameters:** 
	* Name, Password (hash), **UID** (User ID), **GID** (Group ID), Description (GECOS), Home Directory, Shell, Expiration.
    * *Stored in:* `/etc/passwd`
* **Group Parameters:** 
	* Name, Password (rarely used), **GID**, List of Members.
    * *Stored in:* `/etc/group`

## ⚙️ User Commands
| Command | Action | Example |
| :--- | :--- | :--- |
| **`useradd`** | Create new user | `useradd -d /home/lagos -s /bin/bash lagos` |
| **`userdel`** | Delete user | `userdel -r lagos` (The `-r` flag removes the home directory too). |
| **`usermod`** | Modify user | `usermod -d /home/new_home lagos` (Change home dir). |
| **`passwd`** | Change password | `passwd lagos` (Asks for old, then new password). |
| **`finger`** | Inspect user info | `finger lagos` (Shows shell, home dir, login time). |

## ⚙️ Group Commands
| Command | Action | Example |
| :--- | :--- | :--- |
| **`groupadd`** | Create group | `groupadd developers` |
| **`groupdel`** | Delete group | `groupdel developers` |
| **`groupmod`** | Modify group | `groupmod -n dev_team developers` (Rename group). |
| **`groups`** | List groups | `groups lagos` (See which groups lagos belongs to). |

## 🔗 Connections & Implementations
* **`/etc/group` Syntax:** `group_name:password_placeholder:GID:member1,member2`
    * *Example:* `bin::2:root,bin,daemon`
* **Dependencies:** You generally create the **Group** first if you want to assign a new **User** to it immediately during creation.
## See Also
- [[Linux Users and Groups]]
- [[Privilege Escalation (su vs sudo)]]
- [[Linux Permissions]]