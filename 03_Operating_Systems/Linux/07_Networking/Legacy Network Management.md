---
tags:
  - tool
  - linux
  - networking
  - legacy
  - deprecated
category: os
status: learning
related: "[[Network Configuration]]"
date: 2025-11-24
---
# Legacy Network Management (ifconfig & route)
## 📝 One-Sentence Summary
*A reference for the deprecated `net-tools` suite (`ifconfig`, `route`, `netstat`), which may still be encountered on older legacy systems but has been superseded by `iproute2`.*
## ⚙️ ifconfig (Interface Configuration)
* **Display All:** `ifconfig -a` (Shows all interfaces, even down ones).
* **Display Specific:** `ifconfig eth0`
* **Up/Down:**
    * `ifconfig eth0 up`
    * `ifconfig eth0 down`
* **Assign IP:** `ifconfig eth0 192.168.1.5 netmask 255.255.255.0`

## ⚙️ route (Routing Table)
* **View Table:** `route -n` (Use `-n` to avoid slow DNS lookups).
* **Add Gateway:** `route add default gw 192.168.1.1`

## ⚙️ Mapping: Old vs. New
| Action | Legacy (`ifconfig`) | Modern (`ip`) |
| :--- | :--- | :--- |
| Show IP | `ifconfig` | `ip addr` |
| Up/Down | `ifconfig up` | `ip link set up` |
| Show Routes | `route -n` | `ip route` |
| Connections | `netstat` | `ss` |

## See Also
- [[Network Configuration]]