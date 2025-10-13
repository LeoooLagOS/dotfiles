---
tags:
  - concept
  - hardware
  - networking
  - layer-3
category: computer-hardware
status:
  - learning
related: "[[Switch]]"
date: 2025-10-09
---

# Router

## 📝 One-Sentence Summary
A router is a [[3_Network Layer|Layer 3]] networking device that connects different networks together and uses [[IP Address|IP addresses]] to make intelligent decisions about the best path to forward packets toward their final destination.

## 💡 Analogy
A router is like the **main sorting center for a city's postal service**. It receives mail from many different neighborhoods (local networks), reads the full street address and zip code (the destination [[IP Address]]), consults its map, and sends the letter on the correct truck (the best route) to get it to the destination city (the destination network).

## 🔑 Key Details
- **What it is:** 
	- A device that directs traffic between different IP networks. 
- **Why it exists:** 
	- To enable communication between logically separate networks. [[Switch|Switches]] handle communication *within* a network; routers handle communication *between* networks. 
- **Core Function:** 
	- It makes forwarding decisions based on the destination [[IP Address]] in a packet. It maintains a **[[Routing Table]]** to determine the best path (the "next hop") to forward a packet to. 
- **Key Characteristics:** 
	- **Breaks up [[Broadcast Domains]]**: Each interface on a router is a separate broadcast domain. 
- **Does not forward broadcasts**: 
	- By default, routers do not pass Layer 2 broadcast frames from one network to another. 
- **Acts as a [[Default Gateway]]**: 
	- For hosts on a LAN, the router's interface is their gateway to all other networks.
## 🔗 Connections & Implementations
- Routers operate at the [[3_Network Layer]] and are what make large, interconnected networks like the Internet possible. 
## See Also 
- [[Switch]] 
- [[IP Address]] 
- [[Routing]] 
- [[Default Gateway]] 
- [[Routing Table]]