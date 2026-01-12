---
tags: concept
category: OS
status: learning
related: "[[Process State]]"
date: 2026-01-12
---
# Shared Time Systems

## 📝 One-Sentence Summary
A system where a single powerful processor (CPU) handles multiple users/tasks by rapidly switching between them, giving the illusion of simultaneous execution.

## 💡 Analogy
A **Master Chess Player** playing 20 people at once. The master moves from table to table quickly. To each individual player, it feels like they have the master's full attention, but the master is actually dividing their time across 20 separate games.

## 🔑 Key Details
- **What it is:** A multi-programming environment using **Time Slicing** or **Preemptive Scheduling**.
- **Why it exists:** To maximize CPU utilization and allow multiple users to interact with a server concurrently.

## ⚙️ Mechanics
- **Context Switching:** Saving the state of User A to load the state of User B.
- **Quantum:** The specific time interval assigned to each user/process.
- **Complexity:** $O(n)$ where $n$ is the number of active users requiring CPU cycles.

## See Also
[[Concurrency vs Parallelism]]
[[_Operating Systems]]