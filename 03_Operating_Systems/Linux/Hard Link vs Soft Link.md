---
tags:
  - concept
  - linux
  - storage
  - file-system
category: os
status: learning
related: "[[Inode]]"
date: 2025-11-21
---
# Hard Link vs Soft Link
## 📝 One-Sentence Summary
*A Hard Link is an additional name pointing to the exact same file data ([[Inode]]), whereas a Soft (Symbolic) Link is a shortcut file that points to another file's path.*
## 💡 Analogy
* **Hard Link:** 
	* Like having **two different keys** for the exact same house. If you lose one key, you can still enter with the other. The house (data) is only gone if you lose *all* keys.
* **Soft Link:** 
	* Like a **sticky note** on a map saying "Go to 123 Main St." If the house at 123 Main St is demolished, the sticky note still exists, but it leads to nowhere (broken link).
## 🔑 Key Details
| Feature | Hard Link | Soft (Symbolic) Link |
| :--- | :--- | :--- |
| **Mechanism** | Points directly to the **Inode**. | Points to the **File Path**. |
| **Command** | `ln target link_name` | `ln -s target link_name` |
| **Cross-Filesystem** | No (Must be on same partition). | Yes (Can link anywhere). |
| **Directories** | Cannot link directories. | Can link directories. |
| **Deletion** | Data remains until *last* link is deleted. | If source is deleted, link breaks. |
## 🔗 Connections & Implementations
* **Hard Links** are used for backups (like Time Machine) to save space—identical files share the same Inode.
* **Soft Links** are used for versioning (e.g., `python` pointing to `python3.9`) or organizing libraries.

## See Also
- [[Inode]]
- [[Linux File System]]