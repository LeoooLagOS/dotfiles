---
tags:
  - concept
  - networking
  - protocol
  - security
  - layer-7
  - ssh
  - shell
category: networking
status:
  - learning
related: "[[SSH Hardening]]"
date: 2025-11-29
---
# SSH (Secure Shell)

## 📝 One-Sentence Summary
SSH is a cryptographic network protocol used to securely operate network services over an unsecured network, primarily for remote command-line login and execution.

## 💡 Analogy
If **Telnet** is like sending a postcard (anyone handling it can read the message), **SSH** is like sending a message in a **locked, titanium briefcase**. Even if someone intercepts the briefcase on the way, they cannot open it to see the instructions inside without the correct key.

## 🔑 Key Details
-   **What it is:** A secure alternative to non-protected login protocols (like Telnet and rlogin).
-   **Default Port:** TCP port **22**.
-   **Authentication Methods:**
    1.  **Password:** Traditional username/password (less secure, prone to brute force).
    2.  **Public Key Infrastructure (PKI):** Uses a **Public Key** (on the server) and a **Private Key** (on your computer). This is the industry standard for secure connection.
-   **Why it exists:** To ensure confidentiality and integrity of data sent over an insecure network (like the Internet).

## 🔗 Connections & Implementations
-   It is the standard tool for **[[DevOps vs SysAdmin|SysAdmins]]** to manage **[[Server Hosting Models|Servers]]** remotely.
-   It is used to manage Cisco devices securely (see **[[Configuring SSH on a Switch]]**).

## See Also
-   [[SSH Hardening]]
-   [[Telnet vs SSH]]
-   [[Encryption]]