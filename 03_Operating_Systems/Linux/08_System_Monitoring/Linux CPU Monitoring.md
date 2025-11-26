---
tags:
  - hardware
  - cpu
  - linux
  - monitoring
  - tool
category: os
status: learning
related: "[[Concurrency vs Parallelism]]"
date: 2025-11-26
---
# Linux CPU Monitoring (lscpu, mpstat)
## 📝 One-Sentence Summary
*Tools to identify the physical geometry of the CPU (`lscpu`) and analyze how efficiently individual cores are being utilized (`mpstat`).*
## ⚙️ Architecture (`lscpu`)
* **Purpose:** Displays CPU details: Architecture (x86_64), Byte Order, CPUs, Threads per core, Sockets, and NUMA nodes.
* **CS Theory Connection:**
    * **Sockets:** Physical chips on the [[Motherboard]].
    * **Cores:** Physical processing units per socket.
    * **Threads:** Logical processing units (Hyper-threading).
    * *Parallelism Potential:* You cannot run more truly **parallel** threads than you have physical/logical cores.

## ⚙️ Usage Statistics (`mpstat`)
*Part of the `sysstat` package.*
* **Command:** `mpstat -P ALL`
* **Purpose:** Displays usage for **each individual core** separately.
* **Why use it:** `top` gives an average. `mpstat` reveals if **Core 0** is at 100% (bottleneck) while **Core 1** is idle.
* **Interpretation:**
    * **%usr:** User-level apps.
    * **%sys:** Kernel activity.
    * **%iowait:** CPU is waiting for Disk I/O (Bad).
    * **%idle:** CPU is doing nothing.

## See Also
- [[Concurrency vs Parallelism]]
- [[Process Monitoring]]