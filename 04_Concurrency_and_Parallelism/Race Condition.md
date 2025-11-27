---
tags:
  - concept
  - concurrency
  - bug
  - programming
category: cs-fundamental
status: learning
related: "[[Critical Section]]"
date: 2025-11-27
---
# Race Condition
## 📝 One-Sentence Summary
*A race condition is an undesirable situation that occurs when a device or system attempts to perform two or more operations at the same time, but because of the nature of the device or system, the operations must be done in the proper sequence to be done correctly.*
## 💡 Analogy
*Think of a **Shared Bank Account** with \$100.*
* You and your partner try to withdraw \$100 at the **exact same millisecond** from two different ATMs.
* ATM A checks balance: \$100 (Success).
* ATM B checks balance: \$100 (Success).
* Both machines dispense cash.
* The bank has lost \$100 because the "Check" and "Update" steps weren't protected. The race to the database determined the outcome.
## 🔑 Key Details
- **What it is:** A semantic error where the output of a program depends on the sequence or timing of other uncontrollable events (like thread scheduling).
- **The Cause:** Multiple threads accessing a shared resource (memory, file, variable) concurrently, where at least one access is a **write** operation.
- **The Fix:** You must enforce **Atomic Operations** using synchronization mechanisms.
## 🔗 Connections & Implementations
* **Prevention:** This is exactly why we use [[Mutual Exclusion]] and [[Semaphore]].
* **Where it happens:** Inside the [[Critical Section]].
* **Testing:** Extremely hard to debug because they are non-deterministic; the bug might only happen 1 out of 1000 runs.
## 👍 Pros & 👎 Cons
* **Cons:** Causes data corruption, crashes, and security vulnerabilities (TOCTOU attacks).
## See Also
- [[Critical Section]]
- [[Mutual Exclusion]]
- [[Deadlock]]