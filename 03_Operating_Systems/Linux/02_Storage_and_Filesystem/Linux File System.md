---
tags:
  - concept
  - linux
  - file-system
  - storage
category: os
status: learning
related: "[[Linux Architecture]]"
date: 2025-11-21
---
# Linux File System (FHS)
## 📝 One-Sentence Summary
*The Linux File System is a hierarchical tree structure where everything (files, directories, devices) starts from a single root directory (`/`), governed by the Filesystem Hierarchy Standard (FHS).*
## 💡 Analogy
* **Windows** 
	* is like a **department store** with separate buildings for each department: Building `C:` (System), Building `D:` (Data), Building `E:` (USB).
* **Linux** 
	* is like a **massive tree**. No matter how many branches (drives) you add, they are all grafted onto the one main trunk (Root `/`). You access the new branch by climbing the tree, not by walking to a new building.
## 🔑 Core Philosophy: FHS
The **Filesystem Hierarchy Standard (FHS)** defines the directory structure:
- **`/` (Root):** The starting point of the tree.
- **`/bin` & `/usr/bin`:** Essential user **bin**aries (programs like `ls`, `cp`).
- **`/etc`:** System configuration files (**e**ditable **t**ext **c**onfiguration). "Etcetera."
- **`/home`:** Personal files for users (like `C:\Users`).
- **`/var`:** **Var**iable data (logs, databases, websites).
- **`/dev`:** **Dev**ice files (interfaces for hardware).
- **`/mnt` & `/media`:** Mount points for external drives.
## ⚙️ Linux FS vs Windows FS
| Feature | Windows | Linux |
| :--- | :--- | :--- |
| **Root** | Multiple Roots (`C:\`, `D:\`) | Single Root (`/`) |
| **Separation** | Backslash (`\`) | Forward Slash (`/`) |
| **Case Sensitivity** | No (`File.txt` = `file.txt`) | Yes (`File.txt` != `file.txt`) |
| **Drives** | Drive letters | Mounted directories |
## 🔗 Connections & Implementations
* To modify system settings, you usually edit files in `/etc`.
* To view logs when debugging, you check `/var/log`.
## See Also
- [[Inode]]
- [[Permissions]]