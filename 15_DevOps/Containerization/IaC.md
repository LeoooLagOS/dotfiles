---
tags:
  - concept
  - devops
  - methodology
  - automation
category: dev-ops
status:
  - learning
related: "[[Docker]]"
date: 2025-11-29
---
# Infrastructure as Code (IaC)

## 📝 One-Sentence Summary
Infrastructure as Code (IaC) is the practice of managing and provisioning computer data centers through machine-readable definition files (code) rather than physical hardware configuration or interactive configuration tools.

## 💡 Analogy
IaC is the difference between **hand-building a house** and **3D printing** one.
-   **Manual (SysAdmin):** A crew places bricks one by one. If they build a second house, it might be slightly different because of human variation.
-   **IaC (DevOps):** You write a digital blueprint. You feed it to a machine (like Terraform or Ansible), and it generates the exact same house every single time. If you want to change a window, you update the blueprint, not the house itself.

## 🔑 Key Details
-   **What it is:** 
	- The process of automating infrastructure deployment using code.
-   **Why it exists:** 
	- To ensure **Immutability** and **Reproducibility**. It eliminates "configuration drift" where servers become different over time due to manual updates.
-   **The Hierarchy:**
    1.  **Hardware:** The physical metal.
    2.  **Network:** Connectivity.
    3.  **Systems:** The OS and configuration.
    4.  **Development:** The application logic.
    *IaC allows Developers and [[SRE]]s to control the bottom layers using code.*

## 🔗 Connections & Implementations
-   **Tools:**
    -   **[[Docker]]** (and [[Podman]]): For containerizing applications.
    -   **[[Kubernetes]]:** For orchestrating containers.
    -   **[[Terraform]] / [[Pulumi]]:** For provisioning cloud resources (servers, load balancers).
    -   **[[Ansible]]:** For configuration management.
-   It is a core skill for the [[SRE|Site Reliability Engineering (SRE)]] role.

## See Also
-   [[DevOps vs SysAdmin]]
-   [[_Git]] (IaC files are version-controlled)