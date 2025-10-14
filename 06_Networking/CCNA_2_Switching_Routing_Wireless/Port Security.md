---
tags:
  - concept
  - networking
  - security
  - configuration
category: networking
status:
  - learning
related: "[[MAC Address]]"
date: 2025-10-14
---

# Port Security

## 📝 One-Sentence Summary
*Port security is a Layer 2 feature that mitigates [[MAC Address]] table attacks by limiting the number of valid MAC addresses allowed to access a single switch port.*
## 💡 Analogy
*Think of port security as a **bouncer at a VIP room door with a strict guest list**. The bouncer (the port) will only allow a specific number of pre-approved guests (secure MAC addresses) to enter. If an unauthorized person tries to get in, the bouncer takes action (a [[Port Security Violation Modes|violation]]).*

## 🔑 Key Details
- **What it is:** 
	- A feature that compares the source MAC address of incoming frames on an interface to a list of allowed, secure MAC addresses. 
- **Why it exists:** 
	- To control access to the network on a per-port basis. By limiting the number of MAC addresses to one, you can ensure that only the intended device can use that switch port. 
- **Prerequisite:** 
	- Port security can only be enabled on ports that are manually configured as either `access` or `trunk` ports. It will not work on ports left in a dynamic mode.

## 🔗 Connections & Implementations
*The MAC addresses can be learned in several ways, as detailed in [[Port Security MAC Address Modes]].
*When an unauthorized MAC address is detected, the port will take a predefined action, as defined in [[Port Security Violation Modes]].

### Enablement Sequence
```cisco
! The port must be set to access or trunk mode first
S1(config)# interface f0/1
S1(config-if)# switchport mode access

! Then, port security can be enabled
S1(config-if)# switchport port-security
````

### Verification

Cisco CLI

```
S1# show port-security interface f0/1
```

## See Also

- [[Port Security MAC Address Modes]]
    
- [[Port Security Violation Modes]]
    
- [[Securing Unused Ports]]