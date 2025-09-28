---
tags:
  - concept
  - networking
  - layer-1
category: networking
status:
  - learning
related: "[[Duplex Communication]]"
date: 2025-09-26
---

# Autonegotiaton

## 📝 One-Sentence Summary
*Autonegotiation is a feature where two connected network devices automatically exchange information to agree upon the best possible common settings for speed and [[Duplex Communication|duplex mode]].

## 💡 Analogy
*Imagine two diplomats who can each speak multiple languages. When they meet, instead of being told which language to use, they have a quick chat to discover the best, most advanced language they both know fluently and then proceed to use it for their main conversation.
## 🔑 Key Details
- **What it is:** 
	- An optional function of the Fast Ethernet standard (IEEE 802.3u) that allows devices to automatically select the highest performance mode of operation they both support. 
- **Why it exists:** 
	- To simplify network setup. It allows a device to be connected to a port without the administrator needing to manually configure the port's speed and duplex settings, which is the default behavior on modern switches. 
- **Common Issues:** 
	- The most frequent problem with autonegotiation is a **duplex mismatch**. This often occurs if one side of a link is manually configured (e.g., to `100/full`) and the other side is left to autonegotiate. The autonegotiating side may fail to correctly detect the duplex setting and fall back to half-duplex, leading to severe performance issues.

## 🔗 Connections & Implementations
* When autonegotiation fails, an administrator must intervene by [[Configuring Switch Port Speed and Duplex]] manually on both ends of the link. 
* This process determines the operational state for [[Duplex Communication]] (either half or full).
## 👍 Pros & 👎 Cons
* **Pro:** 
	* Simplifies configuration and makes connecting devices plug-and-play. 
* **Con:** 
	* Can fail, especially between devices from different vendors or when one side is manually configured, leading to performance-killing duplex mismatches.

## See Also
- [[Duplex Communication]] 
- [[Configuring Switch Port Speed and Duplex]]