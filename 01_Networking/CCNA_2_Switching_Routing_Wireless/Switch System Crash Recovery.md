---
tags:
  - concept
  - networking
  - procedure
category: networking
status:
  - learning
related: "[[Switch Boot Sequence]]"
date: 2025-09-17
---

# Switch System Crash Recovery

## 📝 One-Sentence Summary
*This is a manual procedure to interrupt the normal [[Switch Boot Sequence]] to access the [[Boot Loader]] environment, which is used for recovery tasks like resetting a password or loading a new [[Cisco IOS]] image.
## 💡 Analogy
*It's the equivalent of starting a computer in **"Safe Mode"** or accessing the BIOS/UEFI. You are stopping the full operating system from loading to perform low-level maintenance from a basic command prompt.
## 🔑 Key Details
- **What it is:** A recovery process that grants access to the `switch:` prompt provided by the [[Boot Loader]]. The key steps are: 
	1. Connect a PC to the switch's [[Console Port]]. 
	2. Power cycle the switch. 
	3. Within 15 seconds of power-on, **press and hold the Mode button**. 
	4. Release the button when the System LED turns amber. 
	5. This action drops the switch into the boot loader prompt (`switch:`) on your console session. 
- **Why it exists:** To provide a last-resort method for an administrator to recover a switch from a critical software failure, such as a corrupt or missing IOS file, or to perform a password recovery.
## 🔗 Connections & Implementations
*From the `switch:` prompt, you can use commands to format the [[Flash Memory]], change the boot variable, or load a new IOS image from a TFTP server. 
*This procedure directly manipulates the [[Switch Boot Sequence]].
## See Also
- [[Boot Loader]] 
- [[Console Port]] 
- [[Cisco IOS]]