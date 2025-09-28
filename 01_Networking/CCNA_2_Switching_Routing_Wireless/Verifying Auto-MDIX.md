---
tags:
  - concept
  - networking
  - command
  - verification
category: networking
status:
  - learning
related: "[[Auto-MDIX]]"
date: 2025-09-26
---

# Verifying Auto-MDIX

## 📝 One-Sentence Summary
*The `show controllers ethernet-controller` command is used to display the low-level hardware status of a specific interface, including whether [[Auto-MDIX]] is operationally active.

## 💡 Analogy
* This is like using a voltmeter to check the output of your universal power adapter. You aren't just trusting that it's working; you are using a specialized tool to verify its exact operational state.

## 🔑 Key Details
- **What it is:** 
	- A command that provides a detailed report on the physical layer (PHY) hardware controller for an interface. 
- **Why it exists:** 
	- To allow administrators to troubleshoot and verify low-level hardware features that are not displayed in the standard `show interfaces` command output.
## 🔗 Connections & Implementations

*This is the primary command for checking the status of `[[Auto-MDIX]]`.
* **Verification Command:**
```cisco
S1# show controllers ethernet-controller fa0/1 phy | include MDIX

Auto-MDIX           : On   [AdminState=1  Flags=0x00052248]
````

*The pipe `|` and `include MDIX` filter the lengthy output to show only the line containing "MDIX", making it easy to read.

## See Also

- [[Auto-MDIX]]
    
- [[Piping Commands (IOS)]]