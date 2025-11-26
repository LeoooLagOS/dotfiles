---
tags:
  - concept
  - theory
  - linux
  - security
  - selinux
category: os
status: learning
related: "[[Linux Permissions]]"
date: 2025-11-24
---
# SELinux (Security Enhanced Linux)
## 📝 One-Sentence Summary
*SELinux is an advanced security architecture that implements Mandatory Access Control (MAC) on top of standard Linux permissions (DAC), strictly defining what every process and user can access.*
## 💡 Analogy
* **DAC (Standard Permissions):** Like having a **Key**. If you have the key (read permission), you can open the door.
* **MAC (SELinux):** Like a **Security Guard with a Clipboard**. Even if you have the key, the guard checks the clipboard (Policy). If the policy says "The Janitor (Process) is not allowed in the Server Room (File) during the day," the guard stops you, even if your key fits.
## 🔑 Key Concepts: MAC vs. DAC
- **DAC (Discretionary Access Control):** The standard owner/group/other permissions. Access is decided by the file owner.
- **MAC (Mandatory Access Control):** Access is strictly defined by system policies loaded into the Kernel. Users cannot override these policies.
## ⚙️ The Three Modes
SELinux operates in one of three states, controlled by `/etc/selinux/config`.

| Mode | Behavior | Logging | Use Case |
| :--- | :--- | :--- | :--- |
| **Enforcing** | **Blocks** unauthorized access. | Logs denials. | Production systems (Secure). |
| **Permissive** | **Allows** access but warns. | Logs what *would* have been blocked. | Debugging/Testing. |
| **Disabled** | SELinux is turned off. | None. | Not recommended. |

## 🔗 Connections & Implementations
* **Configuration File:** `/etc/selinux/config`
* **Log Files:** Violations are typically logged in `/var/log/audit/audit.log` or `/var/log/messages`.
## See Also
- [[Managing SELinux]]
- [[Linux Permissions]]
- [[Kernel]]