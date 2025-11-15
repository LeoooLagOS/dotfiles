---
tags:
  - concept
  - networking
  - command
  - Cisco_IOS
category: networking
status:
  - learning
related: "[[Dynamic Trunking Protocol (DTP)]]"
date: 2025-09-20
---

# switchport nonegotiate

## 📝 One-Sentence Summary
The `switchport nonegotiate` command is used on an interface to disable the sending of [[Dynamic Trunking Protocol (DTP)]] frames, effectively turning off automatic trunk negotiation.
## 💡 Analogy
It's like telling a guard to keep a high-traffic door permanently open (`switchport mode trunk`), but strictly forbidding them from talking to anyone who approaches (`switchport nonegotiate`). The door works, but there's no conversation about its status.
## 🔑 Key Details
- **What it is:** An interface configuration command that prevents a port from participating in DTP. - 
- **Why it exists:** 
	1. **Security:** It is a best practice to disable DTP on all ports to prevent DTP-based attacks like [[VLAN Hopping]]. 
	2. **Interoperability:** It is required to form a trunk link with a device from another vendor (e.g., Juniper, HP) that does not support the Cisco-proprietary DTP.
## 🔗 Connections & Implementations 
* This command can be applied when the interface is in either `access` or `trunk` mode. 
* On a **trunk port**, it stops the switch from sending DTP frames to negotiate a trunk. You must then manually configure the neighboring port as a trunk as well. 
* On an **access port**, it adds a layer of security by preventing the port from being tricked into becoming a trunk by a neighboring device sending DTP frames. 
## See Also 
- [[Switchport Modes]] - 
- [[Dynamic Trunking Protocol (DTP)]] 
- [[Trunk Port]]