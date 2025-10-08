---
tags:
  - overview
  - concept
  - java
  - concurrency
  - parallelism
category: language
status: learning
related: "[[Processes vs Threads]]"
date: 2025-10-06
---
# _Java Threads_

## 📝 One-Sentence Summary
A thread is the fundamental unit of concurrency in Java, representing an independent, lightweight path of execution within a single program and process.
## 💡 Analogy
A single-threaded program is like a **chef working alone** in a kitchen, doing one task at a time. Creating and running a new `Thread` is like **hiring an assistant chef**. You now have a second worker who can perform tasks (like chopping vegetables) at the same time the main chef is doing something else (like taking an order).

## 🔑 Core Philosophy & Design 
Java's philosophy is to abstract away the low-level details of thread management from the programmer. You create concurrent code by defining tasks, and the Java Virtual Machine (JVM) works with the underlying Operating System to manage their execution, automatically leveraging multiple CPU cores for parallelism when available.
## ⚙️ Key Details 
- **What it is:** 
	- An object of the `java.lang.Thread` class that represents a single thread of execution. 
- **Why it exists:** 
	- To enable concurrency *within* a single application, allowing it to perform multiple operations seemingly at once (e.g., updating a GUI while performing a background calculation). 
- **Key Components:** 
	- Each thread maintains its own program counter, stack, and set of registers, but shares the main process's heap memory, code, and file resources with other threads.
## 🔗 Connections & Implementations
- **Creation:** 
	- The two primary methods are [[Creating a Java Thread (extends vs implements)]]. 
- **Execution Model:** 
	- The specifics of how threads run are detailed in [[Concurrency vs Parallelism in Java]]. 
- **Lifecycle:** 
	- A thread progresses through a defined [[Thread Lifecycle (Java)]] (e.g., NEW, RUNNABLE, TERMINATED). 
- **Synchronization:** 
	- Because threads share memory, [[Synchronization in Java]] is crucial to prevent data corruption.

## See Also

- [[Creating a Java Thread]]
- [[_Java]]