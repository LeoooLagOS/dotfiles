---
tags:
  - concept
  - networking
category: networking
status:
  - learning
related: "[[BDPU (Bridge Protocol Data Unit)]]"
date: 2025-09-23
---

# Bridge ID (BID)

## 📝 One-Sentence Summary
*The Bridge ID is the unique identifier a switch uses in the [[Spanning Tree Protocol (STP)]] election process, where the switch with the numerically lowest BID becomes the [[Root Bridge]].
## 💡 Analogy
*Think of the BID as a candidate's **ranking number** in an election. The number is calculated from a combination of factors, and the candidate with the absolute lowest number wins.de."*

## 🔑 Key Details
- **What it is:** A value that uniquely identifies each switch. It is composed of three parts, evaluated in order: 
	1. **Bridge Priority:** A configurable number from 0 to 61440 (in increments of 4096). The default is **32768**. A lower value is preferred. 
	2. **Extended System ID:** The [[VLAN]] ID. This value is added to the priority (e.g., Priority 32768 for VLAN 10 becomes 32778). This allows for per-VLAN spanning trees. 
	3. **MAC Address:** If the priority and Extended System ID are identical between switches, the switch with the lowest MAC address (in hexadecimal value) becomes the tie-breaker. 
- **Why it exists:** To provide a clear and deterministic way to elect a single [[Root Bridge]] in the network.

## 🔗 Connections & Implementations
* The BID is carried within [[BPDU (Bridge Protocol Data Unit)]] frames. 
* The primary purpose of the BID is to elect the [[Root Bridge]]. 
* Administrators can manipulate the **Bridge Priority** to influence the election and ensure a specific, powerful switch becomes the root.

## See Also
- [[Root Bridge]] 
- [[BPDU (Bridge Protocol Data Unit)]] 
- [[MAC Address]] 
- [[VLAN]]