---
tags:
  - concept
  - networking
  - command
  - verification
  - routing
  - Cisco_IOS
  - ccna
category: networking
status:
  - learning
related: "[[IP Address]]"
date: 2025-10-08
---

# Verifying Routes with show ip route

## 📝 One-Sentence Summary
*The `show ip route` command displays the router's IPv4 routing table, which is the "map" it uses to make forwarding decisions for every packet.*

## 💡 Analogy
*The routing table is like a **train station's departure board**. It lists all possible final destinations (networks) and tells the router exactly which track to leave on (exit interface) and the next station to go to (next-hop IP) to get there.*
## 🔑 Key Details
- **What it is:** 
	- A verification command that shows the contents of the routing table stored in RAM. 
- **Why it exists:** 
	- It is the primary tool to verify that a router has learned about local and remote networks and has a path to forward packets to them. 
- **Directly Connected Routes (IOS 15+):** 
	- When an interface is configured and active, two entries appear in the routing table: 
		- **`C` (Connected):** Represents the entire directly connected network (e.g., `192.168.10.0/24`). 
		- **`L` (Local):** Represents the specific IP address on the router's own interface (e.g., `192.168.10.1/32`). This is the router's "local host" address on that network.

## 🔗 Connections & Implementations
*The routing table is populated automatically for networks that are configured on the router's own interfaces ([[Configuring Router Interfaces]]). 
## See Also 
- [[IP Address]] 
- [[Routing]] 
- [[Common Router Verification Commands]]