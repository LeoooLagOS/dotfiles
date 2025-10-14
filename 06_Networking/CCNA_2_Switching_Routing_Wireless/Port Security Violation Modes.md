---
tags:
  - concept
  - networking
  - security
category: networking
status:
  - learning
related: "[[Port Security]]"
date: 2025-10-14
---

# Port Security Violation Modes

## 📝 One-Sentence Summary
*A violation mode defines the action a switch port will take when a frame with an unknown source [[MAC Address]] attempts to access a port with [[Port Security]] enabled.*
## 💡 Analogy
*This is the **bouncer's instruction manual** for dealing with uninvited guests.* 
* **Shutdown:** 
	* If an unauthorized person tries to enter, tackle them, lock the door, and call the manager. 
* **Restrict:** 
	* If an unauthorized person tries to enter, block them at the door and make a note of the incident in the security log. 
* **Protect:** 
	* If an unauthorized person tries to enter, just block them at the door and don't make a scene.

## 🔑 Key Details
- - **What they are:** 
	- Three configurable modes that determine the penalty for a security violation. 
- **Why they exist:** 
	- To provide administrators with different levels of response to a security breach, from completely disabling the port to silently dropping traffic.

## 🔗 Connections & Implementations
*This is a required configuration choice when implementing [[Port Security]]. 
* **Configuration Command:** 
`switchport port-security violation {shutdown | restrict | protect}` 
### The Three Modes

| Mode                   | Action on Port                                                                | Generates Log/SNMP Message? | Increments Violation Counter? |
| :--------------------- | :---------------------------------------------------------------------------- | :-------------------------: | :---------------------------: |
| **shutdown** (Default) | Puts the port into an **`err-disabled`** state, effectively shutting it down. |            ✅ Yes            |             ✅ Yes             |
| **restrict**           | **Drops** packets from the unauthorized MAC address. The port remains up.     |            ✅ Yes            |             ✅ Yes             |
| **protect**            | **Drops** packets from the unauthorized MAC address. The port remains up.     |            ❌ No             |             ❌ No              |
## See Also 
- [[Port Security]] 
- [[Err-disabled State]]