---
tags:
  - concept
  - networking
  - configuration
category: networking
status:
  - learning
related: "[[VLAN]]"
date: 2025-09-27
---

# Switch Management Interface (SVI)

## 📝 One-Sentence Summary
A Switch Virtual Interface (SVI) is a logical Layer 3 interface created for a specific [[VLAN]] that allows a switch to be managed remotely over the network via an [[IP Address]].
## 💡 Analogy
An SVI is like giving the switch's main office its own unique mailing address and phone number. While the switch's other ports act as a mailroom sorting letters for everyone else, the SVI address is used to send messages directly **to the switch itself**.

## 🔑 Key Details
- **What it is:** 
	- A virtual interface that provides a Layer 3 presence on a Layer 2 switch, enabling it to send and receive IP packets. It is not tied to any single physical port. 
- **Why it exists:** 
	- To allow for in-band remote management of a switch using protocols like [[SSH]], [[Telnet]], or [[SNMP]]. For an SVI to be active, the VLAN it represents must exist on the switch.

## 🔗 Connections & Implementations

*To be managed from a remote network, the switch also needs a [[Default Gateway on a Switch]] configured.
* **Configuration Example:**
```cisco
! Create the SVI for VLAN 99 and assign an IP address
Switch(config)# interface Vlan99
Switch(config-if)# ip address 172.17.99.11 255.255.255.0
````

## 👍 Pros & 👎 Cons

- **Pro:** Allows for efficient, secure remote management from anywhere on the network.
    
- **Con:** Requires careful IP address planning and security considerations to prevent unauthorized access.
    

## See Also

- [[VLAN]]
    
- [[Default Gateway on a Switch]]
    
- [[IP Address]]
-