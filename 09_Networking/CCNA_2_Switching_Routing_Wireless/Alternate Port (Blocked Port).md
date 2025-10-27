---
tags:
  - concept
  - networking
  - port-role
category: networking
status:
  - learning
related: "[[Layer 2 Loops]]"
date: 2025-09-23
---

# Alternate Port (Blocked Port)

## 📝 One-Sentence Summary
*An Alternate Port is a switch port that has a redundant path to the [[Root Bridge]] and is therefore put into a logical blocking state by [[STP]] to prevent loops.

## 💡 Analogy
*This is the city's **emergency detour bridge**. It is kept closed to normal traffic to prevent circular routes and traffic jams. However, it's fully maintained and ready to be opened instantly if the main bridge (the [[Root Port]]'s path) fails, ensuring connectivity is restored.
## 🔑 Key Details
- **What it is:** The final port role assigned in STP. Any port that is not elected as a [[Root Port]] or a [[Designated Port]] becomes an Alternate Port. 
- **Why it exists:** 
	- This is the primary loop-prevention mechanism of STP. By blocking redundant paths, STP ensures there is only one logical path between any two points in the network. 
- **State:** The port is in a "blocking" or "discarding" state. It does not forward user data frames and does not learn MAC addresses. However, it still listens to incoming [[BPDU (Bridge Protocol Data Unit)]] frames to monitor the health of the primary paths. If the primary path fails, this port can transition to a forwarding state.

## 🔗 Connections & Implementations
* This port role is the reason [[STP]] can prevent [[Layer 2 Loops]]. 
* It represents a "hot standby" link that can be activated if the primary path (via the [[Root Port]]) goes down.

## See Also
- [[STP]] 
- [[Root Port]]
- [[Designated Port]] 
- [[Layer 2 Loops]]