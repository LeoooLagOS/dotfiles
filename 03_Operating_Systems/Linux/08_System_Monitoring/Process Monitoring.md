---
tags:
  - monitoring
  - process
  - linux
  - cli
  - tool
category: os
status: learning
related: "[[Process]]"
date: 2025-11-26
---
# Process Monitoring (ps, top, kill)
## 📝 One-Sentence Summary
*Tools to view static snapshots (`ps`) or dynamic streams (`top`, `htop`) of running processes, and mechanisms to signal or terminate them (`kill`).*
## 💡 Analogy
* **`ps`:** Like taking a **Photograph** of a highway. You see who is on the road at that exact second, but you can't tell how fast they are moving.
* **`top`/`htop`:** Like a **Traffic Helicopter Video**. You see the cars moving, changing lanes, and speeding up in real-time.
* **`kill`:** Like a **Police Officer** waving a flag to order a driver to pull over (SIGTERM) or forcing them off the road (SIGKILL).
## ⚙️ Viewing Processes
### 1. Static (`ps`)
* **Usage:** `ps aux` (The standard standard).
    * **a:** All users.
    * **u:** User-oriented format (shows CPU/MEM %).
    * **x:** Processes without a terminal ([[Daemon|daemons]]).
* **Connection:** Use `ps` to find the **PID** (Process ID) needed for other commands.

### 2. Dynamic (`top`, `htop`, `btop`)
* **`top`:** The classic. Shows Load Average, CPU %, Memory %.
* **`htop`:** Modern, colorful, supports mouse scrolling. Visualizes cores as bars.
* **`btop`:** The "Gamer" version. Highly graphical, deeply detailed UI in the terminal.
* **CS Theory:** These tools visualize **Context Switching**. If Load Average > Number of Cores, processes are queuing for CPU time ([[Concurrency vs Parallelism|Concurrency]]).

## ⚙️ Controlling Processes (`kill`)
* **Mechanism:** Sends a **Signal** to a PID.
* **Syntax:** `kill [signal] [PID]`
* **Common Signals:**
    * **SIGTERM (-15):** "Please stop." (Default. Allows app to save data).
    * **SIGKILL (-9):** "Die immediately." (Kernel force-quits it. No cleanup).
    * *Example:* `kill -9 1234`
## See Also
- [[Process]]
- [[Thread]]
- [[Linux CPU Monitoring]]