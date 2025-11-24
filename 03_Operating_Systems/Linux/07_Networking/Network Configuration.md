---
tags:
  - tool
  - linux
  - networking
  - iproute2
  - legacy
category: os
status: learning
related: "[[Linux Architecture]]"
date: 2025-11-24
---
# Network Configuration (ip vs ifconfig)
## 📝 One-Sentence Summary
*A comparison of the deprecated `net-tools` suite (`ifconfig`, `route`) and the modern, more powerful `iproute2` suite (`ip`) used to configure network interfaces and routing tables.*
## 💡 Analogy
* **`ifconfig`:** Like an **Old Analog Dashboard**. It shows you speed and fuel, but it's clunky and can't handle complex modern features (like multiple addresses per interface).
* **`ip` command:** Like a **Modern Digital Cockpit**. It controls everything from a single unified interface, supports complex routing, and is much faster.
## 🔑 Key Details
- **The Shift:** Most modern distros (Fedora, Arch, Debian 10+) do not install `ifconfig` by default. You must learn `ip`.
- **Syntax Philosophy:** `ip [object] [command]`.
    - Objects: `addr` (address), `link` (interface), `route` (routing table).

## ⚙️ Rosetta Stone: Old vs. New
| Action | Legacy (`net-tools`) | Modern (`iproute2`) |
| :--- | :--- | :--- |
| **Show Interfaces** | `ifconfig -a` | `ip addr` (or `ip a`) |
| **Enable Interface** | `ifconfig eth0 up` | `ip link set eth0 up` |
| **Assign IP** | `ifconfig eth0 192.168.1.5` | `ip addr add 192.168.1.5/24 dev eth0` |
| **Show Routing Table** | `route -n` | `ip route` (or `ip r`) |
| **Add Gateway** | `route add default gw 192.168.1.1` | `ip route add default via 192.168.1.1` |

## 🔗 Connections & Implementations
* **Persistent Config:** These commands are **ephemeral** (lost on reboot). To make them permanent, you use [[NMCLI]] (NetworkManager) or edit config files in `/etc/sysconfig/network-scripts/` (RedHat) or `/etc/netplan/` (Ubuntu).
## See Also
- [[Network Troubleshooting]]
- [[DNS Configuration]]