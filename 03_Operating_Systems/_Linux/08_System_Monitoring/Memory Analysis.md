---
tags:
  - monitoring
  - memory
  - performance
  - linux
  - tool
category: os
status: learning
related: "[[Linux Swap]]"
date: 2025-11-26
---
# Memory Analysis (free, vmstat)
## 📝 One-Sentence Summary
*Tools to monitor Random Access Memory (RAM) availability (`free`) and the movement of data between RAM and Swap (`vmstat`).*
## ⚙️ `free`
* **Command:** `free -h` (Human readable: GB/MB).
* **Key Columns:**
    * **Total:** Physical RAM installed.
    * **Available:** The actual amount usable for new apps (includes `buff/cache`).
    * **Swap:** If `Used` Swap is high, the system is struggling.

## ⚙️ `vmstat` (Virtual Memory Statistics)
* **Command:** `vmstat 1` (Update every 1 second).
* **The Bridge:** It links Memory, Disk, and CPU in one line.
* **Key Columns:**
    * **si / so (Swap In / Swap Out):** If these numbers are non-zero, your system is **Thrashing** (moving data to disk because RAM is full). This destroys performance.
    * **bi / bo (Block In / Block Out):** Hard disk read/write intensity.
    * **us / sy / id:** CPU breakdown.

## 🔗 Connections & Implementations
* **OOM Killer:** If `free` hits zero and Swap is full, the Kernel invokes the "Out Of Memory Killer" to sacrifice a process (usually the database or web server) to save the OS.
## See Also
- [[Linux Swap]]
- [[Process Monitoring]]
- [[RAM]]