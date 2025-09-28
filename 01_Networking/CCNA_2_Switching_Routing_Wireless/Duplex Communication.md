---
tags:
  - concept
  - networking
  - layer-1
category: networking
status:
  - learning
related: "[[Collision Domain]]"
date: 2025-09-26
---

# Duplex Communication

## 📝 One-Sentence Summary
*Duplex communication describes the direction of data transmission between two devices, with **full-duplex** allowing simultaneous two-way communication and **half-duplex** allowing only one-way communication at a time.

## 💡 Analogy
*It's the difference between a **telephone call** and a **walkie-talkie**. 
* A telephone call is **full-duplex**; both people can talk and listen at the same time. 
* A walkie-talkie is **half-duplex**; only one person can talk at a time while the other listens, and they must say "over" to signal the channel is free.
## 🔑 Key Details
- **What it is:** A setting that determines how data is transmitted on a network link. 
	- **Full-duplex:** Allows data to be sent and received at the same time. This is the default for modern switches. It requires a dedicated connection between two devices (known as [[Microsegmentation]]) and effectively eliminates collisions. 
	- **Half-duplex:** Allows data to be sent or received, but not simultaneously. This is found in older hardware like hubs and creates performance issues due to collisions. 

- **Why it exists:** The duplex setting must match on both ends of a connection for the link to operate efficiently. A mismatch (e.g., one side full, one side half) is a common cause of network performance problems like excessive collisions and errors.
## 🔗 Connections & Implementations
* In full-duplex mode, the [[Collision Domain]] is eliminated because the collision detection circuit on the network card is disabled. 
* Modern standards like Gigabit Ethernet and 10Gb Ethernet **require** full-duplex operation. *The settings can be configured manually using the [[Configuring Switch Port Speed and Duplex]] commands.

## 👍 Pros & 👎 Cons
* **Full-duplex Pro:** 100% bandwidth efficiency in both directions, no collisions. 
* **Half-duplex Con:** Inefficient use of bandwidth, leads to frequent collisions.

## See Also
- [[Collision Domain]] 
- [[Microsegmentation]] 
- [[Autonegotiation]]