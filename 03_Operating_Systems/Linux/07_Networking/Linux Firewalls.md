---
tags:
  - security
  - firewall
  - cybersecurity
  - networking
  - linux
  - concept
category: os
status: learning
related: "[[Network Configuration]]"
date: 2025-11-24
---
# Linux Firewalls (Firewalld vs Iptables)
## 📝 One-Sentence Summary
*A comparison of Linux firewall architectures: the static, rule-based `iptables` service and the modern, dynamic, zone-based `firewalld` daemon.*
## 💡 Analogy
* **Iptables:** Like a **Printed Guest List**. If you want to add one person, you have to throw away the whole list, print a new one, and give it to the bouncer (Reloading/Flushing rules). This momentarily drops connections.
* **Firewalld:** Like a **Tablet**. The bouncer just taps "Add" to let a new person in. The list updates instantly without stopping the line (Dynamic updates).
## 🔑 Key Differences
| Feature | Iptables Service | Firewalld Daemon |
| :--- | :--- | :--- |
| **Storage** | `/etc/sysconfig/iptables` | XML files in `/usr/lib/firewalld/` & `/etc/firewalld/` |
| **Updates** | **Static.** Must flush and reload all rules for any change. | **Dynamic.** Can change settings at runtime without breaking connections. |
| **Default On** | Legacy systems. | RHEL 7+, Fedora, CentOS. |

## 🛡️ The "Zone" Concept
Firewalld assigns network interfaces to "Zones" based on trust level.
* **drop:** Zero trust. All incoming dropped without reply. Outgoing only.
* **block:** Incoming rejected with an ICMP error message (polite refusal).
* **public:** (Default) Untrusted. Only selected ports are open.
* **external:** For routers. Enables **Masquerading** (NAT).
* **dmz:** For isolated servers publicly accessible (De-Militarized Zone).
* **work:** Mostly trusted computers.
* **home:** High trust.
* **internal:** Trustworthy computers inside a gateway.
* **trusted:** Full network access. (Use with caution).

## See Also
- [[Firewalld Configuration]]
- [[Network Configuration]]