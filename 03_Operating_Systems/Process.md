---
tags:
  - concept
  - OS
  - concurrency
  - execution
  - memory-management
category: os
status: learning
related: "[[Kernel]]"
date: 2025-11-15
---
# Process
## 📝 One-Sentence Summary
*A process is an instance of a computer program that is being executed, containing the program code, its data, and its current state.*
## 💡 Analogy
*A **process** is like a **chef in a kitchen (the OS)**. The chef has their own recipe (the program code), their own set of ingredients (memory/data), and their own counter space (CPU registers/stack). They work independently to prepare their own dish.*
## 🔑 Key Details
- **What it is:** 
	- A process is the fundamental execution environment provided by the operating system. It's a running program isolated from other processes, with its own dedicated memory address space, file handles, and execution state.
- **Why it exists:** 
	- Processes exist to allow the OS to run multiple programs concurrently and safely. This isolation (memory protection) is crucial, as it prevents a crashing program from taking down the entire system or corrupting the data of other programs.
## 🔗 Connections & Implementations
* The [[Kernel]] is the component responsible for creating, scheduling, and terminating processes.
* Each process has at least one [[Thread]] (the main thread) that executes its instructions.
* This note defines the "Process" half of [[Processes vs Threads]].
* The OS's management of multiple processes is a primary example of [[Concurrency vs Parallelism | Concurrency]].
* Processes often need to coordinate access to shared resources using mechanisms like [[Semaphore]] or [[Monitor]] to protect a [[Critical Section]].
## 👍 Pros & 👎 Cons
* **Pros:** 
	* **Isolation.** 
		* A crash in one process (e.g., a web browser tab) doesn't typically affect other processes (like your code editor). This provides high stability and security.
* **Cons:** 
	* **Overhead.** 
		* Creating a new process is "heavy" or "expensive" (slow and resource-intensive) because the OS must allocate a new, separate memory address space. Inter-Process Communication (IPC) is also more complex than communication between threads.
## See Also
- [[Thread]]
- [[Processes vs Threads]]
- [[Kernel]]
- [[Concurrency vs Parallelism]]