---
tags:
  - concept
  - networking
  - ipv6
category: networking
status: learning
related: "[[IPv6]]"
date: 2025-11-11
---
# SLAAC (Stateless Address Autoconfiguration)

## 📝 One-Sentence Summary
*SLAAC is an [[IPv6]] method that allows a host device to automatically create its own unique IP address by combining a network prefix (learned from a [[Router]]) with its own interface identifier (often derived from its [[MAC Address]]).

## 💡 Analogy
*It's like a city government (`Router`) posting the **street name and zip code** (`2001:ABC:FCE:1::/64`) on a sign at the entrance to a new neighborhood. Each house (host) then **builds its own house number** (the interface ID) and combines it with the street name to create its full, unique address.

## 🔑 Key Details
-   **What it is:** 
	- A "stateless" [[IPv6]] addressing method. "Stateless" means no server is required to keep track of which address is assigned to which device.
-   **Why it exists:** 
	- To dramatically simplify [[IPv6]] addressing and network administration. Devices can get online and communicate without needing a DHCP server.
-   **Process:**
    1.  The [[Router]] sends out **Router Advertisement (RA)** messages ([[ICMPv6]] type 134) on the network.
    2.  This RA message contains the network prefix (e.g., `2001:ABC:FCE:1::/64`).
    3.  The host device receives this prefix and generates its own 64-bit "host" portion, often using the **EUI-64** method, which converts its 48-bit [[MAC Address]] into a 64-bit ID.

## 🔗 Connections & Implementations
*This contrasts with [[DHCPv6 (Stateful)]], which is a "stateful" method where a server actively manages and leases addresses.*

## See Also
-   [[IPv6]]
-   [[DHCPv6 (Stateful)]]
-   [[ICMPv6]]
-   [[MAC Address]]