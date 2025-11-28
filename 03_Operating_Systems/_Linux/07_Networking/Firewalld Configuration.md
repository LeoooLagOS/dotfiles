---
tags:
  - cli
  - firewall
  - security
  - cybersecurity
  - networking
  - linux
  - guide
category: os
status: learning
related: "[[Linux Firewalls]]"
date: 2025-11-24
---
# Firewalld Configuration
## 📝 One-Sentence Summary
*A guide to using `firewall-cmd` to manage zones, services, and advanced networking features like Masquerading and Port Forwarding.*
## ⚙️ Core Commands
* **Check Status:** `firewall-cmd --state`
* **Panic Mode (Emergency):**
    * `firewall-cmd --panic-on` (Drops ALL packets instantly).
    * `firewall-cmd --panic-off`
* **Services:**
    * `firewall-cmd --get-services` (List all available definitions).
    * `firewall-cmd --info-service=ftp` (Show ports for a specific service).

## ⚓ Runtime vs. Permanent
* **Runtime (Default):** Changes happen instantly but **disappear** on reboot.
* **Permanent:** Saved to config files but don't apply instantly unless you reload.
* **The Golden Rule:** Always use `--permanent` for persistent changes, then reload.
    * `firewall-cmd --permanent --add-service=http`
    * `firewall-cmd --reload`

## 🖧 Advanced Networking
### 1. Masquerading (NAT)
*Required if your Linux box is acting as a Router/Gateway.*
* **Concept:** Replaces the source IP of outgoing packets with the firewall's IP.
* **Command:** `firewall-cmd --zone=external --add-masquerade`
* **Verify:** `firewall-cmd --query-masquerade`

### 2. Port Forwarding
*Redirects traffic from one port to another (or to a different server).*
* **⚠️ Critical Dependency:** Port forwarding **Requires Masquerading** to be enabled first!
* **Command:**
    * *Goal:* Forward incoming traffic on port 22 (SSH) to port 3753.
    * `firewall-cmd --zone=external --add-forward-port=port=22:proto=tcp:toport=3753`

## See Also
- [[Linux Firewalls]]
- [[Network Routing]]