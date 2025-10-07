---
tags:
  - concept
  - networking
  - configuration
  - Cisco_IOS
  - lab
  - command
category: networking
status:
  - learning
related: "[[DHCPv4]]"
date: 2025-10-06
---

# Configuring a Cisco IOS DHCPv4 Server

## 📝 One-Sentence Summary
*A Cisco router can be configured as a DHCPv4 server by excluding specific addresses, creating a named address pool, and then defining the network parameters for that pool.*
## 💡 Analogy
*This is like **setting the rules for a hotel's front desk**. You tell the clerk which rooms are for staff and cannot be given out (`excluded-address`), which block of rooms are for standard guests (`ip dhcp pool`), the location of the main exit (`default-router`), and the number for room service (`dns-server`).*
## 🔑 Key Details
- **What it is:** 
	- The procedure for enabling and configuring the DHCP server feature on a [[Cisco IOS]] router. 
- **Why it exists:** 
	- To provide DHCP services directly from a router, which is common in small to medium-sized networks where a dedicated server is not necessary.

## 🔗 Connections & Implementations
*This is the practical implementation of the server side of [[DHCPv4]].
### Core Configuration Steps

1.  **Exclude Static IP Addresses:**
    * **Purpose:** Reserve specific IP addresses within the range for devices that need a static IP, like the router itself, servers, and printers.
    * **Command:** `ip dhcp excluded-address <low-address> [high-address]`
2.  **Create the DHCP Pool:**
    * **Purpose:** Create a named container for the DHCP configuration.
    * **Command:** `ip dhcp pool <pool-name>`
3.  **Configure Pool Parameters:** (Done in `dhcp-config` mode)
    * **`network <network-id> <subnet-mask>`:** **(Required)** Defines the subnet of addresses the server will lease.
    * **`default-router <ip-address>`:** **(Required)** The default gateway for clients.
    * **`dns-server <ip-address>`:** The IP address of the DNS server(s).
    * **`domain-name <name>`:** The domain name for the network.
    * **`lease {days | infinite}`:** The duration of the IP address lease.

### Example
```cisco
! Reserve the router's address so it's not leased
R1(config)# ip dhcp excluded-address 192.168.10.1
!
! Create and configure the pool
R1(config)# ip dhcp pool LAN-POOL-10
R1(dhcp-config)# network 192.168.10.0 255.255.255.0
R1(dhcp-config)# default-router 192.168.10.1
R1(dhcp-config)# dns-server 8.8.8.8
R1(dhcp-config)# domain-name example.com
````

## See Also

- [[DHCPv4]]