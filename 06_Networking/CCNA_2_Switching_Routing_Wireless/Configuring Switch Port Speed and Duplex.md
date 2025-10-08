---
tags:
  - concept
  - networking
  - configuration
  - Cisco_IOS
  - command
category: networking
status:
  - learning
related: "[[Duplex Communication]]"
date: 2025-09-26
---

# Configuring Switch Port Speed and Duplex

## 📝 One-Sentence Summary
*The `speed` and `duplex` interface commands are used to manually set the physical layer operating parameters of a switch port, overriding the default [[Autonegotiation]] process.
## 💡 Analogy
* This is like switching your car's transmission from **automatic to manual**. 
	Instead of letting the car (the switch port) decide the best gear (speed and duplex) on its own, you are explicitly telling it exactly how to operate.
## 🔑 Key Details
- **What it is:** 
	- A manual configuration process performed in the interface configuration mode of a switch. 
- **Why it exists:** 
	- To troubleshoot and resolve issues where [[Autonegotiation]] fails between two devices. A duplex or speed mismatch is a common source of network errors, and manually setting both ends of the link to the same values can fix the problem.

## 🔗 Connections & Implementations
*These commands directly control the behavior described in [[Duplex Communication]]. 
* **The Commands:** 
	- `duplex {auto | full | half}`: Sets the duplex mode. 
	- `speed {auto | 10 | 100 | 1000}`: Sets the port speed in Mbps.
* **Full Example Sequence:** 
* ```cisco 
  S1# configure terminal 
  S1(config)# interface FastEthernet 0/1 
  S1(config-if)# duplex full 
  S1(config-if)# speed 100 
  S1(config-if)# end 
  S1# copy running-config startup-config
  ````
  *To configure the port to use automatic settings instead of manual ones, see [[Lab - Configure Port Autonegotiation]].
## 👍 Pros & 👎 Cons

- **Pro:** Manually setting these values provides a deterministic and stable link configuration, which is useful for fixing negotiation issues.
    
- **Con:** If you manually set one side of a link, you **must** manually set the other side to match. An incorrect manual configuration can cause a link to fail.
    

## See Also

- [[Duplex Communication]]
    
- [[Autonegotiaton]]