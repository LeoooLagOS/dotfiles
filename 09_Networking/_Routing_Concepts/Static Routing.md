---
tags:
  - concept
  - networking
  - routing
category: networking
status: learning
related: "[[Routing Table]]"
date: 2025-11-11
---
# Static Routing

## 📝 One-Sentence Summary
*Static routing is the process of manually configuring a [[Router]] with a specific path to a [[Remote Route]], rather than having it learn the path automatically through a dynamic routing protocol.

## 💡 Analogy
*This is like manually programming your GPS with a specific, fixed route to a destination. You are telling it exactly which highways to take, and it will **not* change that route, even if there's traffic. It will only use that exact path.

## 🔑 Key Details
-   **What it is:** 
	- A manual entry in the [[Routing Table]] created by an administrator.
-   **Why it exists:** Used in small, simple networks for predictability and security. It is also used to create [[Default Route|Default Routes]] or backup routes.
-   **Configuration Command:**
    `ip route <network-address> <subnet-mask> {<next-hop-ip> | <exit-interface>}`
-   **Floating Static Route:**
    * This is a special type of static route configured with a higher **[[Administrative Distance]]** `(e.g., `4` in the lab).
    * It serves as a **backup path**. It is not added to the [[Routing Table]] unless the primary, more-preferred route (like one from [[OSPF]] or [[EIGRP]]) fails.

## 🔗 Connections & Implementations
Static routes are one of the main ways a router learns about a [[Remote Route]].

## 👍 Pros & 👎 Cons
* **Pro:** 
	* Highly secure (no routes are advertised). Low CPU/memory overhead. Very predictable.
* **Con:** 
	* Not scalable. Must be manually reconfigured if the network topology changes.

## See Also
-   [[Remote Route]]
-   [[Default Route]]
-   [[Administrative Distance]]
-   [[Dynamic Routing]]