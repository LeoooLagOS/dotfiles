---
tags:
  - concept
  - networking
  - configuration
  - ipv6
  - Cisco_IOS
  - ccna
  - command
category: networking
status:
  - learning
related: "[[IPv6]]"
date: 2025-10-09
---

# Enabling IPv6 Routing

## 📝 One-Sentence Summary
*The `ipv6 unicast-routing` command is a mandatory global command that activates a Cisco router's ability to forward IPv6 packets between its interfaces.*

## 💡 Analogy
*This command is like flipping the **main power switch for a city's international airport**. Even if you build all the runways and terminals (`ipv6 address` on interfaces), no international flights (IPv6 packets) can be routed until you turn on the central control tower.*

## 🔑 Key Details
- **What it is:** 
	- A global configuration command that enables IPv6 routing on the device. 
- **Why it exists:** 
	- By default, a Cisco router will not route IPv6 traffic, even if its interfaces are configured with IPv6 addresses. This command must be entered to "turn on" the IPv6 routing process. 
- **Effect:** 
	- Once enabled, the router will begin adding IPv6 connected routes to its routing table and will be able to forward IPv6 packets between different networks.

## 🔗 Connections & Implementations
*This is a prerequisite for any IPv6 routing functionality, including static routing and dynamic routing protocols.
### Command Syntax
```cisco
Router(config)# ipv6 unicast-routing
````

## See Also
- [[Configuring Router Interfaces]]
    
- [[Verifying Routes with show ip route]]