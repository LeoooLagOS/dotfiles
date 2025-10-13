---
tags:
  - concept
  - networking
  - command
  - troubleshooting
  - Cisco_IOS
  - ccna
category: networking
status:
  - learning
related: "[[ICMP]]"
date: 2025-10-08
---

# Verifying Connectivity with Ping

## 📝 One-Sentence Summary
*The `ping` command is a fundamental utility that tests [[3_Network|Layer 3]] connectivity to a destination device by sending an [[ICMP]] echo request and waiting for an echo reply.*
## 💡 Analogy
*Using `ping` is like shouting **"Marco!"** in a large area and waiting to hear **"Polo!"** back. If you hear the reply, you know that the other person is there, they can hear you, and the path between you is clear.*
## 🔑 Key Details
- **What it is:** 
	- A command-line tool that uses the [[ICMP]] protocol to verify end-to-end IP connectivity. 
- **Why it exists:** 
	- It is the primary tool for testing and [[Troubleshooting Methodology|troubleshooting]] the reachability of a host on an [[IP Address]] network. A successful ping confirms that the entire path—the source host's IP stack, its local network, all intermediate routers, the destination's local network, and the destination host's IP stack—is working. 
- **Usage:** 
	- The command is identical for IPv4 and IPv6; you simply provide the appropriate IP address. 
		- `ping 192.168.1.1` 
		- `ping 2001:db8:acad:1::1`

## 🔗 Connections & Implementations
*`ping` is often the first step in any network [[Troubleshooting Methodology]]. A successful `ping` to a default gateway is a common test to verify a host's local network configuration. 
## See Also 
- [[ICMP]] 
- [[Traceroute]] 
- [[Troubleshooting Methodology]]