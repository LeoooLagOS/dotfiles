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

# Port Security MAC Address Modes

## 📝 One-Sentence Summary
*A switch can learn the secure MAC addresses for a [[Port Security]]-enabled interface in one of three ways: manually configured (static), dynamically learned, or dynamically learned with persistence (sticky).*
## 💡 Analogy
*Think of the bouncer's guest list again. It can be created in three ways:*
* **Static:** 
	* The club manager gives the bouncer a **handwritten, permanent list** of names. 
* **Dynamic:** 
	* The bouncer allows the **first person who arrives** to enter and remembers their face for the night, but forgets it the next morning (after a reboot). 
* **Sticky:** 
	* The bouncer allows the **first person who arrives** to enter, takes their picture, and **permanently adds it to the official guest list**.

## 🔑 Key Details
- **What they are:** 
	- Methods for populating the list of secure MAC addresses on a port. 
- **Why they exist:** 
	- To provide administrators with flexibility, from high-security manual configuration to more convenient automated learning.

## 🔗 Connections & Implementations
*These modes are configured within the interface configuration for a [[Port Security]]-enabled port.
### The Three Modes

| Mode                  | Description                                                                                             | Command                                      |
| --------------------- | ------------------------------------------------------------------------------------------------------- | -------------------------------------------- |
| **Manually Configured** | The administrator explicitly defines the secure MAC address(es) for the port.                | `switchport port-security mac-address <mac>` |
| **Dynamically Learned** | The switch automatically learns the source MAC of the first device it sees and secures it. This is the default behavior but the address is lost on reboot. | (Default after `switchport port-security` is enabled) |
| **Dynamically Learned – Sticky** | The switch dynamically learns the MAC address and automatically converts it into a static entry in the running configuration, which can then be saved. | `switchport port-security mac-address sticky` |

## See Also
-   [[Port Security]]
-   [[Running-Config vs Startup-Config]]