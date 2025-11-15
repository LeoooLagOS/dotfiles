---
tags:
  - concept
  - networking
  - routing
  - process
category: networking
status: learning
related: "[[Longest Match Rule]]"
date: 2025-11-07
---
# Packet Forwarding Decision Process

## 📝 One-Sentence Summary
*When a router receives a packet, it applies the [[Longest Match Rule]] to its [[Routing Table]], resulting in one of three possible outcomes: forward to a directly connected network, forward to a next-hop router, or drop the packet.

## 💡 Analogy
*A mail sorter looks up a package's destination address in their map.
1.  **Directly Connected:** "The address is in this building! I'll walk it over to that person directly."
2.  **Next-Hop:** "This address is cross-town. I'll put it on the truck for the 'Downtown' sorting center."
3.  **Drop Packet:** "This address doesn't exist in my map, and there's no 'Head Office' to send it to. I'll throw it in the 'undeliverable' bin."

## 🔑 Key Details
-   **What it is:** 
	- The set of actions a router takes after its routing table lookup is complete.
-   **Why it exists:** 
	- To define the router's behavior for all traffic.

### The Three Outcomes
1.  **Forward to a Directly Connected Network**
    * **When:** The longest match in the routing table is a [[Directly Connected Route]].
    * **Action:** The router forwards the packet directly to the destination device. To do this, it must resolve the destination [[IP Address]] to a [[MAC Address]] using [[ARP|ARP (Address Resolution Protocol)]] or [[ICMPv6]] Neighbor Discovery.

2.  **Forward to a Next-Hop Router**
    * **When:** The longest match in the routing table is a [[Remote Route]] or a [[Default Route]].
    * **Action:** The router forwards the packet to the next-hop router specified in the route entry. It resolves the *next-hop router's* IP address (not the final destination's) to a MAC address using [[ARP|ARP (Address Resolution Protocol)]] or [[ICMPv6]].

3.  **Drop the Packet**
    * **When:** The router has no match in its routing table for the destination network **and** it does not have a [[Default Route]].
    * **Action:** The packet is discarded.

## See Also
-   [[Routing (Packet Forwarding Process)]]
-   [[Longest Match Rule]]
-   [[Directly Connected Route]]
-   [[Remote Route]]
-   [[Default Route]]
-   [[ARP|ARP (Address Resolution Protocol)]]