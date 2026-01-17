---
tags:
  - concept
  - linux
  - cli
category: 15_DevOps
status: learning
related: "[[SysAdmin Functions]]"
date: 2026-01-16
---
# Linux CLI Fundamentals

## 📝 One-Sentence Summary
A collection of standard POSIX commands used to interact with the Linux kernel for file management, process control, and system observation.

## 💡 Analogy
The **Medical Vital Signs Monitor**: Just as a doctor uses specific tools to check heart rate (`ps`) and blood pressure (`free`), a SysAdmin uses the CLI to check the "vitals" of the server without opening the "patient" (GUI).

## 🔑 Key Details
- **What it is:** The primary interface for headless server management.
- **Why it exists:** Efficiency, scriptability (automation), and low-resource overhead.
- **Daemons:** Background processes (e.g., `httpd`, `sshd`) that provide services without user interaction.

## ⚙️ Core Components
- **File Hierarchy:** Programs typically reside in `/bin` or `/usr/bin`.
- **Devices:** Located in `/dev`. 
	- Note that not all are physical (e.g., `/dev/null` is a virtual "black hole").
- **Persistence:** Commands like `dnf update` ensure the software stack remains patched and secure.

## 🔗 Connections & Implementations
- **Lab Work:** Essential for navigating the [[AlmaLinux-Lab]].
- **Setup:** Used to configure your [[_Fedora Workstation]].

## 👍 Pros & 👎 Cons
- **Pros:** Remote access via SSH; very fast for power users.
- **Cons:** No safety net (e.g., `rm` is permanent); steep learning curve.

## See Also
[[Vi Cheat Sheet]]
[[_DevOps]]