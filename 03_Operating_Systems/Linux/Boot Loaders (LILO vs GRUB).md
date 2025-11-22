---
tags:
  - concept
  - boot
  - linux
  - history
category: os
status: learning
related: "[[Linux Boot Process]]"
date: 2025-11-21
---
# Boot Loaders (LILO vs GRUB)
## 📝 One-Sentence Summary
*A comparison of the software responsible for loading the Linux Kernel into memory: the legacy LILO and the modern, flexible [[GRUB]].*
## 💡 Analogy
* **LILO (Legacy):** Like a **printed paper map**. If the road (kernel location) changes, the map is useless until you print a new one (re-run the configuration command). It doesn't "know" the terrain.
* **[[GRUB]] (Modern):** Like a **GPS Navigation System**. It understands the map (filesystem). If a road changes, it can usually find the destination dynamically. It has an interactive interface to change routes on the fly.
## 🔑 Key Details
| Feature | LILO (Linux Loader) | GRUB (Grand Unified Bootloader) |
| :--- | :--- | :--- |
| **Status** | Legacy / Obsolete | Current Standard (GRUB2) |
| **Filesystem Awareness** | **None.** It relies on physical block addresses. | **Yes.** It understands filesystems (ext4, xfs). |
| **Kernel Updates** | Must run `/sbin/lilo` after *every* change to update the map. | Usually automatic (reads config file at boot). |
| **Complexity** | Simple, text-based. | Complex, supports scripting and a mini-shell. |
## 🔗 Connections & Implementations
* **GRUB 2** is the default on almost all modern distributions (Fedora, Ubuntu, RHEL).
* LILO is mostly found on very old systems or specific embedded devices where simplicity is key.
* If your system fails to boot, you often interact with the **GRUB Shell** to manually point it to the kernel image.
## See Also
- [[Linux Boot Process]]
- [[Linux Kernel]]
