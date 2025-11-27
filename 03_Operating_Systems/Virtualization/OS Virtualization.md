---
tags:
  - concept
  - virtualization
  - containers
  - docker
category: os
status: learning
related: "[[_Virtualization]]"
date: 2025-11-27
---
# OS Virtualization (Containerization)
## 📝 One-Sentence Summary
*OS Virtualization creates isolated instances (containers) that share the **host Operating System's kernel** rather than simulating hardware for a full Guest OS.*
## 💡 Analogy
* **Hardware Virt (VMs):** **Houses.** Each has its own plumbing, heating, and foundation. Heavy and isolated.
* **OS Virt (Containers):** **Hotel Rooms.** Everyone shares the same building infrastructure (Plumbing/Kernel), but has a private room (User Space). Lightweight and fast.
## 🔑 Key Details
- **No Hypervisor:** It does not use a hypervisor. It uses Kernel features (like **Namespaces** and **Cgroups** in Linux).
- **Pros:**
    * **Performance:** Native speed (no driver emulation).
    * **Density:** Run 100 containers in the space of 1 VM.
    * **Startup:** Boot in milliseconds vs. minutes.
- **Cons:**
    * **Compatibility:** Guest must use the same kernel as Host (Cannot run Windows apps on Linux natively).
    * **Isolation:** Less secure than hardware virtualization (kernel exploits affect everyone).
- **Examples:** `[[Docker]]`, Solaris Containers, Linux-VServer.

![[Pasted image 20251127153951.png]]

## See Also
- [[Hardware Virtualization]]
- [[Docker]]