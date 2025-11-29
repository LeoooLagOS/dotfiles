---
tags:
  - ssh
  - shell
  - cybersecurity
  - concept
  - hardening
category: cybersecurity
status: learning
related: "[[SSH]]"
date: 2025-11-29
---
# SSH Hardening

## 📝 One-Sentence Summary
SSH Hardening refers to the practice of reconfiguring the default SSH server settings to reduce the attack surface and protect against brute-force or unauthorized access.

## 💡 Analogy
Hardening SSH is like **reinforcing the front door**. The door (SSH) is strong, but if you leave the key under the mat (default port/password), it's useless. Hardening is moving the door to the side of the house (changing ports), throwing away the physical key in favor of a biometric scanner (SSH keys), and installing a secret knock pattern (Port Knocking).

## 🔑 Key Details
-   **Why it exists:** SSH port 22 is the most attacked port on the internet. Bots constantly scan for it to try default passwords.
-   **Best Practices:**
    1.  **Disable Password Authentication:** Force the use of **SSH Keys** (Public/Private key pair).
    2.  **Change the Default Port:** Move SSH from port 22 to a non-standard port (e.g., 2222 or 54321) to avoid automated scanners.
    3.  **Disable Root Login:** Never allow direct login as the `root` user. Log in as a normal user and use `sudo`.
    4.  **Port Knocking:** A technique where the firewall keeps the SSH port closed until a specific sequence of connection attempts ("knocks") is received on other ports.

## 🔗 Connections & Implementations
-   This is a critical task for **[[DevOps vs SysAdmin|SysAdmins]]** when setting up **[[Server Hosting Models|VPS or On-Premise]]** servers.
-   It is a specific application of **[[Device Hardening Best Practices]]**.

## See Also
-   [[Firewall]]
-   [[04_Identity_Access_Management/Authentication|Authentication]]