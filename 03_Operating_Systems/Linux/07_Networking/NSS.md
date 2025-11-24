---
tags:
  - concept
  - linux
  - networking
  - dns
  - authentication
category: os
status: learning
related: "[[DNS Configuration]]"
date: 2025-11-24
---
# NSS (Name Service Switch)
## 📝 One-Sentence Summary
*The Name Service Switch (`/etc/nsswitch.conf`) is the central facility that dictates the **order** and **sources** the OS uses to resolve names (hostnames, usernames, passwords) from various databases.*
## 💡 Analogy
*Think of **NSS** as the **Receptionist's Procedure Manual**.*
* When you ask "Where is Bob?", the manual tells the receptionist:
    1.  Check the **Internal Directory** (`files` / `/etc/hosts`).
    2.  If not found, call the **Branch Office** (`dns`).
    3.  If not found, check the **Global Database** (`ldap` / `nis`).
## 🔑 Configuration: `/etc/nsswitch.conf`
The file lists "databases" and the order of sources.
```text
hosts:      files dns
passwd:     files ldap
```
- **`files`**: Look in local `/etc/` files first (e.g., `/etc/hosts`, `/etc/passwd`).
    
- **`dns`**: Query the nameserver defined in `/etc/resolv.conf`.
    
- **`ldap` / `nis`**: Query remote directory services.
## ⚙️ Importance

- **Troubleshooting:** If `ping google.com` fails but `ping 8.8.8.8` works, checking `nsswitch.conf` ensures the system is actually configured to _use_ DNS (`hosts: files dns`).
    
- **Performance:** Putting `files` first speeds up the system by avoiding network queries for local things like `localhost`.
    

## See Also

- [[DNS Configuration]]
    
- [[Linux Users and Groups]]