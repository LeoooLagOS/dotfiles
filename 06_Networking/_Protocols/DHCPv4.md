---
tags:
  - concept
  - networking
  - protocol
  - layer-7
category: networking
status:
  - learning
related: "[[IP Address]]"
date: 2025-10-06
---

# DHCPv4 (Dynamic Host Configuration Protocol)

## 📝 One-Sentence Summary
*DHCPv4 is a client/server protocol that automates the assignment of [[IP Address|IPv4 addresses]], subnet masks, default gateways, and other network parameters to client devices.

## 💡 Analogy
*Think of a DHCP server as a **restaurant host**. When you (a client device) arrive, you don't pick your own table. The host assigns you a specific table number (IP address) from their list of available tables (address pool) for a set amount of time (the lease). When you leave, the table becomes available for the next guest.*

## 🔑 Key Details
- **What it is:** 
	- A network management protocol used to dynamically assign IP configuration to devices, eliminating the need for manual static IP assignment on every host. 
- **Why it exists:** 
	- To simplify network administration. It ensures that all devices receive a valid and unique IP address, and it allows for the efficient reuse of addresses as devices join and leave the network. 
- **Lease Mechanism:** 
	- A client "leases" an IP address for a limited period. The client must periodically contact the DHCP server to renew the lease. If the lease expires, the server reclaims the IP address and returns it to the pool for reallocation.

## 🔗 Connections & Implementations
* The process of obtaining an IP address lease is known as the [[DHCPv4 DORA Process]]. 
* A Cisco router can be configured to function as a DHCPv4 server. See [[Configuring a Cisco IOS DHCPv4 Server]].

## See Also
- [[DHCPv4 DORA Process]] 
- [[Configuring a Cisco IOS DHCPv4 Server]] 
- [[IP Address]]
- [[Default Gateway]]