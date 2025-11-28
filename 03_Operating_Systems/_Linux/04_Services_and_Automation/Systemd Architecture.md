---
tags:
  - systemd
  - architecture
  - linux
  - concept
category: os
status: learning
related: "[[Service Management (Init vs Systemd)]]"
date: 2025-11-23
---
# Systemd Architecture
## 📝 One-Sentence Summary
*Systemd is a comprehensive suite of system management tools that organizes configurations into a strict hierarchy of directories and resource types called "Units."*
## 🔑 Configuration Hierarchy (Precedence)
Systemd looks for unit files in this specific order. If a file exists in a higher-priority directory, it overrides the lower ones.

1.  **`/etc/systemd/system/`** (Highest Priority)
    - **Purpose:** User/Admin created unit files.
    - **Use Case:** Custom services or overrides for system defaults.
2.  **`/run/systemd/system/`** (Medium Priority)
    - **Purpose:** Runtime units.
    - **Use Case:** Created dynamically by processes; lost on reboot.
3.  **`/usr/lib/systemd/system/`** (Lowest Priority)
    - **Purpose:** Vendor/Package provided units.
    - **Use Case:** Installed by RPM/DEB packages (e.g., Apache, Nginx default configs). *Do not edit these directly.*

## ⚙️ The Suite
Systemd is more than just an init [[Daemon|daemon]]; it includes:
* **`journald`**: Centralized logging management.
* **`logind`**: User session management.
* **`networkd`**: Network configuration.
* **`resolved`**: DNS resolution.

## 🔗 Connections & Implementations
* **Conf Files:** Global configuration is read from `system.conf` and `system.conf.d`.
* **User Instances:** Users can run their own instance of systemd, reading from `user.conf`.
## See Also
- [[Systemd Unit Files]]
- [[Linux Boot Process]]