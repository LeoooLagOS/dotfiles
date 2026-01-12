---
tags:
  - setup
  - virtualization
  - kvm
  - alma-linux
  - fedora
category: 8th-semester
status: active
related: "[[Network_Administration_Syllabus]]"
date: 2026-01-07
---
# Lab Environment Setup

## 📝 One-Sentence Summary
*A localized, isolated virtualization environment using KVM/QEMU on Fedora to safely execute risky Linux administration labs (boot repair, partitioning) without compromising the host system.*

## 💡 Analogy
*Instead of experimenting with a new, potentially explosive chemical (the "System Boot" commands) in your main kitchen (Fedora Host), you are building a blast-proof containment chamber (The AlmaLinux VM). If it explodes, you just press a button (Snapshot Revert) and the kitchen remains spotless.*

## 🔑 Key Details
- **Host OS:** Fedora Workstation (Your Main "Daily Driver").
- **Guest OS:** AlmaLinux 9.1 (Exact match for course requirements).
- **Hypervisor:** KVM (Kernel-based Virtual Machine) via `libvirt` and `virt-manager`.
- **Why KVM?** It is native to the Linux kernel (Type-1 performance), unlike VirtualBox (Type-2), ensuring near-metal speed for your labs.

## 🛠️ Implementation Strategy

### 1. Host Preparation (Fedora)
Install the virtualization group and management tools.
```bash
sudo dnf groupinstall "Virtualization"
sudo dnf install virt-manager
```

**Start and enable the service:**
```bash
sudo systemctl enable --now libvirtd
```
_Verification:_ Run `virt-manager` from your terminal or app launcher. If it opens without errors, the host is ready.

### 2. ISO Acquisition

- **Source:** [AlmaLinux 9.1 Vault](https://www.google.com/search?q=https://repo.almalinux.org/almalinux/9.1/isos/x86_64/)
    
- **Selection:** - `AlmaLinux-9.1-x86_64-minimal.iso` (Preferred for speed and low resource usage).
    - `dvd` (Only if a GUI is strictly required, though CLI is better for Admin learning).
### 3. VM Specifications

- **RAM:** 4096 MB (4GB).
    
- **vCPUs:** 2.
    
- **Storage:** 20 GB minimum (qcow2 format).
    
- **Network:** `default` (NAT). _This provides internet access for `dnf install` inside the VM._
    

### 4. 🛡️ The "Safety Net" Protocol

**Crucial for Syllabus Units 2 (Boot) & 4 (Filesystems):**

1. Perform the base installation of AlmaLinux.
    
2. Run `dnf update` to patch the system.
    
3. **Shut down the VM.**
    
4. In `virt-manager` -> **Manage VM Snapshots** -> Create Snapshot.
    
5. Name: `Base_Clean_Install`. _Use this snapshot to revert instantly if you break the bootloader during the "System Boot" unit._

## 🔌 Connection Protocol
**Do not use the graphical console.** Connect via SSH from the host terminal for better UI.

1.  **Start VM:** `virt-manager` -> Select VM -> Play.
2.  **Get IP (One-time):** Log in to console, run `ip a` (Look for `192.168.122.XXX`).
	* This lab was: 192.168.124.165
3.  **Connect from Host:**
    ```bash
    ssh lag-os-admin@<IP_ADDRESS> 
    # ssh lag-os-admin@192.168.124.165
    ```
4.  **Shared Folders:** Use `scp` to move files if needed.
    ```bash
    scp my_script.sh lag-os-admin@<IP_ADDRESS>:/home/lag-os-admin/
    ```
## 🔗 Connections

- Fits into [[KVM and QEMU]] concepts.
    
- Required for [[Boot Process AlmaLinux]] labs.