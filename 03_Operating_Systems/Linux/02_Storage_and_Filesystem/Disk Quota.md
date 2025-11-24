---
tags:
  - concept
  - linux
  - storage
  - sysadmin
  - security
category: os
status: learning
related: "[[Linux File System]]"
date: 2025-11-21
---
# Disk Quota
## 📝 One-Sentence Summary
*Disk Quotas are limits set by the system administrator to restrict the amount of disk space or the number of files (inodes) that a specific user or group can consume.*
## 💡 Analogy
*Think of **Disk Quotas** like a **Mobile Data Plan**:*
* **Soft Limit:** You get a text message warning when you reach 90% of your data, but you can still keep using it for a little while (Grace Period).
* **Hard Limit:** The absolute cap. Once you hit 10GB, your data cuts off immediately. No more downloads allowed.
## 🔑 Key Details
- **Why it exists:** In a multi-user system (like a university server), one user shouldn't be able to fill up the entire hard drive with movies, causing the system to crash for everyone else.
- **Types of Limits:**
    1.  **Usage Limit (Block quota):** Limits total size (e.g., 10 GB).
    2.  **File Limit (Inode quota):** Limits number of files (e.g., 10,000 files), regardless of size.
- **The Two Barriers:**
    - **Soft Limit:** A warning threshold. Users can exceed this temporarily for a set "Grace Period" (usually 7 days).
    - **Hard Limit:** The absolute ceiling. The OS blocks any write attempts beyond this point.
## 🔗 Connections & Implementations
* **Enabling:** Quotas are usually enabled in `/etc/fstab` by adding `usrquota` or `grpquota` options to the mount point.
* **Management Commands:**
    - `quotacheck`: Scans disk to calculate current usage.
    - `edquota <user>`: Opens a text editor to set limits for a specific user.
    - `repquota -a`: Prints a summary report of all quotas.
## See Also
- [[Linux File System]]
- [[Inode]]