---
tags:
  - concept
  - cybersecurity
  - networking
category: cybersecurity
status:
  - learning
related: "[[Encryption]]"
date: 2025-10-23
---

# VPN (Virtual Private Network)

## 📝 One-Sentence Summary
*A VPN creates a secure, encrypted connection (a "tunnel") over a public network like the internet, allowing remote users or sites to access private network resources as if they were directly connected.*
## 💡 Analogy
*Imagine the internet is a busy, public highway. A VPN is like building a **private, armored tunnel** through that highway system. Only authorized vehicles (encrypted data) can enter the tunnel, and nobody outside can see what's inside, allowing you to travel securely from your home (remote user) directly into your company's private parking garage (private network).
## 🔑 Key Details
- **What it is:** 
	- A technology that extends a private network across a public network. It uses [[Encryption]] and tunneling protocols to ensure data confidentiality and integrity. 
- **Why it exists:** 
	- To provide secure remote access for users, connect geographically separated offices securely, and protect data transmitted over untrusted networks (like public Wi-Fi). 
	- Various network security devices are needed to protect the network perimeter, potentially including a VPN-enabled router.
## 🔗 Connections & Implementations
* VPNs are often implemented using protocols like IPsec or [[SSL/TLS]]. 
* Many [[Router|Routers]] and [[Firewall|Firewalls]] have built-in VPN capabilities.
## 👍 Pros & 👎 Cons
* **Pro:** 
	* Provides secure communication over insecure networks, enables remote access. 
* **Con:** 
	* Can introduce latency, requires proper configuration for security, encryption overhead can impact performance.
## See Also
- [[Encryption]] 
- [[Tunneling]] 
- [[IPsec]] 
- [[SSL/TLS]]