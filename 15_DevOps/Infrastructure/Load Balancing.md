---
tags:
  - concept
  - devops
  - infrastructure
  - networking
category: devops
status: learning
related: "[[Scalability (Vertical vs Horizontal)]]"
date: 2025-11-29
---
# Load Balancing

## 📝 One-Sentence Summary
Load balancing is the process of efficiently distributing incoming network traffic across a group of backend servers to ensure no single server is overwhelmed.

## 💡 Analogy
A Load Balancer is like a **receptionist at a busy bank**.  A line of customers (traffic) comes in. The receptionist directs the first person to Teller 1, the second to Teller 2, the third to Teller 3, and so on. This ensures all tellers are working equally and the line moves fast.

## 🔑 Key Details
-   **What it is:** 
	- A device or software (like [[Nginx]], [[HAProxy]]) that sits between the user and the server farm.
-   **Why it exists:** 
	- Essential for **[[Scalability (Vertical vs Horizontal)|Horizontal Scaling]]**. If you have 10 servers, you need one entry point to split the traffic between them.
-   **Algorithms:**
    -   **[[Round Robin]]:** The simplest method. Requests are distributed sequentially (Server 1, then 2, then 3, then back to 1).
    -   **Least Connections:** Sends traffic to the server with the fewest active users.

## 🔗 Connections & Implementations
-   SysAdmins manage physical load balancers; DevOps engineers often manage software/cloud load balancers using **[[IaC]]**.

## See Also
-   [[Scalability (Vertical vs Horizontal)]]
-   [[Server Hosting Models]]