---
tags:
  - concept
  - OS
category: <cs-fundamental>
status:
  - learning
related: "[[Concurrency vs Parallelism]]"
date: 2025-09-25
---

# Processes vs Threads

## 📝 One-Sentence Summary
*A **process** is an independent program running in its own isolated memory space, while a **thread** is a lightweight path of execution that runs within a process and shares its memory with other threads.*

## 💡 Analogy
*A process is like a standalone restaurant. It has its own building, kitchen, staff, and ingredients (isolated memory and resources). Threads are the individual chefs working in that kitchen. They all share the same kitchen and ingredients (shared memory) but may be working on different dishes (executing different instructions) simultaneously.*

## 🔑 Key Details
-   **What it is:** 
	- **Process:** An instance of a computer program being executed. Each process has its own private virtual address space, containing its code, data, stack, and heap. They are often called **heavyweight processes**
	- **Thread:** The smallest sequence of programmed instructions that can be managed independently by a scheduler. Multiple threads can exist within a single process, sharing the process's resources but maintaining their own program counter, stack, and set of registers. They are known as **lightweight processes**.
-   **Why it exists:** 
	- **Processes** provide isolation. The operating system uses them to run multiple applications without letting them interfere with one another. A crash in one process typically does not affect another.
    - **Threads** exist to enable concurrency _within_ a single application. This allows an application to perform multiple tasks at once (e.g., updating a GUI while saving a file) without the high overhead of creating separate processes.
## 🔗 Connections & Implementations
* **Memory:** Processes are isolated in [[memory]]. Threads within the same process share the code, data, and file resources. This makes communication between threads fast, but also dangerous without proper synchronization.
* **Overhead:** Creating a process and performing a context switch between processes is a slow, resource-intensive operation for the OS. Creating and switching between threads is significantly faster and less costly because fewer resources are involved.

## 👍 Pros & 👎 Cons

- **Processes:**
    
    - **Pros:** High stability and security due to memory isolation.
        
    - **Cons:** High creation and context-switching overhead. Inter-Process Communication (IPC) is complex and slow.
        
- **Threads:**
    
    - **Pros:** Low overhead. Fast context switching. Easy and fast to share data between them.
        
    - **Cons:** Lack of isolation; an error in one thread can crash the entire process. Sharing data requires careful synchronization to prevent data corruption (race conditions).
        

## See Also

- [[Concurrency vs. Parallelism]]
    
- [[Synchronization]]
    
- [[Context Switch]]