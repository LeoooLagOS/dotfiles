---
tags:
  - concept
  - networking
  - protocol
category: networking
status:
  - learning
related: "[[STP]]"
date: 2025-09-23
---

# BDPU (Bridge Protocol Data Unit)

## 📝 One-Sentence Summary
*BPDUs are small data frames exchanged between switches that contain the necessary information for the [[STP]] to elect a [[Root Bridge]] and build a loop-free topology.

## 💡 Analogy
*Think of BPDUs as the **ballots and campaign messages** used during an election. Each switch sends out BPDUs to announce its qualifications (its [[Bridge ID (BID)]]) and who it currently supports for president (the Root ID). By comparing these messages, all switches eventually agree on a single winner.

## 🔑 Key Details
- **What it is:** 
	- The messaging framework for STP. Switches send BPDUs out of their ports every two seconds by default. 
- **Why it exists:** 
	- To allow switches in a broadcast domain to share information about themselves and their connections, enabling the Spanning Tree Algorithm (STA) to make decisions. 
- **Key Contents:** 
	- A BPDU frame contains several fields, most importantly the sender's [[Bridge ID (BID)]] and the sender's perceived Root ID (the BID of the switch it believes is the root).

## 🔗 Connections & Implementations
* BPDUs are the fundamental mechanism used by [[STP]] to function. 
* The information within a BPDU, specifically the [[Bridge ID (BID)]], is the deciding factor in all STP elections.
## See Also
- [[STP]] 
- [[Bridge ID (BID)]] 
- [[Root Bridge]]