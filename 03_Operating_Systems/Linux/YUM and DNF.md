---
tags:
  - cli
  - fedora
  - redhat
  - linux
  - tool
category: os
status: learning
related: "[[Linux Package Management]]"
date: 2025-11-23
---
# YUM and DNF
## 📝 One-Sentence Summary
*YUM (Yellowdog Updater, Modified) is the legacy package manager for Red Hat systems, now succeeded by DNF (Dandified YUM), which offers better performance and dependency resolution.*
## 💡 Analogy
* **YUM** is like the **Old Reliable Pickup Truck**. It works, it's been around forever, but it's a bit slow and gas-guzzling.
* **DNF** is the **New Model**. It looks the same, drives the same (commands are mostly identical), but the engine is faster and smarter.
## 🔑 Key Details
- **Context:** In **[[Fedora]]**, you are using **DNF** by default. `yum` is often just a symlink (shortcut) to `dnf` on modern systems.
- **File Type:** Manages `.rpm` files.
## ⚙️ Core Commands (DNF/YUM)
*Most commands mirror APT but are slightly more concise.*

| Action | APT Equivalent | DNF/YUM Command |
| :--- | :--- | :--- |
| Refresh Lists | `apt-get update` | `dnf check-update` (or just run install, it auto-updates) |
| Install | `apt-get install` | `dnf install <package>` |
| Remove | `apt-get remove` | `dnf remove <package>` |
| Search | `apt-cache search` | `dnf search <keyword>` |
| Info | `apt-cache show` | `dnf info <package>` |
| History | *(Complex in apt)* | `dnf history` (View/Undo past transactions) |

## 🔗 Connections & Implementations
* **Repositories:** Stored in `/etc/yum.repos.d/`.
* **Groups:** DNF has a powerful feature to install groups of tools: `dnf groupinstall "Development Tools"`.
## See Also
- [[Linux Package Management]]
- [[APT]]