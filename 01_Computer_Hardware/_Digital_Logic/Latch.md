---
tags:
  - concept
  - hardware
  - sequential-logic
  - memory
category: computer-hardware
status: learning
related: "[[Flip-Flop]]"
date: 2025-12-04
---
# Latch

## 📝 One-Sentence Summary
A Latch is a basic memory element that stores one bit of data and is **level-sensitive**, meaning its output changes immediately whenever its input changes (while it is enabled), rather than waiting for a clock edge.

## 💡 Analogy
*A Latch is like an **unlocked door**. As long as the door is unlocked (Enable = 1), anyone (Data) can walk in or out immediately. When you lock the door (Enable = 0), whoever is inside stays inside, and no new data can enter.*

## 🔑 Key Details
- **What it is:** 
	- A sequential circuit built using feedback loops (usually cross-coupled NAND or NOR [[Logic Gate|gates]]). It is the simplest form of storage.
-  **Why it exists:** 
	- To store a state (0 or 1) indefinitely as long as power is maintained. It allows a circuit to "remember" past inputs.
- **Difference from Flip-Flop:**
    - **Latch:** Transparent. Input flows to output *continuously* while Enable is high.
    - **Flip-Flop:** Synchronous. Input is sampled *only* at the specific moment the clock edge rises or falls.
- **Common Types:**
    - **SR Latch:** Set/Reset. (Basic, but has an invalid state if S=1 and R=1).
    - **D Latch:** Data Latch. Prevents the invalid state. Often called a "Transparent Latch".

## 🔗 Connections & Implementations
- Latches are the building blocks used to construct [[Flip-Flop|Flip-Flops]] (e.g., a Master-Slave Flip-Flop is made of two latches).
- Used in asynchronous circuits where strict clock synchronization is not required.

## 👍 Pros & 👎 Cons
- **Pros:** Faster than flip-flops (no clock edge delay); uses fewer transistors (smaller area).
- **Cons:** "Transparency" can cause timing problems (race conditions) in complex synchronous circuits, making [[Flip-Flop]] preferred for most CPU designs.

## See Also
-   [[Flip-Flop]]
-   [[Register File]]
-   [[_Computer Architecture]]