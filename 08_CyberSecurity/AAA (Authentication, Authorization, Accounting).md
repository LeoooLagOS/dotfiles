---
tags:
  - concept
  - cybersecurity
  - networking
  - framework
category: cybersecurity
status:
  - learning
related:
date: 2025-10-23
---

# AAA (Authentication, Authorization, Accounting)

## 📝 One-Sentence Summary
*AAA is a security framework used to control access to network resources by verifying user identity (**Authentication**), defining what users can do (**Authorization**), and tracking their actions (**Accounting**).*
## 💡 Analogy
*Using AAA is like using a **credit card**: 
* **Authentication:** The card identifies who can use it (verifying your identity with a PIN or signature). 
* **Authorization:** The card has limits on how much you can spend (defining your access rights). 
* **Accounting:** The credit card company keeps a detailed record of every purchase you make (tracking your actions).
## 🔑 Key Details
- **What it is:** 
	- A comprehensive framework for intelligently controlling access to computer resources, enforcing policies, and auditing usage. 
- **Why it exists:** 
	- To provide granular control over network access, enhance security, and maintain accountability for user actions. 
- **The Components:** 
	- **Authentication:** 
		- Verifies the identity of a user or device attempting to access the network. This can be done using a [[Local vs Server-Based AAA|local database]] on the device or a [[Local vs Server-Based AAA|central AAA server]]. 
		- SSH provides more secure authentication than older methods like simple password/login combinations on VTY lines because usernames and passwords are encrypted. 
	- **Authorization:** 
		- Determines what resources and actions an authenticated user is permitted to access or perform. This happens automatically after successful authentication and uses a set of attributes to define privileges and restrictions. 
	- **Accounting:** 
		- Collects and logs data about user activity, such as connection times, executed commands, and data transferred. This is used for auditing, billing, and troubleshooting. 
		- AAA servers keep detailed logs useful for tracking user actions, including configuration changes, which aids in troubleshooting and identifying malicious activity.
## 🔗 Connections & Implementations
* AAA services are often provided by protocols like [[RADIUS]] or [[TACACS+]]. 
* [[NAC (Network Access Control)]] solutions often leverage AAA services. 
* [[802.1X]] is an authentication protocol often used within an AAA framework.
## See Also
-   [[Local vs Server-Based AAA]]