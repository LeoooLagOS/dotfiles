---
tags:
  - networking
  - concept
category: networking
status:
  - learning
related: "[[Spanning Tree Protocol (STP)]]"
date: 2025-09-23
---

# STP Path Cost

## 📝 One-Sentence Summary
*STP Path Cost is a value assigned to a switch port based on its link speed, used by the Spanning Tree Algorithm to determine the single best path to the [[Root Bridge]].

## 💡 Analogy
*Think of path cost as the **toll on a highway**. A super-fast fiber optic highway (10 Gbps) has a very low toll (cost = 2), while a slower country road (100 Mbps) has a higher toll (cost = 19). STP always chooses the route with the lowest total toll.
## 🔑 Key Details
- **What it is:** 
	- A numerical value representing the "cost" of sending traffic over a port. The cost is inversely proportional to the port's bandwidth. - 10 Gbps = Cost 2 - 1 Gbps = Cost 4 - 100 Mbps = Cost 19 - 10 Mbps = Cost 100 
- **Why it exists:** 
	- To provide a clear metric for the Spanning Tree Algorithm to compare different paths and choose the most efficient one. 
- **Internal Root Path Cost:** 
	- This is the cumulative cost of all the individual port costs along the path from a switch to the [[Root Bridge]].
## 🔗 Connections & Implementations
* The internal root path cost is the primary factor used to elect the [[Root Port]] on a non-root switch. 
* Switches add the ingress port cost to the cost advertised in a received [[BPDU (Bridge Protocol Data Unit)]] to calculate their own total cost to the root.

## See Also
- [[Spanning Tree Protocol (STP)]] 
- [[Root Port]] 
- [[Root Bridge]]