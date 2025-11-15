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

# Root Port

## 📝 One-Sentence Summary
*A Root Port is the single port on a non-root switch that has the lowest cumulative [[STP Path Cost]] back to the [[Root Bridge]].
## 💡 Analogy
*It's the **main highway on-ramp** for your town. Out of all possible roads, this specific on-ramp provides the fastest, cheapest, and most direct route to the capital city (the [[Root Bridge]]).
## 🔑 Key Details
- **What it is:** 
	- A specific port role in STP. Every switch that is *not* the Root Bridge must elect exactly one Root Port. 
- **Why it exists:** 
	- To identify the single best path from every non-root switch towards the root. This is the primary path that the switch will use to forward traffic toward the rest of the network. 
- **Election:** 
	- The switch calculates the internal root path cost out of all its ports. The port that receives the [[BPDU (Bridge Protocol Data Unit)]] that results in the lowest total cost is elected as the Root Port. This port is always placed in a forwarding state.

## 🔗 Connections & Implementations
* The election of the Root Port happens *after* the [[Root Bridge]] has been elected. 
* The primary decision factor is the [[STP Path Cost]].

## See Also
- [[STP]] 
- [[Root Bridge]] 
- [[Designated Port]]
- [[Alternate Port (Blocked Port)]]