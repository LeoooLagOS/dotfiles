---
tags:
  - concept
  - linux
  - memory-management
  - performance
category: os
status: learning
related: "[[Linux Kernel]]"
date: 2025-11-21
---
# Linux Swap
## 📝 One-Sentence Summary
*Swap is a designated space on a [[Storage Devices|hard drive or SSD]] that the Linux Kernel uses as an extension of physical RAM (Virtual Memory) when physical memory is full.*
## 💡 Analogy
*Think of **RAM** as your actual **Desktop workspace**. It's fast, but space is limited.*
*Think of the **Hard Drive** as the **File Cabinet**. It's huge, but slow to retrieve files.*
* **Swap** is the **Overflow Tray** on the corner of your desk. When your desk is full of papers, you move the ones you aren't using right now to the tray (Swap) to make room for active work. It's slower than the desk, but faster than walking to the cabinet.
## 🔑 Key Details
- **What it is:** When RAM is exhausted, the Kernel moves inactive memory pages from RAM to the Swap space (paging out). When that data is needed again, it is moved back to RAM (paging in).
- **Types:**
    1.  **Swap Partition/Volume:** A dedicated section of the disk (or LVM volume).
    2.  **Swap File:** A specific file on an existing filesystem acting as swap.
- **Swappiness:** A kernel parameter (`/proc/sys/vm/swappiness`) ranging from **0 to 100** that controls how aggressive the kernel is about swapping.
    - **High value (e.g., 60-100):** The kernel swaps proactively to keep RAM free for file caching. (Default is usually 60).
    - **Low value (e.g., 0-10):** The kernel tries to avoid swapping as much as possible, only doing it to avoid an Out-Of-Memory (OOM) crash.
## 🔗 Connections & Implementations
* **Checking Swap:** Use `free -h` or `swapon --show` to see current usage.
* **Performance Warning:** Heavy swapping ("thrashing") makes the system extremely slow because disks are much slower than RAM.
## See Also
- [[Managing Swap]]
- [[LVM]]
- [[Linux File System]]