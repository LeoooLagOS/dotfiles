---
tags:
  - concept
  - linux
  - security
  - cybersecurity
  - remote-access
category: os
status: learning
related: "[[Network Configuration]]"
date: 2025-11-24
---
# Remote Access Overview
## 📝 One-Sentence Summary
*Remote access in Linux is achieved through CLI protocols (Telnet, SSH) for text-based control or GUI protocols (VNC, X-System) for graphical interface control.*
## ⚙️ Protocols: Text-Based
* **Telnet:**
    * *Status:* **Obsolete/Unsafe.**
    * *Why:* Transmits everything (including passwords) in plain text. Anyone with `tcpdump` can steal your credentials.
* **SSH (Secure Shell):**
    * *Status:* **The Standard.**
    * *Why:* Fully encrypted connection. Replaces Telnet, RSH, and Rlogin.

## ⚙️ Protocols: Graphical (GUI)
* **X-System (X11 Forwarding):**
    * *Model:* Network-transparent. You can run a graphical app (like Firefox) on the server, and the window appears on your local client desktop.
    * *Config:* Requires `X11Forwarding yes` in SSH config.
* **VNC (Virtual Network Computing):**
    * *Model:* Screen sharing. Sends the actual bitmap of the screen. Slower than X11 but works for full desktop environments.
* **WinSCP:**
    * A Windows client that uses SSH to provide a graphical file manager for Linux servers.

## See Also
- [[SSH Basics]]
- [[Secure File Transfer]]