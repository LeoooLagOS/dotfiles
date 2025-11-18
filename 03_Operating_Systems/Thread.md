---
tags:
  - concept
  - OS
  - concurrency
  - execution
  - scheduling
category: os
status: learning
related: "[[Process]]"
date: 2025-11-18
---
# Thread
## 📝 One-Sentence Summary
*A thread is the smallest sequence of programmed instructions that can be managed independently by an operating system scheduler.*
## 💡 Analogy
*If a [[Process]] is a **chef in a kitchen**, then a **thread** is one of the chef's **hands**. The chef (process) has one set of ingredients (shared memory), but each hand (thread) can perform a separate task concurrently (e.g., one hand chops vegetables while the other stirs a pot).*
## 🔑 Key Details
- **What it is:** 
	- A thread is the basic unit of CPU utilization, sometimes called a "lightweight process." It consists of its own program counter, a set of registers, and a stack. However, it **shares** its code section, data section, and other OS resources (like open files) with other threads in the same [[Process]].
- **Why it exists:** 
	- Threads allow a single program to do multiple things at once (concurrency). This is crucial for applications like web servers handling multiple requests, or a text editor that spell-checks as you type. It's far more efficient (faster, less resource-intensive) than creating a whole new process for every small task.
## 🔗 Connections & Implementations
* A [[Process]] is the container; a [[Thread]] is the "thread of execution" *within* that container.
* This note defines the "Thread" half of [[Processes vs Threads]].
* Threads are the entities that the [[Kernel]]'s scheduler actually dispatches to run on CPU cores.
* Because threads in a process share all memory, they must use synchronization primitives like [[Semaphore]] or [[Monitor]] to enforce [[Mutual Exclusion]] when accessing shared data within a [[Critical Section]].
* Using multiple threads is the most common way to achieve [[Concurrency vs Parallelism | Concurrency]] inside a single application.
## 👍 Pros & 👎 Cons
* **Pros:** 
	* **Lightweight.** Much faster to create and switch between than processes.
	* **Efficient Communication.** Threads can share data directly through global variables and memory, which is simple and fast.
* **Cons:** 
	* **No Isolation.** A bug or crash in one thread (e.g., a bad pointer) can corrupt the memory of all other threads in the process, bringing down the entire application. 
	* **Synchronization Overhead.** Shared data access is complex and requires careful management to prevent race conditions.
## See Also
- [[Process]]
- [[Processes vs Threads]]
- [[Kernel]]
- [[Concurrency vs Parallelism]]
- [[Critical Section]]
- [[Semaphore]]