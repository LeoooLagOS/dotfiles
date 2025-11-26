---
tags:
  - io
  - storage
  - monitoring
  - linux
  - tool
category: os
status: learning
related: "[[Linux File System]]"
date: 2025-11-26
---
# Storage and IO Monitoring
## 📝 One-Sentence Summary
*A suite of tools to monitor disk capacity (`df`, `du`), input/output throughput (`iostat`), and open file handles (`lsof`).*
## ⚙️ Capacity (Space)
* **`df` (Disk Free):** Shows available space on mounted **filesystems**.
    * Usage: `df -h`
    * *Analogy:* Checking the fuel gauge.
* **`du` (Disk Usage):** Shows space used by specific **directories**.
    * Usage: `du -sh /var/log` (Summary Human-readable).
    * *Analogy:* Weighing your luggage.

## ⚙️ Throughput (Speed)
* **`iostat`:** Monitors device loading.
    * Usage: `iostat -xz 1`
    * **Key Metric: `%util`**: If this is near 100%, the disk is the bottleneck. The CPU is likely waiting on the disk (`iowait`).

## ⚙️ Handles (Open Files)
* **`lsof` (List Open Files):**
    * **Philosophy:** In Linux, "Everything is a file" (Connections, Libraries, Streams).
    * **Usage:**
        * `lsof -u lagos`: Files opened by user.
        * `lsof -i :80`: Process using Port 80.
        * `lsof /var/log/syslog`: Who is writing to this file?
## See Also
- [[Linux File System]]
- [[Packet Analysis]] (Network sockets are also files in lsof)