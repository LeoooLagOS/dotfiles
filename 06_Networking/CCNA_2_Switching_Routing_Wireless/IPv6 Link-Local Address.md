---
tags:
  - concept
  - networking
  - ipv6
category: <data-structure|cs-fundamental|devops|git>
status: <learning|reviewing|mastered>
related: '"[[<Another Core Concept>]]"'
date: 2025-10-08
---

# IPv6 Link-Local Address

## 📝 One-Sentence Summary
*An IPv6 link-local address is a required, automatically configured IP address that is only used for communication between devices on the same local network link.*

## 💡 Analogy
*A link-local address is like an **internal, unlisted office extension**. It allows you and your officemates on the same floor (the local link) to call each other directly, but the number is meaningless to anyone outside your building (the local network), and the operator (router) won't connect an outside call to it.*

## 🔑 Key Details
- **What it is:** 
	- An IPv6 address that is only valid and usable on a single network segment. 
- **Prefix:** 
	- Always begins with **`FE80::`**. 
- **Configuration:** 
	- It is automatically generated on any interface as soon as IPv6 is enabled on it, even if no other IPv6 address is configured. 
- **Purpose:** 
	- It is essential for several IPv6 functions that happen on the local link, including Neighbor Discovery Protocol (NDP) and the exchange of routing protocol updates between neighboring routers. Routers **will not** forward packets that have a link-local source or destination address.
## 🔗 Connections & Implementations
*You can view a device's link-local address using `show ipv6 interface brief` or `show ipv6 interface`. 
## See Also 
- [[IP Address]] 
- [[ICMPv6]]