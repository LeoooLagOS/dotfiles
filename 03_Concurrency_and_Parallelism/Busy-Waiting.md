---
tags:
  - concept
  - synchronization
  - OS
category: <cs-fundamental>
status:
  - learning
related: "[[Mutual Exclusion]]"
date: 2025-10-03
---

# Busy-Waiting

## 📝 One-Sentence Summary
**Busy-waiting** is a synchronization technique where a process repeatedly and continuously checks a condition in a loop, actively consuming [[CPU Cycles]] while waiting.
## 💡 Analogy
Imagine you order a pizza and, instead of waiting for them to call you when it's ready, you **call the pizzeria every 30 seconds** to ask, "Is it ready yet?". 
You are constantly "busy" (consuming your time and theirs) instead of waiting passively. That is busy-waiting.
## 🔑 Key Details

- **What it is:** 
	- A method where a process stays in a loop to check a shared variable until it reaches a desired value, which allows it to continue. It is one of the most primitive ways to implement [[Mutual Exclusion]].
    
- **Why it exists:** 
	- It exists as a fundamental mechanism that demonstrates that synchronization is possible using only atomic read/write memory operations. However, it is only used in practice in very specific situations (like low-level systems or for extremely short waits) due to its inefficiency.
    

## 🔗 Connections & Implementations

- **Entry/Exit Protocol:** 
	- In the context of a [[Critical Section]], the busy-wait loop constitutes the **entry protocol**. 
	- Once the process leaves its critical section, it must execute an **exit protocol** to modify the shared variable, allowing another process to enter.
    
- **Inefficiency:** 
	- The main problem is that it wastes processor resources on a loop that produces no useful work. 
	- This can significantly degrade system performance, especially on single-processor systems.

## 👍 Pros & 👎 Cons

- **Pros:**
    
    - Simple to implement with shared variables.
        
    - Can have very low response latency once the condition is met, as the process doesn't need to be "woken up" by the operating system.
        
- **Cons:**
    
    - **Extremely inefficient:** It wastes CPU cycles.
        
    - Prone to subtle implementation errors that can violate mutual exclusion or cause [[Deadlock|deadlocks]].
## See Also

- [[Semaphore]]
    
- [[Monitor]]
    
- [[Critical Section]]