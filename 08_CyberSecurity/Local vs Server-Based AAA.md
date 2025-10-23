---
tags:
  - concept
  - cybersecurity
  - networking
category: cybersecurity
status:
  - learning
related: "[[AAA (Authentication, Authorization, Accounting)]]"
date: 2025-10-23
---

# Local vs Server-Based AAA

## 📝 One-Sentence Summary
*AAA authentication can be implemented either locally on each network device or centrally using a dedicated AAA server like [[RADIUS]] or [[TACACS+]].*
## 💡 Analogy
* **Local AAA:** 
	* Like each **building having its own separate security guard** with a list of employees allowed in that specific building. Simple for one building, but hard to manage if you have many. 
* **Server-Based AAA:** 
	* Like having a **central security headquarters** that maintains the master list of all employees for all buildings. Each building's guard contacts headquarters to verify anyone trying to enter. Easier to manage for a large organization.
## 🔑 Key Details
- **What they are:** 
	- Two common methods for implementing the authentication component of the [[AAA (Authentication, Authorization, Accounting)|AAA]] framework. 
- **Why the distinction exists:** 
	- To provide scalability options based on network size and complexity.
### The Methods
* **Local AAA Authentication:**
    * Stores usernames and passwords directly on the network device (e.g., a Cisco router). Users authenticate against this local database.
    * **Pros:** Simple to configure, ideal for small networks. SSH with local database authentication is more secure and accountable than simple line passwords.
    * **Cons:** User accounts must be configured individually on each device; difficult to manage in large environments; no fallback method if credentials are lost.
* **Server-Based AAA Authentication:**
    * The network device accesses a central AAA server (e.g., running RADIUS or TACACS+) containing credentials for all users.
    * **Pros:** Centralized management of user accounts; more scalable for larger networks. Provides a better solution than configuring local databases on each device.
    * **Cons:** Requires a dedicated server; adds a potential point of failure (if the server is unreachable).

## See Also
-   [[AAA (Authentication, Authorization, Accounting)]]
-   [[RADIUS]]
-   [[TACACS+]]