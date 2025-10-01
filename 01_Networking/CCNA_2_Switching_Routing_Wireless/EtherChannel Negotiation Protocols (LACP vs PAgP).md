---
tags:
  - concept
  - networking
  - protocol
category: networking
status:
  - learning
related: "[[EtherChannel]]"
date: 2025-10-01
---

# EtherChannel Negotiation Protocols (LACP vs PAgP)

## 📝 One-Sentence Summary
**LACP** is the open-standard protocol and **PAgP** is the Cisco-proprietary protocol used to dynamically negotiate the formation of an [[EtherChannel]] link between two switches. 
## 💡 Analogy
* Think of this as the difference between **USB-C** and Apple's **Lightning connector**. 
* **LACP** is like USB-C: an **open standard** that allows devices from many different manufacturers (Cisco, Juniper, HP) to connect and work together. 
* **PAgP** is like the Lightning connector: a **proprietary** technology that works very well, but only between Apple (Cisco) devices.
## 🔑 Key Details
- **What they are:** 
	- Sub-protocols used by [[EtherChannel]] to exchange information and automatically bundle links. 
- **Why they exist:** 
	- To provide a dynamic and safe way to form a channel. If the configuration on one end is not compatible (e.g., wrong speed or duplex), these protocols will prevent the channel from forming incorrectly.

### Mode Comparison
| Protocol | Active Mode | Passive Mode | Will `Passive + Passive` Work? |
| -------- | ----------- | ------------ | ------------------------------ |
| **LACP** | `active`    | `passive`    | ❌ No                           |
| **PAgP** | `desirable` | `auto`       | ❌ No                           |
*For a channel to form, at least one side must be in an **active** mode (`active` or `desirable`) to initiate the negotiation.*
## 🔗 Connections & Implementations
A common [[EtherChannel]] troubleshooting issue is a protocol mismatch (LACP on one side, PAgP on the other) or a mode mismatch (two passive modes).

## See Also
- [[EtherChannel]] 
- [[LACP]] 
- [[PAgP]]