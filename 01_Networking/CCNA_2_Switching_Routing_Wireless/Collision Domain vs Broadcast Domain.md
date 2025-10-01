---
tags:
  - concept
  - networking
  - layer-1
  - layer-2
category: networking
status:
  - learning
related: "[[Switch]]"
date: 2025-09-30
---

# Collision Domain vs Broadcast Domain

## 📝 One-Sentence Summary
*A **collision domain** is a [[1_Physical Layer (OSI Model)|Layer 1]] segment where data packets can collide, a problem solved by **switches**, while a **broadcast domain** is a [[2_Data Link Layer (OSI Model)|Layer 2]] segment where broadcasts propagate, a problem managed by **routers**.*
## 💡 Analogy
*Imagine a large, open office floor.* 
* A **collision domain** is like a single, long conference table. Only one person can talk at a time. If two people talk, their words collide. A **switch** fixes this by giving each person a private phone booth (a separate collision domain). 
* A **broadcast domain** is the entire office floor. If someone shouts a message (a broadcast), everyone on that floor hears it. A **router** acts as a locked door to another floor, stopping the shout from bothering anyone else.
## 🔑 Key Details
- **Collision Domain (Layer 1):** 
	- A section of a network where packet collisions can occur if two devices attempt to transmit at the same time. 
	- All ports on a **hub** are in the same collision domain. 
	- Each port on a **switch** is its own separate collision domain. This is called [[Microsegmentation]] and is why switches virtually eliminate collisions. 
- **Broadcast Domain (Layer 2):** 
	- The area of a network where a broadcast frame will be forwarded. 
	- By default, all ports on a **switch** are in the same broadcast domain. 
	- Each port on a **router** is a separate broadcast domain. Routers do not forward Layer 2 broadcasts from one network to another.
## 🔗 Connections & Implementations
* Switches solve collision domain issues, while [[VLAN|VLANs]] and [[Router|Routers]] are used to segment and reduce the size of broadcast domains.

## See Also
- [[Switch]] 
- [[Router]] 
- [[Hub]]
- [[VLAN]]