---
tags:
  - concept
  - networking
  - security
  - configuration
category: networking
status:
  - learning
related: "[[Initial Device Security Configuration]]"
date: 2025-10-14
---

# Securing Unused Ports

## 📝 One-Sentence Summary
*A foundational security practice is to administratively disable all unused switch ports to prevent unauthorized devices from connecting to the network.*
## 💡 Analogy
*This is like **locking all the unused doors and windows** in your house. An open, unused port is an easy invitation for an attacker to gain access to your network.*
## 🔑 Key Details
- **What it is:** 
	- The process of placing any switch port that is not in active use into a shutdown state. 
- **Why it exists:** 
	- It is a simple but highly effective method for hardening a switch and reducing the attack surface of the network.

## 🔗 Connections & Implementations
*This is often done for a large number of ports at once using the `interface range` command for efficiency.*
### Command Sequence
```cisco
! Select a range of unused ports
Switch(config)# interface range FastEthernet0/5-24

! Administratively disable the ports
Switch(config-if-range)# shutdown
````

*To reactivate a port, use the `no shutdown` command on that interface.*

## See Also

- [[Initial Device Security Configuration]]
    
- [[Port Security]]