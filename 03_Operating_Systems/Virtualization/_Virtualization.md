---
tags:
  - overview
  - OS
  - virtualization
  - concept
category: os
status: learning
related: "[[_Operating Systems]]"
date: 2025-11-27
---
# _Virtualization_
## 📝 One-Sentence Summary
*Virtualization is the process of creating a software-based (virtual) representation of something, such as virtual applications, servers, storage, and networks, allowing single physical resources to act as multiple separate resources.*
## 💡 Analogy
* **Physical Server:** A large **Mansion**. It's expensive, huge, and often only one family lives in it (inefficient).
* **Virtualization:** Splitting that Mansion into **Apartments**. You use the same foundation and roof (Hardware), but now 10 families (VMs) can live there privately and efficiently.
## 🔑 Core Philosophy & Design
The core goal is **Abstraction**. By inserting a layer of software (the Hypervisor) between the hardware and the Operating System, we decouple the software from the physical machine.
* **Efficiency:** Stop wasting idle CPU cycles.
* **Isolation:** If one "apartment" burns down (crashes), the neighbors are safe.
## ⚙️ Key Details
- **What it is:** Creating a virtual platform including computer hardware, storage, and network.
- **Main Approaches:**
    1.  **[[Hardware Virtualization]]:** Simulating an entire computer so you can run a full OS (Windows on Linux).
    2.  **[[OS Virtualization]]:** Sharing the host OS kernel to run lightweight instances (Containers).
- **Key Vendors:** VMware (ESXi), Microsoft (Hyper-V), Citrix (Xen).
## 🔗 Connections & Implementations
* **Cloud Computing:** AWS, Azure, and GCP are essentially massive farms of virtualized servers.
* **DevOps:** Uses [[OS Virtualization]] (Docker) for rapid deployment.


[Image of virtualization architecture diagram]

## See Also
- [[Hypervisor]]
- [[Hardware Virtualization]]
- [[OS Virtualization]]