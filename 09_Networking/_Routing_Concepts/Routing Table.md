---
tags:
  - concept
  - networking
  - layer-3
category: networking
status: learning
related: "[[Router]]"
date: 2025-07-11
---
# Routing Table

## 📝 One-Sentence Summary
*A routing table is a data file stored in a [[Router]]'s [[RAM]] that acts as a "map" of the network, listing all known network destinations and the best path to reach them.

## 💡 Analogy
*The routing table is the **GPS navigation database** for a router. It doesn't just store destinations; it stores the specific, turn-by-turn directions (the next-hop or exit interface) for the **best* way to get to each destination.

## 🔑 Key Details
-   **What it is:** 
	- A table of route entries, each consisting of a network prefix (network address) and a prefix length.
-   **Why it exists:** 
	- To provide the router with the necessary information to make its primary decision: where to forward an incoming packet.
-   **How it's built:** A router populates its routing table in three primary ways:
    1.  **[[Directly Connected Route]]:** Automatically added when a router's interface is configured with an [[IP Address]] and is active.
    2.  **[[Remote Route]] (Static):** Manually entered by a network administrator.
    3.  **[[Remote Route]] (Dynamic):** Automatically learned from other routers using dynamic routing protocols like [[OSPF]] or [[EIGRP]].

## See Also
-   [[Directly Connected Route]]
-   [[Remote Route]]
-   [[Default Route]]
-   [[Longest Match Rule]]
-   [[Packet Forwarding Decision Process]]