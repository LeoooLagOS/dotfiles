---
tags:
  - concept
  - networking
  - command
  - verification
category: networking
status:
  - learning
related: "[[Cisco IOS Modes]]"
date: 2025-09-27
---

# Common Switch Verification Commands

## 📝 One-Sentence Summary
*The `show` commands are the primary tool used in privileged EXEC mode to monitor and verify the operational status and configuration of a network device without making any changes.

## 💡 Analogy
* Using `show` commands is like looking at the **dashboard of your car**. It provides real-time information about the vehicle's status-speed, fuel level, engine temperature-allowing you to verify its operation without actually altering how it runs.

## 🔑 Key Details
- **What they are:** 
	- A suite of commands available in the [[Cisco IOS Modes|privileged EXEC mode]] (`#`) that display information about the device's hardware, software, and configuration. 
- **Why they exist:** 
	- They are essential for monitoring network health, verifying configurations, and are the first step in any [[Troubleshooting Methodology]].

## 🔗 Connections & Implementations
*These commands are used to view different aspects of a switch's operation, from high-level status to detailed interface statistics.

### Key `show` Commands 
| Command                            | Purpose                                                                       |
| ---------------------------------- | ----------------------------------------------------------------------------- |
| `show running-config`              | Displays the currently active configuration in RAM.                           |
| `show startup-config`              | Displays the backup configuration stored in NVRAM.                            |
| `show interfaces [interface-id]`   | Displays the Layer 1 and Layer 2 status and statistics of network interfaces. |
| `show ip interface [interface-id]` | Displays the Layer 3 (IP) configuration of an interface.                      |
| `show mac-address-table`           | Displays the MAC address forwarding table.                                    |
| `show version`                     | Displays system hardware, software version, and uptime.                       |
| `show flash`                       | Displays the contents of the flash file system.                               |
| `show history`                     | Displays the command history for the current session.                         |
## See Also 
- [[Cisco IOS Modes]] 
- [[Troubleshooting Methodology]]
- [[Running-Config vs Startup-Config]]