---
tags:
  - concept
  - networking
  - command
  - verification
category: networking
status:
  - learning
related: "[[Port Security]]"
date: 2025-10-14
---

# Verifying Port Security

## 📝 One-Sentence Summary
*A set of `show` commands used to verify the configuration, operational status, and learned addresses of the [[Port Security]] feature on a switch.*
## 💡 Analogy
*These are the **security camera feeds and logs** that the club manager uses to check on the bouncer's work. They can get a quick summary (`show port-security`), zoom in on one door (`... interface`), view the official guest list (`... address`), and check the written instructions (`show run`).*
## 🔑 Key Details
- **What they are:** 
	- A suite of verification commands used in privileged EXEC mode to monitor and troubleshoot port security.
- **Why they exist:** 
	- To allow an administrator to confirm that port security is enabled as expected, see which MAC addresses have been secured, and check for any security violations.

## 🔗 Connections & Implementations
*These commands are essential for confirming the settings of [[Port Security]], [[Port Security MAC Address Modes]], and [[Port Security Violation Modes]].
### Key Verification Commands 

| Command                                  | Purpose                                                                                                                 |
| :--------------------------------------- | :---------------------------------------------------------------------------------------------------------------------- |
| **`show port-security`**                 | Displays a high-level summary of port security status for all interfaces.                                               |
| **`show port-security interface <id>`**  | Shows all detailed port security settings for a single, specific interface.                                             |
| **`show port-security address`**         | Displays a table of all secure MAC addresses on the switch, including their type and assigned port.                     |
| **`show running-config interface <id>`** | Shows the commands applied to the interface, including any "sticky" MAC addresses that have been written to the config. |
## See Also 
- [[Port Security]] 
- [[Common Switch Verification Commands]]