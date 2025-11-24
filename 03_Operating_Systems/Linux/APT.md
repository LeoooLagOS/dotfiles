---
tags:
  - debian
  - cli
  - linux
  - tool
category: os
status: learning
related: "[[Linux Package Management]]"
date: 2025-11-23
---
# APT (Advanced Package Tool)
## 📝 One-Sentence Summary
*APT is the package management system for Debian-based distributions (like Ubuntu), utilizing `apt-get` for installation and `apt-cache` for searching.*
## 🔑 Key Tools
* **`apt-get`**: The core command-line tool for handling packages.
* **`apt-cache`**: A tool to query the local package database (metadata) without changing the system.
* **`apt`**: A modern, user-friendly wrapper that combines the most common commands from both of the above.

## ⚙️ Cheat Sheet: `apt-get` (Management)
| Command | Action | Detail |
| :--- | :--- | :--- |
| `update` | **Refresh List** | Downloads the new package lists from repositories. (Does *not* update software, just the list). |
| `upgrade` | **Upgrade All** | Installs the newest versions of all packages currently installed. |
| `install <pkg>` | **Install** | Installs a new package (e.g., `apt-get install vim`). |
| `remove <pkg>` | **Uninstall** | Removes the binary package but **keeps** configuration files. |
| `purge <pkg>` | **Nuke** | Removes the package **AND** its configuration files. |
| `check` | **Verify** | Checks for broken dependencies. |

## ⚙️ Cheat Sheet: `apt-cache` (Information)
| Command | Action | Detail |
| :--- | :--- | :--- |
| `search <regex>` | **Find** | Searches the package list for a pattern (e.g., `apt-cache search python`). |
| `show <pkg>` | **Details** | Shows the description, version, and size of a package. |
| `depends <pkg>` | **Dependencies** | Shows what other packages this one needs to run. |
| `showpkg <pkg>` | **Technical** | Shows general info and reverse dependencies (who needs *this* package). |

## 🔗 Connections & Implementations
* **Config Location:** Repositories are defined in `/etc/apt/sources.list`.
* **Common Workflow:** `sudo apt-get update && sudo apt-get upgrade -y` (The standard maintenance command).
## See Also
- [[Linux Package Management]]
- [[YUM and DNF]]