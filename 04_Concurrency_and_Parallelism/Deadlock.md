---
tags:
  - failure
  - OS
  - concurrency
  - concept
category: cs-fundamental
status: learning
related: "[[Process]]"
date: 2025-11-27
---
# Deadlock
## 📝 One-Sentence Summary
*Deadlock is a state in which each member of a group is waiting for another member, including itself, to take action, such as sending a message or more commonly releasing a lock.*
## 💡 Analogy
* **Traffic Gridlock:** Four cars arrive at a 4-way stop simultaneously. Traffic rules say "Yield to the car on your right."
    * Car North waits for Car East.
    * Car East waits for Car South.
    * Car South waits for Car West.
    * Car West waits for Car North.
* No one moves. Everyone is waiting for a resource (the intersection) held by the next process.
## 🔑 Key Details
- **The 4 Coffman Conditions:** Deadlock *only* happens if **ALL 4** of these are true simultaneously:
    1.  **Mutual Exclusion:** Resources cannot be shared.
    2.  **Hold and Wait:** A process holding a resource is waiting for another.
    3.  **No Preemption:** Resources cannot be forcibly taken away.
    4.  **Circular Wait:** A closed chain of processes exists, where each waits for the next.
## 🔗 Connections & Implementations
* **OS Handling:** The `[[Kernel]]` usually ignores deadlocks (The Ostrich Algorithm) because detecting them is expensive. It assumes the user will just reboot.
* **Databases:** Often use "Deadlock Detection" (Wait-for graphs) and will kill one transaction to free the others.
## See Also
- [[Race Condition]]
- [[Resource Allocation Graph]]
- [[Starvation]]