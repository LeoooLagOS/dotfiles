---
tags:
  - concept
  - networking
category: networking
status:
  - learning
related: "[[STP]]"
date: 2025-09-30
---

# STP Port Roles

## 📝 One-Sentence Summary
*[[STP|STP]] assigns a specific role—**Root**, **Designated**, or **Alternate**—to every active port on a switch to build a single, loop-free path through the network.*

## 💡 Analogy
*Think of a GPS navigating a road network with loops.* 
* The **Root Port** is the main highway on-ramp that provides the fastest route to the destination city (the [[Root Bridge]]). 
* A **Designated Port** is the "official exit" on a street that directs traffic *away* from the Root Bridge towards other parts of the network. 
* An **Alternate Port** is the emergency detour that is kept closed (`blocking`) to prevent traffic jams but is ready to open if the main highway gets blocked.

## 🔑 Key Details
- **What they are:** Labels assigned to switch ports during the Spanning Tree Algorithm (STA) to determine their state (forwarding or blocking). 
- **Why they exist:** To logically create a single, loop-free path from any point in the network back to the [[Root Bridge]].

### The Roles

| Role                | Function                                                                                                  | State      |
| ------------------- | --------------------------------------------------------------------------------------------------------- | ---------- |
| **Root Port**       | The single, lowest-cost path from a non-root switch to the [[Root Bridge]].                               | Forwarding |
| **Designated Port** | The single, lowest-cost port on a network segment that forwards traffic away from the [[Root Bridge]].    | Forwarding |
| **Alternate Port**  | A port that provides a redundant, backup path toward the [[Root Bridge]] and is blocked to prevent loops. | Blocking   |
## 🔗 Connections & Implementations
The election of these roles is the final step in the [[STP]] algorithm, following the election of the [[Root Bridge]].

## See Also
- [[STP]] 
- [[Root Bridge]] 
- [[STP Path Cost]]