---
tags:
  - concept
  - linux
  - sysadmin
  - systemd
category: os
status: learning
related: "[[Linux Boot Process]]"
date: 2025-11-21
---
# Runlevels and Systemd Targets
## 📝 One-Sentence Summary
*Runlevels (in SysVinit) and Targets (in Systemd) are presets that define which system services are running and what state the machine is in (e.g., text-mode vs. graphical mode).*
## 💡 Analogy
*Think of the computer like a **Building**:*
* **Runlevel 0 (Poweroff):** The building is closed. Lights out.
* **Runlevel 1 (Rescue):** Only emergency maintenance staff are allowed inside. No public access.
* **Runlevel 3 (Multi-User):** The building is open for work, but the fancy lobby displays (GUI) are off. Efficient, business-only.
* **Runlevel 5 (Graphical):** Grand Opening. Everything is on, including the lights, music, and displays (GUI).
## 🔑 The Mapping: SysVinit vs Systemd
Modern Linux uses `systemd`, which uses "Targets" instead of numbers, but they map directly to the old "Runlevels."

| Old Runlevel | Description | Systemd Target | Purpose |
| :--- | :--- | :--- | :--- |
| **0** | Halt | `poweroff.target` | Shuts down the system. |
| **1 (S)** | Single User | `rescue.target` | Root shell only. No network. For fixing broken configs. |
| **2, 3, 4** | Multi-User (Text) | `multi-user.target` | Normal server mode. Network on, but no GUI. |
| **5** | Graphical | `graphical.target` | Normal desktop mode. Network + GUI. |
| **6** | Reboot | `reboot.target` | Restarts the system. |
| **N/A** | Emergency | `emergency.target` | Lowest level. Read-only filesystem. Used when boot fails critically. |

## ⚙️ Key Commands
* **Check current default:**
    ```bash
    systemctl get-default
    # Output: graphical.target
    ```
* **Change default boot mode (e.g., to Text Only):**
    ```bash
    systemctl set-default multi-user.target
    # Equivalent to old "init 3". Useful for servers to save RAM.
    ```
* **Switch immediately (without reboot):**
    ```bash
    systemctl isolate multi-user.target
    ```
## See Also
- `[[Linux Boot Process]]`
- `[[Init System]]`