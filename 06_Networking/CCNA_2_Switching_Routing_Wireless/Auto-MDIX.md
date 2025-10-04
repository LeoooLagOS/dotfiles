---
tags:
  - concept
  - networking
  - layer-1
category: networking
status:
  - learning
related: "[[Autonegotiaton]]"
date: 2025-09-26
---

# Auto-MDIX

## 📝 One-Sentence Summary
*Auto-MDIX (Automatic Medium-Dependent Interface Crossover) is a feature that allows a switch port to automatically detect the required Ethernet cable type (straight-through or crossover) and configure itself to establish a successful link.

## 💡 Analogy
*It's like having a universal power adapter for your laptop that automatically senses the voltage in any country and adjusts itself. You don't need to manually flip a switch or carry a different adapter for each region; it just works.
## 🔑 Key Details
- **What it is:** 
	- A physical layer feature that automates the detection of transmit (Tx) and receive (Rx) pins on a connected device. 
- **Why it exists:** 
	- To eliminate the need for administrators to use specific cable types for different connections. It removes the guesswork and potential for error when connecting devices like switches, routers, and PCs. 
- **Requirement:** 
	- For auto-MDIX to function correctly, the interface speed and duplex must be set to **`auto`**, allowing the port to [[Autonegotiaton||autonegotiate]] these settings along with the pinout.
## 🔗 Connections & Implementations

* This feature simplifies the choice between using an [[Ethernet Straight-through Cable]] and an [[Ethernet Crossover Cable]].
* **Configuration Command:**
```cisco
S1(config)# interface FastEthernet 0/1
S1(config-if)# mdix auto
````
*For a complete practical example, see [[Lab - Configure Port Autonegotiation]].
*The operational status of this feature can be checked by [[Verifying Auto-MDIX]].

## 👍 Pros & 👎 Cons

- **Pro:** Greatly simplifies network cabling and reduces installation errors.
    
- **Con:** Relies on [[Autonegotiation]], which can sometimes be a point of failure if one device has it disabled.
    

## See Also

- [[Autonegotiation]]
    
- [[Verifying Auto-MDIX]]
    
- [[Ethernet Straight-through Cable]]
    
- [[Ethernet Crossover Cable]]