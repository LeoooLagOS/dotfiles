---
tags:
  - concept
  - networking
  - configuration
category: networking
status:
  - learning
related: "[[Switch Management Interface (SVI)]]"
date: 2025-09-27
---

# Default Gateway on a Switch

## 📝 One-Sentence Summary
The default gateway on a [[Layer 2 switch]] is the IP address of a router that the switch uses to communicate with devices on other networks for management purposes.

## 💡 Analogy
Imagine the switch's management office is in a large building. If it needs to send a letter to a different building (another network), the **default gateway** is the address of the local post office (the router) where it must send all its outgoing mail.
## 🔑 Key Details
- **What it is:** 
	- A globally configured IP address that points to a neighboring router. 
- **Why it exists:** 
	- It is essential for remote management. If an administrator on a different network (e.g., `10.1.1.0/24`) wants to SSH into a switch on the `172.17.99.0/24` network, the switch needs a default gateway to know how to send the return traffic back. 
- **Important Distinction:** 
	- This gateway is **only** for traffic originating from the switch's own [[Switch Management Interface (SVI)]]. It does **not** affect how the switch forwards user data frames between PCs on the same VLAN.

## 🔗 Connections & Implementations
*This command is used in conjunction with a configured [[Switch Management Interface (SVI)]].
* **Configuration Command:**
```cisco
! The command is entered in global configuration mode
Switch(config)# ip default-gateway 172.17.99.1
````

## See Also

- [[Switch Management Interface (SVI)]]
    
- [[Router]]