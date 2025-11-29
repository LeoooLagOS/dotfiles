---
tags:
  - concept
  - devops
  - infrastructure
  - hardware
category: devops
status: learning
related: "[[Scalability (Vertical vs Horizontal)]]"
date: 2025-11-29
---
# Server Hosting Models

## 📝 One-Sentence Summary
Server hosting models describe the different ways computing resources are provisioned and managed, ranging from physical machines owned by the user to virtualized slices of shared hardware.

## 💡 Analogy
Think of hosting like **housing arrangements**:
-   **On-Premise:** Owning a **detached house**. You are responsible for everything: the bricks, the plumbing, the security, and the air conditioning.
-   **Dedicated Server:** **Renting a house**. You don't own the bricks, but you have the whole building to yourself.
-   **VPS (Virtual Private Server):** Living in a **condo/apartment**. You have your own private space with your own lock, but you share the building's foundation and pipes with neighbors.
-   **Shared Hosting:** Staying in a **hostel dormitory**. You share the room and resources with others; it's cheap, but if someone is noisy, it affects you.

## 🔑 Key Details
-   **On-Premise:** Managing your own physical hardware ("fierros").
    -   **Requirements:** A controlled environment with specific temperature, humidity, and dust control.
    -   **Pros:** Total control, data sovereignty.
    -   **Cons:** High cost, requires hardware maintenance (cloning disks, replacing RAM), hard to scale.
-   **VPS (Virtual Private Server):** A virtual machine running on a physical server. It acts like a dedicated server but shares physical resources.
-   **Cloud/Dedicated:** Leasing physical hardware or abstracting it entirely (AWS EC2, DigitalOcean).

## 🔗 Connections & Implementations
-   Moving from On-Premise to VPS/Cloud often enables easier **[[Scalability (Vertical vs Horizontal)]]**.
-   Managed by **[[DevOps vs SysAdmin|SysAdmins]]** (On-Premise) or **[[SRE]]s** ([[Cloud]]).

## See Also
-   [[Virtualization]]
-   [[Scalability (Vertical vs Horizontal)]]