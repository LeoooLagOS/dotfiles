---
tags:
  - concept
  - networking
  - protocol
category: networking
status:
  - learning
related: "[[Switchport Modes]]"
date: 2025-09-20
---

# Dynamic Trunking Protocol (DTP)

## 📝 One-Sentence Summary
*DTP is a Cisco-proprietary protocol that allows a switch port to automatically negotiate with a neighboring port to decide whether they should form a [[Trunk Port]].
## 💡 Analogy
*Imagine two ambassadors meeting. Instead of waiting for instructions, they can automatically agree to speak a special, high-bandwidth language (trunking) to exchange information for all their departments (VLANs) at once. 
DTP is the protocol for that automatic agreement.
## 🔑 Key Details
- **What it is:** A [[2_Data Link Layer||layer 2]] protocol that automates the creation of a trunk link between two switches. It operates on a point-to-point basis. 
- **Why it exists:** To simplify and speed up network configuration. An administrator can connect two switches, and if configured correctly, they will form a trunk link without manual intervention. 
- **Security Caution:** DTP is a known security risk. An attacker can use it to perform a [[VLAN Hopping]] attack by tricking a switch into forming a trunk with the attacker's machine. It is best practice to disable DTP on ports connected to untrusted devices or end-users.
## 🔗 Connections & Implementations

* DTP's behavior is configured using the [[Switchport Modes]] command, specifically the `dynamic auto` and `dynamic desirable` options. 
* The primary security vulnerability it creates is [[VLAN Hopping]]. 
* To disable DTP on a trunk port, you use the [[switchport nonegotiate]] command. 
* This protocol is enabled by default on many Cisco Catalyst switches.
## 👍 Pros & 👎 Cons
* **Pro:** 
	* Simplifies initial switch setup and can reduce configuration time. 
* **Con:** 
	* Creates a significant security vulnerability if not managed correctly. It is not an open standard and only works between Cisco devices.
## See Also
- [[Trunk Port]] 
- [[Switchport Modes]] 
- [[VLAN Hopping]]
