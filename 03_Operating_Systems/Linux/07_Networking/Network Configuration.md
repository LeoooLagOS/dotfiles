---
tags:
  - tool
  - linux
  - networking
  - iproute2
  - legacy
  - configuration
  - debian
  - guide
  - rhel
category: os
status: learning
related: "[[Linux Architecture]]"
date: 2025-11-24
---
# Network Configuration
## 📝 One-Sentence Summary
*A guide to configuring Linux networking using the modern `ip` command for transient changes and distribution-specific files for persistent configuration.*
## ⚙️ Transient Config (The `ip` Command)
* **Show Interfaces:** `ip addr` (or `ip a`)
* **Enable Interface:** `ip link set eth0 up`
* **Assign IP:**
    * Syntax: `ip addr add [ip]/[mask] dev [interface]`
    * Example: `ip addr add 192.168.2.223/24 dev eth1`
    * *Note:* You can run this multiple times to add multiple IPs.

## 📁 Persistent Config (The Files)
*Changes made with `ip` are lost on reboot. Use these files to save them.*

### 🔴 Red Hat / CentOS / Fedora
* **Directory:** `/etc/sysconfig/network-scripts/`
* **File Naming:** `ifcfg-<interface_name>` (e.g., `ifcfg-eth0`)
* **Global Config:** `/etc/sysconfig/network` (Deprecated, but used for Hostname).
* **Example `ifcfg-eth0`:**
    ```bash
    DEVICE=eth0
    Type=Ethernet
    ONBOOT=yes
    BOOTPROTO=none       # 'dhcp' or 'none' (static)
    IPADDR=208.164.186.1
    PREFIX=24            # Netmask 255.255.255.0
    GATEWAY=192.168.1.1
    DNS1=8.8.8.8
    ```
* **Apply Changes:** `nmcli connection reload` or `systemctl restart NetworkManager`.

### 🌀 Debian / Ubuntu (Server Legacy)
* **File:** `/etc/network/interfaces`
* **Hostname:** `/etc/hostname`
* **Example:**
    ```bash
    auto eth0
    iface eth0 inet static
        address 192.168.0.10
        netmask 255.255.255.0
        gateway 192.168.0.1
    ```
* **Apply Changes:** `systemctl restart networking`.

## 🔗 Connections & Implementations
* **Default Gateway Logic:** In RHEL, the system parses `ifcfg` files in numerical order. The **last** `GATEWAY` directive read wins. Best practice is to define the gateway ONLY in the WAN interface file.
## See Also
- [[Legacy Network Management]]
- [[Network Routing]]
- [[NSS]]