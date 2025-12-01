---
tags:
  - concept
  - devops
  - sre
  - role
category: dev-ops
status:
  - learning
related: "[[DevOps vs SysAdmin]]"
date: 2025-11-29
---
# Site Reliability Engineering (SRE)

## 📝 One-Sentence Summary
Site Reliability Engineering (SRE) is a discipline that incorporates aspects of software engineering and applies them to infrastructure and operations problems to create scalable and highly reliable software systems.

## 💡 Analogy
If a **SysAdmin** is a mechanic who fixes cars when they break down, an **SRE** is a **Formula 1 Engineer**. They don't just fix the car; they use data and engineering principles to redesign the engine so it doesn't break in the first place, automate the pit stops, and calculate exactly how fast the car can go without exploding (SLA).

## 🔑 Key Details
-   **What it is:** 
	- A specific implementation of the [[DevOps vs SysAdmin|DevOps]] philosophy, originally pioneered by Google. It treats operations as a software problem.
-   **The Hierarchy of Knowledge:** An effective SRE requires a deep stack of understanding, often visualized as:
    1.  **Development:** Coding skills (Python, Go) to build tools.
    2.  **Systems:** Deep [[_Operating Systems]] knowledge (Linux internals).
    3.  **Networks:** Understanding [[09_Networking/_Protocols/STP|protocols]] and traffic flow.
    4.  **[[_Computer Hardware|Hardware]]:** Knowing the physical limits of the "fierros" (servers).
-   **Service Level Agreement (SLA):** SREs manage reliability using math.
    -   **Example:** Google might not promise 100% uptime, but **99.95%**. That 0.05% is the "Error Budget"—time allowed for updates, experiments, or "Downgrades" (planned maintenance/expansion).

## 🔗 Connections & Implementations
-   SREs rely heavily on **[[IaC]]** tools like Terraform and Ansible to ensure immutability.
-   They use **[[Docker|Containerization]]** (and [[Kubernetes]]) to abstract away hardware dependencies.

## See Also
-   [[DevOps vs SysAdmin]]
-   [[_Operating Systems]]