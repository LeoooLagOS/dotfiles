---
tags:
  - concept
  - infrastructure
  - devops
  - architecture
category: devops
status: learning
related: "[[Load Balancing]]"
date: 2025-11-29
---
# Scalability (Vertical vs Horizontal)

## 📝 One-Sentence Summary
Scalability is the ability of a system to handle growing amounts of work, achieved either by adding power to a single machine (Vertical) or adding more machines to the pool (Horizontal).

## 💡 Analogy
-   **Vertical Scaling (Scale Up):** You have a car that can't carry enough people. You exchange it for a **bigger bus** with a bigger engine.
-   **Horizontal Scaling (Scale Out):** You have a car that can't carry enough people. You buy **three more cars** and drive in a convoy.

## 🔑 Key Details
-   **Vertical Scaling (Scale Up):**
    -   **How:** Adding more resources (RAM, CPU, ROM) to a single existing server.
    -   **Legacy Context:** Common in older, heterogeneous networks where there was one "Main Server" doing everything.
    -   **Limit:** You eventually hit a hardware ceiling (you can't buy a bigger CPU).
-   **Horizontal Scaling (Scale Out):**
    -   **How:** Adding more servers (nodes) to a cluster to execute the program.
    -   **Modern Context:** The preferred method for Cloud/DevOps. Requires a **[[Load Balancing|Load Balancer]]**.
    -   **Benefit:** Theoretically infinite scaling and high availability.

## 🔗 Connections & Implementations
-   Horizontal scaling requires **[[Load Balancing]]** to distribute traffic.
-   **[[Docker]]** and [[Kubernetes]] are designed specifically to make Horizontal Scaling easy.

## See Also
-  [[Server Hosting Models]]