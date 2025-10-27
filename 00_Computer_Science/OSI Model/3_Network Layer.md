---
tags:
  - concept
  - cs-fundamental
  - networking
  - osi-model
category: networking
status:
  - learning
related: "[[2_Data Link Layer]]"
date: 2025-10-09
---

# 3_Network Layer

## 📝 One-Sentence Summary
The Network Layer (Layer 3) is responsible for providing logical addressing, path determination, and forwarding packets from a source host on one network to a destination host on a different network.

## 💡 Analogy
The Network Layer is like the **global postal service's addressing system**. It's responsible for the full "To" and "From" addresses on an envelope ([[IP Address|IP addresses]]) that are unique across the world, and for figuring out the best route for the letter to travel from city to city ([[Routing]]).

## 🔑 Key Details
- **Layer:** 3 of the [[_OSI Model]]. 
- **PDU (Protocol Data Unit):** **Packet** 
- **Primary Functions:** 
	- **Logical Addressing:** 
		- Assigns a unique, hierarchical address (e.g., [[IPv4]] or [[IPv6]]) to each device on the network. 
	- **Path Determination ([[Routing]]):** 
		- Determines the best path for a packet to take to reach its destination network by consulting a routing table. 
	- **Forwarding:** 
		- The process of moving packets from an incoming interface to an outgoing interface. 
	- **Key Devices:** 
		- The primary device that operates at this layer is the [[Router]].
## 🔗 Connections & Implementations
- The Network Layer receives segments from the [[4_Transport Layer]] and **encapsulates** them into packets. It then hands these packets down to the [[2_Data Link Layer]] to be **encapsulated** into frames for local delivery. 
- **Key Protocols:** [[IP]] (Internet Protocol), [[ICMP]] (Internet Control Message Protocol), and routing protocols like [[OSPF]] and [[EIGRP]]. 
## See Also 
- [[_OSI Model]] 
- [[Router]] 
- [[IP Address]] 
- [[Routing]]