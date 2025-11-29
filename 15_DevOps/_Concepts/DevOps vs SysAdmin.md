---
tags:
  - concept
  - devops
  - role
  - culture
category: devops
status: learning
related: "[[Site Reliability Engineering (SRE)]]"
date: 2025-11-29
---
# DevOps vs SysAdmin

## 📝 One-Sentence Summary
The difference between a SysAdmin and DevOps is a shift from manual, reactive server management to an automated, collaborative culture where infrastructure is managed as code.

## 💡 Analogy
-   **The "Wall of Confusion" (Traditional):** Developers write code and throw it over a wall to SysAdmins. If it breaks, devs say "It works on my machine," and SysAdmins say "Your code broke my server."
-   **DevOps (Modern):** Developers and Operators sit at the same table. They build a robot (automation pipeline) that takes the code and puts it on the server safely. If it breaks, the robot tells them exactly why.

## 🔑 Key Details
-   **The SysAdmin (System Administrator):**
    -   **Focus:** [[_Computer Hardware]], [[Server]]s, [[DNS]], routes, [[Load Balancing|load balancers]].
    -   **Methods:** Often manual tasks like "cloning disks," patching servers individually, and maintaining **"On-Premise"** hardware ("fierros").
    -   **Mindset:** "Keep the lights on" and minimize change to ensure stability.
-   **DevOps (Development + Operations):**
    -   **Focus:** The entire software delivery lifecycle.
    -   **Methods:** [[IaC]], [[CI/CD Pipelines]], and automation.
    -   **Mindset:** "Change is inevitable; automate it to make it safe." It is a **Culture**, not just a job title.

## 🔗 Connections & Implementations
-   The evolution of the SysAdmin role often leads to **[[SRE]]**.
-   DevOps replaces manual server configuration with [[IaC]] tools.

## See Also
-   [[Scalability (Vertical vs Horizontal)]]