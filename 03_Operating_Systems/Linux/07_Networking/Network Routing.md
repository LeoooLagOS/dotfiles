---
tags:
  - tool
  - linux
  - networking
  - routing
  - cli
category: os
status: learning
related: "[[Network Configuration]]"
date: 2025-11-24
---
# Network Routing
## 📝 One-Sentence Summary
*Network routing involves defining paths (routes) for traffic to reach specific networks, controlled via the `ip route` command and system gateway configurations.*
## ⚙️ Managing Routes (CLI)
* **View Table:** `ip route`
* **Add Static Route:**
    * Syntax: `ip route add [network] via [gateway] dev [interface]`
    * Example: `ip route add 192.0.2.0/24 via 10.0.0.3 dev eth0`
* **Add Default Gateway:**
    * `ip route add default via 10.0.0.1`


## 🔑 The Default Gateway Logic
How does Linux know which Gateway to use if multiple are defined?
1.  **Parsing Order:** The system reads `/etc/sysconfig/network` (Global) first.
2.  **Interface Files:** It then reads `ifcfg-ethX` files in numerical order.
3.  **Last Win:** The **last** `GATEWAY` directive read is the one used to compose the default route.
    * *Best Practice:* In modern RHEL, avoid the global file. Define the gateway only in the specific `ifcfg` file for the WAN interface.

## See Also
- `[[Network Configuration]]`
- `[[Network Troubleshooting]]`