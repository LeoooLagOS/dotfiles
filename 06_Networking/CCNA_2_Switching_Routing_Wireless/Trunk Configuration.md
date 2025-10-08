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

# Trunk Configuration

## 📝 One-Sentence Summary
*A trunk is a point-to-point link that carries traffic for multiple [[VLAN|VLANs]] between switches, configured by setting the port mode, defining the native VLAN, and specifying the allowed VLANs.*

## 💡 Analogy
*A trunk is like a **multi-lane highway for a cargo truck**. Each lane (`allowed vlan`) is designated for a specific type of cargo (VLAN traffic). The truck driver (the switch) knows which lane to use for each box. 
The **native VLAN** is like a special, unlabeled lane for local maintenance vehicles that everyone knows belongs to the highway authority.*

## 🔑 Key Details
- **What it is:** 
	- A port configured to carry tagged frames (usually IEEE 802.1Q) to identify which VLAN the traffic belongs to. 
- **Why it exists:** 
	- To allow VLANs to span across multiple physical switches. 
- **Configuration Elements:** 
	- **Mode:** `switchport mode trunk` manually forces the port into a trunking state. 
	- **Native VLAN:** `switchport trunk native vlan <vlan-id>` specifies which VLAN will carry untagged traffic. It must match on both ends of the link. 
	- **Allowed VLANs:** `switchport trunk allowed vlan <vlan-list>` controls which VLANs are permitted to cross the trunk, enhancing security and efficiency.

## 🔗 Connections & Implementations
* Trunk links are the backbone that connects different switch segments in a [[VLAN Configuration]]. 
* Trunks can be bundled together into an [[EtherChannel]] for higher bandwidth and redundancy.
### Command Sequence
```cisco
S1(config)# interface range f0/1-2
S1(config-if-range)# switchport mode trunk
S1(config-if-range)# switchport trunk native vlan 1000
S1(config-if-range)# switchport trunk allowed vlan 10,20,1000
````

### Verification

Cisco CLI

```
S1# show interfaces trunk
```

## See Also

- [[VLAN]]
    
- [[EtherChannel]]
    
- [[802.1Q]]