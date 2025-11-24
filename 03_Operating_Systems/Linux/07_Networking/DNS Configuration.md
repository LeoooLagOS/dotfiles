---
tags:
  - concept
  - linux
  - networking
  - dns
  - configuration
category: os
status: learning
related: "[[Network Configuration]]"
date: 2025-11-24
---
# DNS Configuration (Hosts & Resolv)
## 📝 One-Sentence Summary
*Linux resolves domain names to IP addresses by checking a local static file (`/etc/hosts`) first, followed by the DNS servers defined in the resolver configuration (`/etc/resolv.conf`).*
## 💡 Analogy
* **`/etc/hosts`:** Your **Personal Rolodex**. You write "Mom" -> "555-0199". The phone checks this first. It overrides everything else.
* **`/etc/resolv.conf`:** The **Public Phone Book**. If "Mom" isn't in your Rolodex, the phone calls the operator (DNS Server) listed here to find the number.
## 🔑 Key Files
### 1. `/etc/hosts` (Local Override)
* **Format:** `IP_Address  Hostname  Alias`
* **Example:** `127.0.0.1  localhost`
* **Use Case:** Blocking websites (redirecting to 0.0.0.0) or naming local dev servers without buying a domain.

### 2. `/etc/resolv.conf` (The Resolver)
* **Format:** `nameserver <IP>`
* **Example:**
    ```text
    nameserver 8.8.8.8
    nameserver 1.1.1.1
    ```
* **Warning:** On modern systems (systemd-resolved), this file is often a symbolic link and shouldn't be edited manually.

## ⚙️ Hostnames
* **Check Hostname:** `hostname`
* **Change Hostname:** `hostnamectl set-hostname new-name` (This is the systemd way).
## See Also
- [[Network Configuration]]
- [[Network Troubleshooting]]