---
tags:
  - concept
  - networking
  - redundancy
  - cisco
category: networking
status: learning
related: "[[Default Gateway]]"
date: 2025-11-11
---
# HSRP (Hot Standby Router Protocol)

## 📝 One-Sentence Summary
*HSRP is a Cisco-proprietary protocol that provides a redundant [[Default Gateway]] for hosts on a subnet by creating a "virtual router" with a single virtual [[IP Address]] and MAC address.

## 💡 Analogy
*Imagine a bank with two tellers ([[Router|Routers]]) at the front desk. They both share a single **"Main Teller" sign** (the Virtual IP). One teller (**Active**) handles all customers (packets), while the other (**Standby**) just watches. If the active teller faints (fails), the standby teller *instantly* steps in and takes over. From the customer's (host's) perspective, the "Main Teller" service was never interrupted.

## 🔑 Key Details
-   **What it is:** 
	- A First [[FHRP|Hop Redundancy Protocol (FHRP)]] that provides [[3_Network Layer|Layer 3 ]]gateway redundancy.
-   **Why it exists:** 
	- To prevent the [[Default Gateway]] from being a single point of failure for a subnet.
-   **How it Works:**
    1.  **Group:** Routers are configured into an [[HSRP]] group (e.g., `standby 1`).
    2.  **Virtual IP:** The group shares a single virtual IP address (e.g., `192.168.2.254`), which is what hosts use as their gateway.
    3.  **Active/Standby Election:** One router is elected **Active** (based on highest `priority`, `150` in the lab) and handles all traffic. The other becomes **Standby**.
    4.  **Preemption:** The `standby 1 preempt` command allows a router with a higher priority (like R3 in the lab) to forcibly take back the `Active` role when it recovers from a failure.

## 🔗 Connections & Implementations
*HSRP is Cisco-proprietary. The open-standard equivalent is [[VRRP|VRRP (Virtual Router Redundancy Protocol)]].*

## 👍 Pros & 👎 Cons
* **Pro:** 
	* Provides seamless, automatic default gateway failover for end devices.
* **Con:** 
	* Cisco-proprietary. Can be complex to troubleshoot.

## See Also
-   [[Default Gateway]]
-   [[Redundancy]]
-   [[VRRP]]