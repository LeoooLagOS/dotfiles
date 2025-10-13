---
tags: concept
category: networking
status:
  - learning
related: "[[Interpreting Interface Status]]"
date: 2025-09-28
---

# Common Interface Errors

## 📝 One-Sentence Summary
*The error counters in the `show interfaces` command output provide critical clues for diagnosing physical ([[1_Physical Layer|Layer 1]]) and data link ([[2_Data Link Layer|Layer 2]]) problems on a network connection.
## 💡 Analogy
Think of these error counters as the specific **diagnostic codes** a car's computer gives a mechanic. A generic "check engine" light ([[Interpreting Interface Status|interface is down]]) tells you there's a problem, but a specific code like "CRC error" or "runt" tells you *exactly* what kind of problem it is, helping you find the root cause much faster.
## 🔑 Key Details
- **What they are:** 
	- Statistics tracked by a network interface that increment each time a specific type of transmission problem occurs. 
- **Why they exist:** 
	- To help network administrators identify and resolve performance issues that may not be severe enough to bring the entire link down. Monitoring these counters is a key part of any [[Troubleshooting Methodology]].

## 🔗 Connections & Implementations
*These errors are viewed using the `show interfaces` command, which is one of the [[Common Switch Verification Commands]].
Unordered, uses more memory.*

### Key Error Types and Causes
| Error Type                        | Description                                                          | Common Causes                                                             |
| --------------------------------- | -------------------------------------------------------------------- | ------------------------------------------------------------------------- |
| **Runts**                         | Frames smaller than the 64-byte minimum.                             | Duplex Mismatch, faulty NIC, software issues.                             |
| **Giants**                        | Frames larger than the 1,518-byte maximum.                           | Faulty NIC, software issues.                                              |
| **CRC** (Cyclic Redundancy Check) | The checksum calculated by the receiver does not match the one sent. | Bad or damaged cable, electromagnetic interference (EMI), faulty NIC.     |
| **Collisions**                    | Two devices transmit at the same time on a shared medium.            | Expected on half-duplex links. High numbers indicate a saturated network. |
| **Late Collisions**               | A collision that occurs after the first 64 bytes have been sent.     | **Duplex Mismatch**, faulty NIC, Ethernet cable is too long.              |
## See Also
- [[Interpreting Interface Status]] 
- [[Duplex Communication]] 
- [[Troubleshooting Methodology]]