---
tags:
  - concept
  - hardware
  - networking
  - layer-2
category: computer-hardware
status:
  - learning
related: "[[Router]]"
date: 2025-10-09
---

# Switch

## 📝 One-Sentence Summary
A switch is a [[2_Data Link Layer|Layer 2]] networking device that uses [[MAC Address|MAC addresses]] to intelligently forward data frames only to the specific port of the intended recipient within a local network.

## 💡 Analogy
A switch is like a modern **office mailroom clerk**. The clerk has a directory of which employee sits at which desk. When a letter arrives for "Jane Doe," the clerk delivers it directly to Jane's desk, rather than shouting her name across the entire office like a [[Hub]] would.

## 🔑 Key Details
- **What it is:** 
	- A device that connects multiple devices on a Local Area Network (LAN) to facilitate communication. 
- **Why it exists:** 
	- To dramatically increase the efficiency of a LAN by reducing unnecessary traffic and virtually eliminating collisions. 
- **Core Function:** 
	- It makes forwarding decisions based on the destination [[MAC Address]] in an Ethernet frame. To do this, it builds and maintains a **MAC address table** (also known as a CAM or Content Addressable Memory table) that maps MAC addresses to its physical ports. 
- **Key Characteristics:** 
	- **Breaks up [[Collision Domains]]**: Each port on a switch is its own separate collision domain. This process is called [[Microsegmentation]]. 
- **Forwards Broadcasts**: 
	- By default, all ports on a switch are in the same [[Broadcast Domain]]. It will forward a broadcast frame to all ports (within the same [[VLAN]]).

## 🔗 Connections & Implementations
- Switches are the fundamental building blocks of modern LANs, operating at the [[2_Data Link Layer]]. 
- For communication between different networks (e.g., different VLANs or subnets), a switch must forward traffic to a [[Router]]. 
## See Also 
- [[Router]] 
- [[Hub]] 
- [[MAC Address]] 
- [[VLAN]]