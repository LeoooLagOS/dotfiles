---
tags:
  - concept
  - networking
  - routing
category: networking
status: learning
related: "[[Routing Table]]"
date: 2025-11-07
---
# Directly Connected Route

## 📝 One-Sentence Summary
*A directly connected route is an entry in the [[Routing Table]] that is automatically created for the network assigned to one of the router's own active interfaces.

## 💡 Analogy
*This is the **"My Own Street"** entry in the router's GPS. The router automatically knows about the street it's physically located on (the configured network) without needing any special instructions.

## 🔑 Key Details
-   **What it is:** 
	- A network that is configured on an active interface of the router.
-   **Why it exists:** 
	- This is the most basic way a router learns about a network.
-   **Creation:** 
	- A directly connected route is automatically added to the [[Routing Table]] when two conditions are met:
	    1.  The interface is configured with an [[IP Address]] and subnet mask.
	    2.  The interface is active (in an `up, line protocol is up` state).

## 🔗 Connections & Implementations
*When a router's [[Packet Forwarding Decision Process]] matches this route, it forwards the packet directly to the destination device on that network (using [[ARP|ARP (Address Resolution Protocol)]] or [[ICMPv6]]).

## See Also
-   [[Routing Table]]
-   [[Remote Route]]
-   [[Default Route]]
-   [[Configuring Router Interfaces]]