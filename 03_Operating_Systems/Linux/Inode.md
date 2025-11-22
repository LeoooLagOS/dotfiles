---
tags:
  - concept
  - linux
  - storage
  - data-structure
category: os
status: learning
related: "[[Linux File System]]"
date: 2025-11-21
---
# Inode (Index Node)
## 📝 One-Sentence Summary
*An inode is a data structure that stores all the metadata about a file (permissions, owner, size, location on disk) except its name and actual data.*
## 💡 Analogy
*Think of a **Library Card Catalog**:*
* The **Book** is the actual data (content).
* The **Book Title** is the Filename (stored in the directory).
* The **Card** is the **Inode**. It tells you the author, publication date, which shelf it's on (disk block location), and who is allowed to borrow it (permissions).
## 🔑 Key Details
- **What it is:** Every file in Linux is identified by a unique number called the **Inode Number**. The Inode table stores:
    - File type (regular, directory, link)
    - Permissions (Read/Write/Execute)
    - Owner and Group IDs
    - File Size
    - Pointers to data blocks (where the content lives)
- **What it is NOT:** The Inode does **not** store the filename. The filename is stored in the *directory* and points to the Inode number.
## 🔗 Connections & Implementations
* You can run out of disk space even if you have free GBs, if you use up all your Inodes (by creating millions of tiny files).
* Check inode usage with `df -i`.
* This separation of "Name" and "Metadata" allows for [[Hard Link vs Soft Link|Hard Links]].
## See Also
- [[Linux File System]]
- [[Hard Link vs Soft Link]]