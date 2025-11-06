---
tags:
  - concept
  - networking
  - layer-3
category: networking
status: learning
related: "[[Router]]"
date: 2025-11-05
---
# Routing (Packet Forwarding Process)

## 📝 One-Sentence Summary
*Routing is the core process a [[Router]] uses to find the best path for a packet and then forward that packet from one network to another toward its final destination.

## 💡 Analogy
*Imagine you're a mail sorter at a post office ([[Router]]). Your job has two parts: 
1) You look at the destination address on a package, check your large map ([[Routing Table]]) to find the best route, and 
2) you put the package on the correct truck (`forwarding`) to send it to the next city.

## 🔑 Key Details
-   **What it is:** 
	- The process a router performs when it receives a packet on one interface and needs to determine which interface to use to send it out.
-   **Why it exists:** 
	- To move data between different IP networks. Switches handle traffic *within* a network, while routers handle traffic *between* networks.
-   **The Two Primary Functions:**
    1.  **Determine the Best Path:** The router searches its [[Routing Table]] using the packet's destination [[IP Address]]. It uses the [[Longest Match Rule]] to find the most specific and best route.
    2.  **Forward the Packet:** The router encapsulates the packet into a new [[2_Data Link Layer||Layer 2]] frame and sends it out the interface defined by the best route.

## 🔗 Connections & Implementations
*This entire process is the main responsibility of the [[3_Network Layer]].
* The router's [[Routing Table]] is its map, which it populates with [[Directly Connected Route|Directly Connected Routes]], [[Remote Route|Remote Routes]], and potentially a [[Default Route]].

## See Also
-   [[Router]]
-   [[Routing Table]]
-   [[Longest Match Rule]]
-   [[Packet Forwarding Decision Process]]