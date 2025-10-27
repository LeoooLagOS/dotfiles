---
tags:
  - concept
  - networking
  - security
  - configuration
  - command
  - procedure
  - ccna
  - Cisco_IOS
category: networking
status:
  - learning
related: "[[Cisco IOS Modes]]"
date: 2025-10-08
---

# Initial Device Security Configuration

## 📝 One-Sentence Summary
*This is the foundational set of commands applied to a new Cisco device to establish a baseline of security, including setting a hostname, creating and encrypting passwords, and displaying a legal banner.*

## 💡 Analogy
*Think of this as **changing the locks and setting up the security system** for a new building. You're replacing the generic factory keys with unique ones, adding a password to the main security panel, and putting a "No Trespassing" sign on the front lawn before you allow any traffic.*

## 🔑 Key Details
- **What it is:** 
	- A standard operating procedure for hardening a Cisco switch or router before it is deployed on a network. It protects the device from unauthorized access and creates a professional and manageable configuration environment. 
- **Why it exists:** 
	- To secure the different [[Cisco IOS Modes]] and access methods, such as the console port and the [[VTY Lines]] for remote access.
## 🔗 Connections & Implementations
*This procedure is one of the first tasks performed after accessing a new device's command line. The commands are entered in global configuration mode.* 
### Core Command Sequence
| Command                              | Purpose                                                                 |
| ------------------------------------ | ----------------------------------------------------------------------- |
| `hostname S1`                        | Sets the device name for easy identification.<br>                       |
| `enable secret <password>`           | Sets a strong, encrypted password for privileged EXEC mode.             |
| `line console 0`                     | Enters console port configuration mode.                                 |
| `line vty 0 15`                      | Enters configuration for remote access lines.                           |
| `password <password>` / `login`      | Sets and requires a password for remote Telnet/SSH access.              |
| `banner motd "#..."`                 | Sets a "Message of the Day" banner to warn unauthorized users.          |
| `copy running-config startup-config` | Saves the active configuration to make it permanent.                    |
| `password <password>` / `login`      | Sets and requires a password for physical console access.               |
| `service password-encryption`        | Encrypts all plaintext passwords (like console/vty) in the config file. |
| `no ip domain-lookup`                | Prevents the IOS from trying to resolve typos as domain names.          |
## See Also 
- [[Configuring SSH on a Switch]] 
- [[Running-Config vs Startup-Config]] 
- [[Cisco IOS Modes]]