---
tags:
  - concept
  - linux
  - architecture
  - kernel
  - shell
category: os
status: learning
related: "[[_Linux]]"
date: 2025-11-21
---
# Linux Architecture
## 📝 One-Sentence Summary
*The layered structure of the Linux OS, separating the hardware from user applications through a central kernel and a command interpreter.*
## 💡 Analogy
*Think of Linux like a **restaurant operation**:*
* **Hardware:** The kitchen equipment (stove, fridge).
* **Kernel:** The **Head Chef**. He controls the equipment, manages ingredients (memory), and tells the staff what to do.
* **Shell:** The **Waiter**. He takes orders from the customers (users) and translates them into instructions for the Chef.
* **Applications:** The **Customers** eating and drinking (doing work).
## 🔑 Key Details
- **What it is:** A hierarchical, layered design that isolates the complexity of hardware from the user.
- **The 4 Layers:**
    1.  **Hardware:** The physical devices (CPU, RAM, Disk).
    2.  **[[Linux Kernel|Kernel]]:** The core. It talks directly to hardware and manages resources.
    3.  **[[Shell]]:** The interface (CLI) that wraps around the Kernel, allowing users to send commands (e.g., [[Bash]], [[Zsh]]).
    4.  **Applications/User Space:** The programs the user actually runs (Web Browser, Python scripts, `ls`, `grep`).
## 🔗 Connections & Implementations
* The **User** interacts with the **Application** or **Shell**.
* The **Shell** uses System Calls to talk to the **[[Linux Kernel|Kernel]]**.
* The **Kernel** uses [[Drivers]] to talk to the **Hardware**.
## See Also
- [[_Linux]]
- [[Linux Kernel]]
- [[Shell]]