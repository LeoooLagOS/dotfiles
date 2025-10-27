---
tags:
  - concept
  - java
  - concurrency
  - parallelism
category: language
status:
  - learning
related: "[[Concurrency vs Parallelism]]"
date: 2025-10-06
---

# Concurrency vs Parallelism in Java

## 📝 One-Sentence Summary
In Java, concurrency is the design of a program to handle multiple tasks in overlapping time (via time-slicing), while parallelism is the physical execution of those tasks at the exact same instant on multi-core hardware.

## 💡 Analogy
- **Concurrency** is a single chess master playing 20 games "at once" by moving quickly from board to board. It's an illusion of simultaneity. 
- **Parallelism** is 20 chess masters playing their 20 games at the exact same time. It's true simultaneous execution.
## 🔑 Key Details
### Concurrency: The Illusion of "At Once" 
- **How it works (Single Core):** On a machine with a single CPU core, the JVM's **Thread Scheduler** works with the OS to perform **time-slicing**. It gives a tiny slice of CPU time to Thread A, pauses it, gives the next slice to Thread B, and so on. This happens so fast it appears the threads are running simultaneously. 
- **The Challenge:** The main challenge is [[Synchronization in Java]], ensuring threads that share memory don't corrupt each other's data.
### Parallelism: Truly "At Once" 
- **How it works (Multi-Core):** On a machine with multiple CPU cores, the JVM and OS can assign different threads to different physical cores. If Thread A runs on Core 1 at the same time Thread B runs on Core 2, you have achieved true parallelism. 
- **The Programmer's Role:** You design for concurrency by breaking work into [[_Java Threads|Threads]]. The system (JVM/OS) handles the parallelism for you by mapping those threads to available cores.

## 🔗 Connections & Implementations
- Modern Java simplifies parallelism with high-level APIs: 
- **[[Executor Framework]]:** Manages a pool of threads for you. 
- **[[Parallel Streams]] (Java 8+):** Allows for parallel processing of collections with minimal code changes (e.g., `.parallelStream()`).

## See Also

- [[Creating a Java Thread]]