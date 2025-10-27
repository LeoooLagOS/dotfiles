---
tags:
  - concept
  - networking
  - security
category: networking
status:
  - learning
related: "[[Configuring SSH on a Switch]]"
date: 2025-09-29
---

# Telnet vs SSH

## 📝 One-Sentence Summary
*Secure Shell (**SSH**) is the secure, encrypted protocol that should always be used for remote device management, while **Telnet** is an insecure, legacy protocol that transmits all data, including passwords, in plaintext.
## 💡 Analogy
*Using **Telnet** is like sending your login details on a **postcard**. Anyone who intercepts it along the way can read everything. *Using **SSH** is like sending the same details in a **locked, steel box**. Only the person with the correct key can open it, ensuring the contents are private and secure during transit.*

## 🔑 Key Details
- **Telnet:** 
	- Uses TCP Port 23. - Sends all data, including usernames and passwords, in unencrypted plaintext. - Extremely vulnerable to eavesdropping attacks using tools like [[Wireshark]]. Considered obsolete for secure management. 
- **SSH (Secure Shell):** 
	- Uses TCP Port 22. - Provides strong [[Encryption]] for all communication: user authentication and the data exchanged. - The industry standard for secure remote command-line access.
## 🔗 Connections & Implementations
*Because of Telnet's vulnerabilities, the best practice is to always perform [[Configuring SSH on a Switch]] and disable Telnet access on the [[VTY Lines]].

## See Also
- [[Encryption]] 
- [[Wireshark]]