---
tags:
  - concept
  - concurrency
  - parallelism
category: <cs-fundamental>
status:
  - learning
related: "[[Processes vs Threads]]"
date: 2025-09-25
---

# Concurrency vs Parallelism

## 📝 One-Sentence Summary
***Concurrency** is the art of structuring a program to handle multiple tasks that seem to overlap in time, while **parallelism** is the act of physically executing multiple tasks at the exact same instant.*

## 💡 Analogy 
Imagine a kitchen. 
- **Concurrency** is **one chef** making a meal. They put water on to boil (task 1), and while it's heating up, they chop vegetables (task 2). The tasks are interleaved by one resource (the chef). 
- **Parallelism** is **two chefs** making a meal. One boils pasta while the other chops vegetables. Both tasks happen simultaneously, requiring multiple resources (two chefs). 
## 🔑 Key Details 
- **What it is:** 
	- **Concurrency:** A property of a program's **design** where multiple tasks can be in progress over the same period. It is a **logical** concept, often achieved by interleaving execution (context switching). 
	- **Parallelism:** A property of a program's **execution** where multiple tasks are running at the same physical time. It is a **physical** concept that requires multiple processing units. 
- **Why it exists:** 
	- **Concurrency** exists to improve **responsiveness** and resource utilization, especially for I/O-bound tasks. 
	- **Parallelism** exists to increase raw **performance** and computational speed for CPU-bound tasks. 
	
## 🔗 Connections & Implementations 

- Concurrency is typically managed by an Operating System's scheduler (multitasking). 
- Parallelism is enabled by multi-core hardware architectures (multiprocessing). 
## 👍 Pros & 👎 Cons 
- **Concurrency:** 
	- **Pros:** High responsiveness, improved resource utilization. 
	- **Cons:** Introduces complexity (race conditions, deadlocks) requiring synchronization like [[Mutual Exclusion]]. 
- **Parallelism:** 
	- **Pros:** Significant speed-up for divisible problems. 
	- **Cons:** Requires multiple processors; not all problems can be parallelized. 
## See Also 
- [[Processes vs Threads]] 
- [[Mutual Exclusion]] 
- [[Bernstein's Conditions]]