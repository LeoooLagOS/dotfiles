---
tags:
  - concept
  - networking
  - configuration
  - command
  - redundancy
category: networking
status:
  - learning
related: "[[Trunk Configuration]]"
date: 2025-09-30
---

# EtherChannel

## 📝 One-Sentence Summary
*EtherChannel is a technology that bundles multiple physical switch ports into a single logical link to increase bandwidth and provide redundancy.*

## 💡 Analogy
*Instead of having a single-lane road between two cities, **EtherChannel is like building a multi-lane bridge**. It allows more traffic to flow at once, and if one lane is closed for repairs (a cable fails), traffic can still flow on the other lanes.*

## 🔑 Key Details
- **What it is:** 
	- A port-channeling technology that groups several physical Ethernet links into one logical channel. 
- **Why it exists:** 
	- **Increased Bandwidth:** Aggregates the capacity of all links in the channel. 
	- **Redundancy:** If one physical link fails, traffic is automatically redistributed across the remaining links without disrupting the logical connection. 
- **Protocols:** 
	- **LACP (Link Aggregation Control Protocol):** An open standard (IEEE 802.3ad) that allows switches to negotiate the formation of a channel. Modes are `active` (initiates negotiation) and `passive` (waits for negotiation). 
	- **PAgP (Port Aggregation Protocol):** A Cisco-proprietary protocol.
## 🔗 Connections & Implementations
* EtherChannel is most often used to bundle links that are configured for [[Trunk Configuration]] between switches.

* When an EtherChannel is formed, a virtual **Port-channel interface** is created, and all configuration is applied to this logical interface instead of the individual physical ports.

### LACP Configuration
```cisco
! On both switches
S1(config)# interface range f0/1-2
S1(config-if-range)# channel-group 1 mode active
````

### Verification

Cisco CLI

```
S1# show etherchannel summary
S1# show interfaces trunk
```

## See Also

- [[Trunk Configuration]]
    
- [[LACP]]
    
- [[Spanning Tree Protocol (STP)]]