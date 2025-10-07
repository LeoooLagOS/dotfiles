---
tags:
  - concept
  - networking
  - process
category: networking
status:
  - learning
related: "[[DHCPv4]]"
date: 2025-10-06
---

# DHCPv4 DORA Process

## 📝 One-Sentence Summary
*DORA is the four-step message exchange
—**D**iscover, **O**ffer, **R**equest, **A**cknowledgment—that a client uses to obtain an IP address lease from a [[DHCPv4|DHCPv4 server]].

## 💡 Analogy
*It's like hailing a taxi in a city. 
1. **Discover:** 
	 * You stand on the corner and raise your hand (client sends a broadcast) to signal you need a ride. 
2. **Offer:** 
	* Several taxi drivers (DHCP servers) see you and flash their lights (servers send unicast offers). 
3. **Request:** 
	* You make eye contact with and point to one specific taxi (client broadcasts its choice). 
4. **Acknowledgment:** 
	* That taxi driver pulls over and unlocks the door for you (the chosen server confirms the lease).
## 🔑 Key Details
- **What it is:** 
	- The sequence of messages that allows a client to dynamically obtain an IP address.
- **Why it exists:** 
	- To provide an orderly, broadcast-based process for a new device with no IP address to communicate on the network and get a valid configuration.

### The Four Steps 
1. **DHCP Discover (DHCPDISCOVER):** 
	* The client sends a broadcast frame to find any available DHCPv4 servers on the network. 
2. **DHCP Offer (DHCPOFFER):** 
	* DHCPv4 servers on the network respond to the client with an offer of an IP address lease. 
3. **DHCP Request (DHCPREQUEST):** 
	* The client chooses one of the offers and sends a broadcast message to inform the chosen server that it accepts the offer. 
4. **DHCP Acknowledgment (DHCPACK):** 
	* The chosen server sends a final message to confirm the lease and provides all other configured parameters (gateway, DNS, etc.). 
## See Also 
- [[DHCPv4]]