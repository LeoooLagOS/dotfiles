---
tags:
  - concept
  - networking
  - command
  - configuration
category: networking
status:
  - learning
related: "[[VLAN]]"
date: 2025-09-30
---

# VLAN Configuration

## 📝 One-Sentence Summary
*[[VLAN]] configuration involves creating the VLANs in the switch database, assigning ports to them, and securing unused ports.*

## 💡 Analogy
*This is like **setting up different departments in a new office building**. First, you create the departments on the floor plan (`vlan 10`, `name Management`). Then, you assign specific offices (ports) to each department (`switchport access vlan 20`). Finally, you lock all the unused offices (`shutdown`) and assign them to a non-production department (`Parking_Lot VLAN`).*
## 🔑 Key Details
- **What it is:** 
	- The process of logically segmenting a switch into multiple broadcast domains. 
- **Why it exists:** 
	- To improve security, organize network traffic, and increase performance by limiting the scope of broadcast traffic. 
- **Best Practice:** 
	- A "Parking Lot" VLAN is an unused, non-production VLAN. All unused ports should be assigned to this VLAN and administratively shut down to prevent unauthorized devices from gaining access to the network.

## 🔗 Connections & Implementations
* Once VLANs are created, a [[Switch Management Interface (SVI)]] can be configured for remote access. 
* The `interface range` command is a highly efficient tool for configuring multiple ports at once.
### Command Sequence 
1. **Create and Name VLANs:** 
``` cisco 
S1(config)# vlan 10 
S1(config-vlan)# name Management 
S1(config)# vlan 999 
S1(config-vlan)# name Parking_Lot 
``` 
2. **Assign Ports to a Data VLAN:** 
``` cisco 
S1(config)# interface f0/6 
S1(config-if)# switchport mode access 
S1(config-if)# switchport access vlan 20 
``` 
3. **Secure Unused Ports:** 
``` cisco 
S1(config)# interface range f0/7 - 24 
S1(config-if-range)# switchport access vlan 999 
S1(config-if-range)# shutdown 
``` 
4. **Verification:** 
``` cisco 
S1# show vlan brief 
``` 
## See Also 
- [[VLAN]]
- [[Trunk Configuration]]
- [[Switch Management Interface (SVI)]]