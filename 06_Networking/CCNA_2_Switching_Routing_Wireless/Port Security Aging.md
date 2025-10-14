---
tags:
  - concept
  - networking
  - security
category: networking
status:
  - learning
related: "[[Port Security MAC Address Modes]]"
date: 2025-10-14
---

# Port Security Aging

## 📝 One-Sentence Summary
*Port security aging automatically removes secure [[MAC Address|MAC addresses]] from a port's list after a specified time, providing a way to clear old entries without manual intervention.*
## 💡 Analogy
*This is like a **temporary guest pass** for the VIP room. The pass can be set to expire after a fixed time (`absolute`), or it can be set to expire only if the guest leaves the room and doesn't come back for a while (`inactivity`).*

## 🔑 Key Details
- **What it is:** 
	- A feature that sets a timer on dynamically learned secure MAC addresses. 
- **Why it exists:** 
	- To provide flexibility in environments where devices are frequently moved. It prevents the secure MAC address list from filling up with old, unused entries. 
- **Aging Types:** 
	- **`absolute`:** The secure address is deleted after the exact aging time expires, regardless of whether the device is active. 
	- **`inactivity`:** The timer is reset every time the device sends traffic. The address is only deleted if it is idle for the entire aging time.

## 🔗 Connections & Implementations
*This feature is often used with the `dynamic` and `sticky` `[[Port Security MAC Address Modes]]`.
* **Configuration Commands:**
```cisco
! Sets the aging timer in minutes
S1(config-if)# switchport port-security aging time 10

! Sets the aging type
S1(config-if)# switchport port-security aging type inactivity
````

## See Also

- [[Port Security]]
    
- [[Port Security MAC Address Modes]]