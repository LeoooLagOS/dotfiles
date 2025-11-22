---
tags:
  - concept
  - linux
  - boot
  - startup
category: os
status: learning
related: "[[Linux Architecture]]"
date: 2025-11-21
---
# Linux Boot Process
## 📝 One-Sentence Summary
*The sequence of events that occurs from the moment the computer is turned on until the user login prompt appears.*
## 💡 Analogy
*Like **launching a space shuttle**:*
1.  **[[BIOS]]/[[UEFI]]:** Ground control checks systems.
2.  **[[MBR]]/[[GPT]]:** The launch codes are located.
3.  **[[Bootloader]] ([[GRUB]]):** The main engines ignite (selects which OS to launch).
4.  **[[Linux Kernel|Kernel]]:** Liftoff! The ship takes flight and systems stabilize.
5.  **[[Init System]] ([[systemd]]):** The crew wakes up and turns on life support (services).
## 🔑 Key Details
- **Step 1: [[BIOS]] / [[UEFI]]:** The motherboard performs a [[POST]] (Power-On Self-Test) and identifies the bootable device.
- **Step 2: [[MBR]] / [[GPT]]:** The system reads the partition table to locate the bootloader.
- **Step 3: [[Bootloader]] (usually [[GRUB]]):** The **Grand Unified Bootloader** loads the Kernel into memory. This provides the menu to select the OS.
- **Step 4: [[Linux Kernel|Kernel]]:** The kernel initializes hardware, mounts the root filesystem, and executes the first program (`/sbin/init`).
- **Step 5: [[Init System]] (usually [[systemd]]):** The mother of all processes (PID 1). It brings the system to a usable state by starting services (Network, SSH, GUI) based on the target (runlevel).
## 🔗 Connections & Implementations
* **Troubleshooting:** If the boot fails at Step 3, you enter the `grub>` prompt. If it fails at Step 5, you might drop into "Emergency Mode."
* **Configuration:** `systemd` is configured using `systemctl` commands.
## See Also
- [[Linux File System]]
- [[Process]] 