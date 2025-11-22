---
tags:
  - concept
  - OS
  - process
  - scheduling
  - execution
category: os
status: learning
related: "[[Process]]"
date: 2025-11-18
---
# Process State
## 📝 One-Sentence Summary
*A process state is a label (like "running" or "waiting") that defines the current activity of a process, which the OS uses to manage execution and resource allocation.*
## 💡 Analogy
*Think of processes as **customers at a busy restaurant**.
- **New (Created):** The customer has just walked in the door.
- **Ready:** The customer is at the host stand, waiting to be seated. They are *able* to be seated, but no table is free.
- **Running:** The customer is seated at a table (the CPU) and is actively ordering/eating.
- **Waiting (Blocked):** The customer has finished eating and is now waiting for the check to arrive (waiting for an I/O event, like a file read). They *cannot* move on, even if a new table (CPU) opened up.
- **Terminated:** The customer has paid and left the restaurant.
## 🔑 Key Details
- **What it is:** A process state is one of several distinct states that a process can be in at any given time. The operating system's `[[Kernel]]` maintains a record of each process's state, typically in a data structure called a Process Control Block (PCB).
- **Why it exists:** Process states are essential for multitasking and resource management. They allow the OS scheduler to know which processes are eligible to run on the CPU (the **ready** queue) and which are stuck waiting for an external event (the **waiting** queue), ensuring the CPU is never idle if there is work to be done.

## 🔗 Connections & Implementations
* A `[[Process]]` is the entity that *has* a state.
* The **Process Control Block (PCB)** is the data structure where the OS stores the state, along with the program counter, registers, and memory limits.
* The **Scheduler** (part of the `[[Kernel]]`'s `[[CPU Scheduling]]` logic) is the component that *changes* a process's state (e.g., from "ready" to "running" or "running" to "waiting").
* A process in the **running** state is actively executing instructions, possibly inside a `[[Critical Section]]`.
* A process moves to the **waiting** state when it needs to perform I/O or wait on a `[[Semaphore]]`.
## 👍 Pros & 👎 Cons
* **Pros:** **Efficiency.** The state model allows the OS to make intelligent decisions, maximizing CPU utilization by never scheduling a process that is "waiting" for an external event.
* **Cons:** **Overhead.** Every time a process changes state (a "context switch"), the OS must do work: saving the old state and loading the new one. This is pure overhead and takes CPU time away from user applications.
## See Also
- `[[Process]]`
- `[[CPU Scheduling]]`
- `[[Context Switch]]`
- `[[Process Control Block (PCB)]]`