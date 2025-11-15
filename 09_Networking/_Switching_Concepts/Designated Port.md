---
tags:
  - concept
  - networking
  - port-role
category: networking
status:
  - learning
related: "[[Root Bridge]]"
date: 2025-09-23
---

# Designated Port

## 📝 One-Sentence Summary
*A Designated Port is the single, forwarding port on any given network segment that has the lowest [[STP Path Cost]] to the [[Root Bridge]].
## 💡 Analogy
*Imagine a single two-way street connecting two neighborhoods. The Designated Port is the **"official exit"** on that street that is marked as the best route towards the city center (the [[Root Bridge]]). All traffic destined for the city center from that street must go through that specific exit.

## 🔑 Key Details
- **What it is:** A specific port role in STP. Every network segment (e.g., the link between two switches) must have exactly one Designated Port. 
- **Why it exists:** To decide which of the two ports on a link will be responsible for forwarding traffic onto that segment. This prevents traffic from being forwarded onto the segment from both ends, which would create a loop. 
- **Election:** The port on the segment with the lower cumulative path cost to the root becomes the Designated Port. All ports on the [[Root Bridge]] itself are automatically Designated Ports. This port is always in a forwarding state.

## 🔗 Connections & Implementations
* A port that is not a [[Root Port]] may become a Designated Port. 
* This role is decided by comparing [[BDPU]]s on a shared link.
## See Also 
- [[STP]] 
- [[Root Bridge]] 
- [[Root Port]]
- [[Alternate Port (Blocked Port)]]