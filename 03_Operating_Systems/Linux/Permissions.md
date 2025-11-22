---
tags:
  - security
  - file-system
  - concept
  - linux
category: os
status: learning
related: "[[Linux Users and Groups]]"
date: 2025-11-22
---
# Permissions (Chmod & Chown)
## 📝 One-Sentence Summary
*Linux permissions control the ability of the **User (Owner)**, the **Group**, and **Others** to **Read**, **Write**, or **Execute** a specific file or directory.*
## 💡 Analogy
*Think of a **House**:*
* **Owner (u):** You. You can repaint walls, sleep there, enter any room.
* **Group (g):** Family. They can sleep there and enter rooms, but maybe can't repaint walls.
* **Others (o):** The Mailman. He can only stand on the porch (Read/Look), but cannot enter (Execute) or change anything (Write).
## 🔑 The "Octal" Math (rwx)
Permissions are often represented by numbers. You add the values together.
* **r (Read) = 4**
* **w (Write) = 2**
* **x (Execute) = 1**
* **- (No permission) = 0**

| Sum | Permission | Symbol | Meaning |
| :--- | :--- | :--- | :--- |
| **7** | 4+2+1 | `rwx` | Read, Write, Execute (Full Access) |
| **6** | 4+2 | `rw-` | Read & Write (Standard for files) |
| **5** | 4+1 | `r-x` | Read & Execute (Standard for scripts) |
| **4** | 4 | `r--` | Read Only |

## ⚙️ Core Commands
* **`chmod` (Change Mode):** Changes the permissions.
    * *Symbolic:* `chmod u+x script.sh` (Add **eXecute** for **User**).
    * *Octal:* `chmod 755 script.sh` (User=7, Group=5, Others=5).
* **`chown` (Change Owner):** Changes who owns the file.
    * *Format:* `chown user:group file`
    * *Example:* `chown lagos:developers project.py`
## 🔗 Connections & Implementations
* **Directories:** For a directory, "Execute" (`x`) means permission to **enter** (cd into) it. "Read" (`r`) means permission to **list** (`ls`) its contents.
* **View Permissions:** Use `ls -l` to see the string (e.g., `-rwxr-xr--`).
## See Also
- [[Linux Users and Groups]]
- [[Linux File System]]