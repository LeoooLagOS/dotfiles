---
tags:
  - concept
  - cybersecurity
  - networking
category: cybersecurity
status:
  - learning
related: "[[Authentication]]"
date: 2025-10-23
---

# NAC (Network Access Control)

## 📝 One-Sentence Summary
*NAC is a security approach that controls access to network resources based on predefined policies, including user identity verification and endpoint security posture checks.*
## 💡 Analogy
*Think of NAC as a **strict airport security checkpoint** before you can board a plane (access the network). It checks your ticket and ID ([[Authentication]]), scans your luggage (endpoint health check like antivirus status), and ensures you meet all requirements before allowing you through the gate. If you don't meet the requirements, you might be denied entry or sent to a quarantine area (remediation VLAN).*
## 🔑 Key Details
- **What it is:** 
	- A system that enforces security policies on devices and users attempting to access network resources. 
- **Why it exists:** 
	- To prevent unauthorized or non-compliant devices (e.g., infected laptops, unpatched servers) from connecting to the network and potentially spreading malware or accessing sensitive data. 
	- It's often used as part of perimeter security and endpoint protection strategies 
- **Key Functions:** 
	- Typically includes authentication, authorization, accounting ([[[[AAA (Authentication, Authorization, Accounting)|AAA]]), endpoint security assessment (checking for antivirus, patches, etc.), and policy enforcement (allowing, denying, or quarantining access).
## 🔗 Connections & Implementations
* NAC often integrates with directory services (like Active Directory) for user authentication and uses protocols like [[802.1X]] for port-based authentication.
* It is a key component of modern endpoint protection strategies.
## 👍 Pros & 👎 Cons
* **Pro:** 
	* Greatly enhances network security by ensuring only compliant devices connect, provides visibility into connected endpoints. 
* **Con:** 
	* Can be complex to implement and manage, requires careful policy definition, may impact user experience if not configured correctly. 
## See Also
-   [[Authentication]]
-   [[802.1X]]
-   [[AAA (Authentication, Authorization, Accounting)]]
-   [[Endpoint Security]]