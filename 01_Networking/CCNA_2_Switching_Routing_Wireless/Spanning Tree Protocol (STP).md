---
tags:
  - concept
  - networking
  - protocol
  - layer-2
category: networking
status:
  - learning
related: "[[Layer 2  Loops]]"
date: 2025-09-23
---

# Spanning Tree Protocol (STP)

## 📝 One-Sentence Summary
*STP (IEEE 802.1D) is a Layer 2 network protocol that prevents [[Layer 2 Loops]] by logically blocking redundant paths in a switched network, ensuring there is only one active path between any two devices at a time.

## 💡 Analogy
*Imagine a city with multiple bridges between its districts, creating circular routes. STP acts as a city planner who closes certain bridges to traffic. While all bridges physically exist (redundancy), traffic is forced to follow a single, non-circular path. If the main bridge closes for repairs, the planner can instantly open one of the closed bridges to redirect traffic, maintaining connectivity without creating a traffic jam.
## 🔑 Key Details
- **What it is:** A loop-prevention protocol that allows for physical redundancy in a network while creating a logically loop-free topology. It was invented by Radia Perlman. 
- **Why it exists:** Unlike [[IPv4]] and [[IPv6]] which have a TTL (Time-to-Live) mechanism to discard looping packets, Layer 2 Ethernet frames have no such mechanism. A [[Layer 2 Loops|Layer 2 loop]] would cause broadcast, multicast, and unknown unicast frames to circulate endlessly, leading to MAC address table instability, link saturation, and a complete network failure. STP solves this problem. 
- **The Algorithm (STA - Spanning Tree Algorithm):** STP uses an algorithm to build a logical  [[Spanning Tree (Graph Theory)|Spanning Tree]], which creates its loop-free topology through a four-step election process. Switches (referred to as "bridges" in the standard) exchange **Bridge Protocol Data Units (BPDUs)** to make these decisions. 
	1. **Elect one Root Bridge:** 
		1. The switch with the lowest **Bridge ID (BID)** becomes the root bridge for the entire STP topology. The BID is a combination of a configurable **Priority** value (default 32768) and the switch's **MAC address**. *The lower the BID, the better.* 
	2. **Elect Root Ports on non-root bridges:** 
		1. Every switch that is *not* the root bridge must select one **Root Port**. This is the port on that switch that has the single lowest-cost path back to the Root Bridge. Cost is determined by the cumulative bandwidth of the links (e.g., 1 Gbps is cheaper than 100 Mbps). 
	3. **Elect Designated Ports on each network segment:** 
		1. On every network segment (the link between two switches), one of the two ports will be elected the **Designated Port**. This is the port on that segment that has the lowest cost path to the Root Bridge. The port on the Root Bridge is *always* a Designated Port. 
	4. **Block all other ports:** 
		1. Any port that is not a Root Port or a Designated Port is put into a blocking state. It is considered an **Alternate** or **Non-Designated Port**. It does not forward frames, but it still listens to BPDUs. If a primary link fails, this port can transition to a forwarding state to restore connectivity.
## 🔗 Connections & Implementations
* STP's entire purpose is to prevent [[Layer 2 Loops]]. 
* Switches use [[BPDU (Bridge Protocol Data Unit)]] frames to exchange information and run the STP algorithm. *The election of the [[Root Bridge]] is the foundational step of the entire process. 
* If a link fails, STP automatically recalculates the topology to unblock a previously blocked port, ensuring network uptime.
## 👍 Pros & 👎 Cons
* **Pro:** A critical and effective protocol for enabling network redundancy at Layer 2 without causing catastrophic loops. It is automatic and self-healing.  
* **Con:** The original 802.1D STP can be slow to converge (30-50 seconds) after a topology change. Newer versions like [[RSTP (Rapid Spanning Tree Protocol)]] and [[MSTP (Multiple Spanning Tree Protocol)]] provide much faster convergence.

## See Also 
- [[Layer 2 Loops]] 
- [[Root Bridge]] 
- [[BPDU (Bridge Protocol Data Unit)]] 
- [[RSTP (Rapid Spanning Tree Protocol)]]