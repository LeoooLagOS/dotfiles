---
tags:
  - advanced
  - file-system
  - linux
  - security
  - tool
category: os
status: learning
related: "[[Permissions]]"
date: 2025-11-24
---
# File Attributes (Chattr & Lsattr)
## 📝 One-Sentence Summary
*File attributes are a layer of filesystem properties (handled by `chattr`) that override standard permissions, allowing files to be made immutable, append-only, or securely deleted.*
## 💡 Analogy
* **Permissions (`chmod`):** A **"Do Not Touch" sign**. People might ignore it, or the owner can take it down.
* **Attributes (`chattr`):** **Laminating the paper**. No matter who you are (even Root), you cannot write on it until you physically peel off the plastic (unset the attribute).
## 🔑 Key Attributes
* **`i` (Immutable):** The file cannot be modified, deleted, renamed, or linked. Even `root` cannot delete it until the flag is removed.
    * *Use Case:* Protecting critical config files like `/sbin/lilo.conf`.
* **`a` (Append Only):** Data can only be added to the end. Existing data cannot be overwritten or deleted.
    * *Use Case:* Log files.
* **`A` (No Access Time):** The file's "last accessed" timestamp is not updated when read.
    * *Use Case:* Improving performance on files read very frequently.
* **`s` (Secure Deletion):** When deleted, the blocks are zeroed out (wiped) on the disk.

## ⚙️ Core Commands
* **List Attributes:**
    * `lsattr` (Current directory).
    * `lsattr -R` (Recursive).
* **Change Attributes:**
    * `chattr +i file.txt` (Add Immutable flag).
    * `chattr -i file.txt` (Remove Immutable flag).
## See Also
- [[Permissions]]
- [[Linux File System]]