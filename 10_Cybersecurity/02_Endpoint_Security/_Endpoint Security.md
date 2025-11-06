---
tags:
  - concept
  - cybersecurity
  - networking
category: cybersecurity
status:
  - learning
related: "[[NAC]]"
date: 2025-10-23
---

# Endpoint Security

## 📝 One-Sentence Summary
*Endpoint security involves protecting the end-user devices (like laptops, desktops, servers, phones) that connect to a network from threats like malware and unauthorized access.*
## 💡 Analogy
*Think of endpoint security as the **individual security systems for each house in a neighborhood**. While the neighborhood might have a main gate ([[Firewall]]), each house also needs its own locks, alarms, and security cameras (antivirus, host firewall, HIPS) because threats can originate from within the neighborhood just as easily as from outside.*
## 🔑 Key Details
- **What it is:** 
	- The practice of securing endpoints, which are the host devices commonly targeted by attackers. 
	- These include traditional devices like laptops and servers, as well as BYOD (Bring Your Own Device)
- **Why it exists:** 
	- Endpoints are often the weakest link in network security. They are susceptible to malware from email or web browsing, and a compromised endpoint can become a launching point for attacks against critical internal systems. 
- **Protection Methods:** 
	- Traditionally includes [[Antivirus/Antimalware]], host-based firewalls, and [[Host-based Intrusion Prevention Systems (HIPS)]]. 
## 🔗 Connections & Implementations
- Modern approaches often integrate [[NAC]], advanced malware protection (AMP) software, and specialized security appliances like [[Cisco ESA]] and [[Cisco WSA]].
## 👍 Pros & 👎 Cons
* **Pro:** 
	* Directly protects the devices where users interact and data resides, providing defense-in-depth. 
* **Con:** 
	* Can be complex to manage across a large number of diverse devices, requires constant updates to keep up with new threats.
## See Also
- [[Malware]] 
- [[NAC]] 
- [[Cisco ESA]] 
- [[Cisco WSA]]
