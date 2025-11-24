---
tags:
  - concept
  - linux
  - software
  - sysadmin
category: os
status: learning
related: "[[Linux Architecture]]"
date: 2025-11-23
---
# Linux Package Management
## 📝 One-Sentence Summary
*Linux Package Management is the method of installing, updating, and removing software using centralized repositories and automated tools that handle software dependencies.*
## 💡 Analogy
* **Windows/Mac:** Like **Shopping at a Mall**. You go to different stores (websites), download different bags (installers), and manage them yourself.
* **Linux:** Like a **Vending Machine**. You type a code (command), and the machine grabs the item from its internal stock (repository) and delivers it. You trust the machine to have safe, compatible products.
## 🔑 The Two Main Families
Most Linux distributions fall into one of two camps regarding how they package software:

| Family      | Distros                      | File Format | Low-Level Tool | High-Level Tool (Dependency Solver) |
| :---------- | :--------------------------- | :---------- | :------------- | :---------------------------------- |
| **Debian**  | Ubuntu, Kali, Mint, Debian   | `.deb`      | `dpkg`         | [[APT]] (`apt`, `apt-get`)          |
| **Red Hat** | **[[Fedora]]**, RHEL, CentOS | `.rpm`      | `rpm`          | [[YUM and DNF]] (`dnf`, `yum`)      |

## ⚙️ Key Concepts
- **Repository (Repo):** A central server where packages are stored.
- **Dependency:** A library or program that another program needs to run. The Package Manager automatically finds and installs these (e.g., installing "VLC" also installs "video-codecs").
## See Also
- [[APT]]
- [[YUM and DNF]]