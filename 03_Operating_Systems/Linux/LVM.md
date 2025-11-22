---
tags:
  - concept
  - linux
  - storage
  - lvm
  - sysadmin
category: os
status: learning
related: "[[Linux File System]]"
date: 2025-11-21
---
# LVM (Logical Volume Manager)
## 📝 One-Sentence Summary
*LVM is a storage virtualization layer that allows administrators to pool multiple physical hard drives into a single volume group, which can then be flexibly sliced into logical volumes.*
## 💡 Analogy
* **Traditional Partitions:** 
	* Like having distinct **water bottles** (Disk 1, Disk 2). If one bottle is empty and the other full, you can't easily move the water.
* **LVM:** 
	* You pour all the water bottles into a **large bathtub (Volume Group)**. You can then dip cups **(Logical Volumes)** of any size into the tub. If you need more water, you just dump another bottle (Physical Volume) into the tub.
## 🔑 The LVM Hierarchy
1.  **PV (Physical Volume):** The raw physical disk or partition (e.g., `/dev/sdb1`).
2.  **VG (Volume Group):** The storage pool created by combining PVs.
3.  **LV (Logical Volume):** The virtual partition created from the VG. The OS sees this as a mountable device.

## ⚙️ Core Workflow & Commands
To create a usable filesystem using LVM, follow this specific order:
1.  **Initialize Physical Volumes (PV):**
    - `pvcreate /dev/sdb1` (Labels the disk for LVM use)
    - `pvdisplay` / `pvscan` (Check status)
2.  **Create Volume Group (VG):**
    - `vgcreate my_vg /dev/sdb1` (Creates the pool named 'my_vg')
3.  **Create Logical Volume (LV):**
    - `lvcreate -L 10G -n my_lv my_vg` (Carves out a 10GB slice named 'my_lv')
    - `lvdisplay` (Check logical volumes)
4.  **Create File System:**
    - `mkfs.ext4 /dev/my_vg/my_lv` (Formats the LV so it can be mounted)
## 👍 Pros & 👎 Cons
* **Pros:** **Flexibility.** 
	* You can resize (extend/reduce) volumes on the fly without rebooting. You can span a single filesystem across multiple physical disks.
* **Cons:** **Complexity.** 
	* More layers mean more steps to recover data if a disk fails.
## See Also
- [[Linux File System]]
- [[Mounting]]