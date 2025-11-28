---
tags:
  - guide
  - linux
  - sysadmin
  - lvm
category: os
status: learning
related: "[[Linux Swap]]"
date: 2025-11-21
---
# Managing Swap
## 📝 One-Sentence Summary
*A practical guide to creating swap spaces using LVM or Files, modifying the `/etc/fstab` for persistence, and safely removing them.*
## ⚙️ Method 1: Adding LVM Swap
*Best for systems already using [[LVM]]. 
Example: Adding a 2GB swap volume.*

1.  **Create the Logical Volume (LV):**
    ```bash
    # Creates a 2GB volume named LogVol02 in VolGroup00
    lvcreate VolGroup00 -n LogVol02 -L 2G
    ```
2.  **Format as Swap:**
    ```bash
    mkswap /dev/VolGroup00/LogVol02
    ```
3.  **Persist (Auto-mount):**
    Add this line to `/etc/fstab`:
    ```text
    /dev/VolGroup00/LogVol02 swap swap defaults 0 0
    ```
4.  **Activate:**
    ```bash
    systemctl daemon-reload  # Refresh systemd config
    swapon -v /dev/VolGroup00/LogVol02
    ```

## ⚙️ Method 2: Adding a Swap File
*Best for flexibility or when you cannot resize partitions.*

1.  **Create the Empty File:**
    *Formula: Block Size (`bs`) * Count = Total Size.*
    ```bash
    # Example: 64MB swap (1024 * 65536)
    dd if=/dev/zero of=/swapfile bs=1024 count=65536
    ```
2.  **Secure and Format:**
    *Security is critical: swap contains data from RAM, potentially including passwords.*
    ```bash
    chmod 0600 /swapfile   # Read/Write for root ONLY
    mkswap /swapfile       # Set up the swap area
    ```
3.  **Persist (Auto-mount):**
    Add this line to `/etc/fstab`:
    ```text
    /swapfile swap swap defaults 0 0
    ```
4.  **Activate:**
    ```bash
    systemctl daemon-reload
    swapon /swapfile
    ```

## ⚙️ Removing Swap
*To safely decommission swap space.*

1.  **Disable Swapping:**
    ```bash
    # Moves data out of swap back to RAM
    swapoff -v /swapfile
    ```
2.  **Remove Configuration:**
    - Open `/etc/fstab` (`vi /etc/fstab`) and **delete the swap line**.
    - Run `systemctl daemon-reload`.
3.  **Delete the Artifact:**
    ```bash
    rm /swapfile
    # OR if using LVM:
    # lvremove /dev/VolGroup00/LogVol02
    ```
## 🔗 See Also
- [[Linux Swap]]
- [[LVM]]
