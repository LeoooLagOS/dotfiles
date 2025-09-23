---
tags:
  - concept
  - networking
category: networking
status:
  - learning
related: "[[Spanning Tree Protocol (STP)]]"
date: 2025-09-23
---

# Root Bridge

## 📝 One-Sentence Summary
*The Root Bridge is the single switch elected by [[Spanning Tree Protocol (STP)]] to act as the central reference point for building a loop-free network topology.
## 💡 Analogy
- **What it is:** 
	- The logical center of the STP topology. It is the switch with the lowest [[Bridge ID (BID)]]. 
- **Why it exists:** 
	- To provide a stable reference point that the Spanning Tree Algorithm (STA) can use for all its path calculations, ensuring all switches agree on the same loop-free topology. 
- **Election Process:** 
	- When switches boot, they all declare themselves the root by sending [[BPDU (Bridge Protocol Data Unit)]] frames. When a switch receives a BPDU with a lower BID than its own, it stops advertising itself as the root and begins forwarding the superior BPDU from the better candidate. This process continues until only the switch with the absolute lowest BID is sending its own BPDUs, and all other switches are forwarding them.

## 🔗 Connections & Implementations
* Once the Root Bridge is elected, the STA then determines the role of all other ports in the network, such as [[Root Port]] and [[Designated Port]]. 
* All ports on a Root Bridge are [[Designated Port]]s and are always in a forwarding state.


## See Also
- [[Bridge ID (BID)]] 
- [[Spanning Tree Protocol (STP)]] 
- [[Root Port]] 
- [[Designated Port]]