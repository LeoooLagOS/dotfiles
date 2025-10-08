---
tags:
  - concept
  - networking
  - security
  - command
  - configuration
category: networking
status:
  - learning
related: "[[CISCO IOS Modes]]"
date: 2025-09-30
---

# Switch Security Configuration

## 📝 One-Sentence Summary
*This is the foundational set of commands applied to a new switch to establish a baseline of security, including setting a hostname, creating passwords, encrypting them, and displaying a legal banner.
## 💡 Analogy
*Think of this as **changing the locks and setting up the security system** for a new house. You're replacing the generic factory keys, adding a password to the main security panel, and putting a "No Trespassing" sign on the front lawn before you even start moving furniture in.*

## 🔑 Key Details
- **What it is:** 
	- A standard operating procedure for hardening a Cisco switch before it is deployed on a network. 
- **Why it exists:** 
	- To protect the device from unauthorized access and to create a professional and manageable configuration environment. These steps are considered the bare minimum for device security.

## 🔗 Connections & Implementations
*This procedure involves securing different [[Cisco IOS Modes]] and access methods like the console and [[VTY Lines]].

### Command Sequence
| Command                       | Purpose                                                        |
| ----------------------------- | -------------------------------------------------------------- |
| `hostname S1`                 | Sets the device name for easy identification.                  |
| `no ip domain-lookup`         | Prevents the IOS from trying to resolve typos as domain names. |
| `enable secret class`         | Sets a strong, encrypted password for privileged EXEC mode.    |
| `line console 0`              | Enters console port configuration mode.                        |
| `password cisco` / `login`    | Sets and requires a password for console access.               |
| `line vty 0 15`               | Enters configuration for remote access lines.                  |
| `password cisco` / `login`    | Sets and requires a password for remote Telnet/SSH access.     |
| `service password-encryption` | Encrypts all plaintext passwords in the configuration file.    |
| `banner motd "..."            | Sets a "Message of the Day" banner to warn users.              |
| `clock set ...`               | Manually sets the system time, which is crucial for logging.   |

## See Also
- [[VLAN Configuration]] 
- [[SSH]]
- [[Running-Config vs Startup-Config]]