---
tags:
  - infrastructure
  - core
  - virtualization
  - concept
category: os
status: learning
related: "[[_Virtualization]]"
date: 2025-11-27
---
# Hypervisor (VMM)
## 📝 One-Sentence Summary
*A Hypervisor (or Virtual Machine Monitor - VMM) is the software layer that creates and runs virtual machines (VMs), managing the distribution of physical resources (CPU, RAM) to the virtual guests.*
## 💡 Analogy
*The **Hypervisor** is the **Traffic Cop** at a busy intersection. It sees all the cars (VMs) and decides who gets to go (access CPU) and when, ensuring they don't crash into each other.*
## 🔑 Key Details
- **Function:** It allows one host computer to support multiple guest VMs by virtually sharing its resources.
- **Why use it?**
    * **Speed:** Create VMs instantly (software definition) vs. buying cables and servers.
    * **Efficiency:** High utilization of hardware (less energy/space).
    * **Flexibility:** Run Windows, Linux, and macOS on the same physical box.
    * **Portability:** Move a running VM from Server A to Server B without turning it off (Live Migration).

![[Pasted image 20251127153744.png]]

## ⚙️ Hypervisor Types
*(Standard classification in CS Theory)*
1.  **Type 1 (Bare-Metal):** Installs directly on the hardware. No Host OS.
    * *Examples:* VMware ESXi, Microsoft Hyper-V, Xen.
    * *Use Case:* Enterprise datacenters.
2.  **Type 2 (Hosted):** Runs as an app inside an OS.
    * *Examples:* Oracle VirtualBox, VMware Workstation.
    * *Use Case:* Your laptop.
## See Also
- [[Hardware Virtualization]]
- [[_Virtualization]]