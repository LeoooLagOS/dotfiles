---
tags:
  - concept
  - networking
  - vlan
  - routing
category: networking
status: learning
related: "[[VLAN]]"
date: 2025-11-11
---
# Router-on-a-Stick

## 📝 One-Sentence Summary
*A "Router-on-a-Stick" is an inter-VLAN routing method where a single physical interface on a [[Router]] routes traffic between multiple [[VLAN|VLANs]] by using virtual subinterfaces, one for each VLAN.

## 💡 Analogy
*Imagine a single mailroom (`Router`) that serves an entire apartment building. The mailroom has one physical door (the router's physical interface). Inside, there are dozens of different mailboxes, one for each apartment (`VLAN`). The mail clerk (the router's processor) uses this single room to sort and deliver mail between all the different apartments.

## 🔑 Key Details
-   **What it is:** 
	- A common, cost-effective method for enabling communication between different VLANs.
-   **Why it exists:** 
	- It avoids the need to use one physical router port for every single VLAN, which is expensive and not scalable.
-   **Core Components:**
    1.  **Switch Port:** The switch port connecting to the router must be configured as a [[Trunk Port]] to carry frames tagged for all VLANs.
    2.  **Router Subinterfaces:** The router's physical interface is not assigned an IP address. Instead, virtual subinterfaces are created for each VLAN (e.g., `FastEthernet0/24.10`, `FastEthernet0/24.20`).
    3.  **Encapsulation:** Each subinterface must be configured with the `encapsulation dot1q <vlan-id>` command to tell it which VLAN tag it should process.
    4.  **IP Address:** Each subinterface is assigned an [[IP Address]] that serves as the [[Default Gateway]] for its specific VLAN.

## 🔗 Connections & Implementations
*This is one of the primary methods of inter-VLAN routing. The other common method is using a multilayer switch with [[SVI|SVIs]].

## 👍 Pros & 👎 Cons
* **Pro:** 
	* Cost-effective (only uses one router port). Easy to configure.
* **Con:** 
	* Can become a performance bottleneck since all VLANs share one link. The single link/port is a single point of failure.

## See Also
-   [[VLAN]]
-   [[Trunk Port]]