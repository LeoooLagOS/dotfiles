---
tags:
  - concept
  - networking
  - configuration
  - router
  - command
category: networking
status:
  - learning
related: "[[IP Address]]"
date: 2025-10-06
---

# Configuring Router Interfaces

## 📝 One-Sentence Summary
*To make a router interface operational, you must assign it an IP address and activate it using the `no shutdown` command.*

## 💡 Analogy
*Configuring a router interface is like setting up a new telephone line in an office. You must first **assign it a unique phone number** (the `ip address`), and then you have to **activate the line** with the phone company (the `no shutdown` command). Without both, the phone won't work.*

## 🔑 Key Details
- **What it is:** 
	- The process of enabling a physical or virtual interface on a router so it can participate in a network. 
- **Why it exists:** 
	- Unlike switch ports which are enabled by default, router interfaces are disabled by default for security. They must be explicitly configured and enabled to route packets.

## 🔗 Connections & Implementations

*This is the primary function that allows a router to connect different networks.
### Core Configuration Steps
1.  **Select the Interface:** `interface <type-and-number>` (e.g., `interface gigabitethernet 0/0/0`)
2.  **(Optional) Add a Description:** `description <text>` (e.g., `description Link to LAN-10`)
3.  **Assign an IP Address:** `ip address <ip-address> <subnet-mask>`
4.  **Activate the Interface:** `no shutdown`

### Example
```cisco
R1(config)# interface gigabitethernet 0/0/0
R1(config-if)# description Link to LAN 1
R1(config-if)# ip address 192.168.10.1 255.255.255.0
R1(config-if)# ipv6 address 2001:db8:acad:1::1/64
R1(config-if)# no shutdown
````

## See Also

- [[IP Address]]
    
- [[Subnet Mask]]
    
- [[Loopback Interface]]