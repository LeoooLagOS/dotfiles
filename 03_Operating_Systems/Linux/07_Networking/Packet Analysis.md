---
tags:
  - cli
  - monitoring
  - security
  - networking
  - linux
  - tool
category: os
status: learning
related: "[[Network Troubleshooting]]"
date: 2025-11-24
---
# Packet Analysis (Tcpdump & Netstat)
## 📝 One-Sentence Summary
*Tools for monitoring active network connections (`netstat`) and capturing raw data packets off the wire (`tcpdump`) for deep analysis.*
## ⚙️ `netstat` (Network Statistics)
* **Status:** Legacy (Superseded by `[[Network Troubleshooting|ss]]`), but ubiquitous.
* **Purpose:** Displays open ports, routing tables, and active connections.
* **Key Flags:** `-ant` or `-nltp`
    * **a**: All sockets.
    * **n**: Numeric (don't resolve '80' to 'http').
    * **t**: TCP only.
    * **p**: Program/PID (Show which app opened the port).
    * **l**: Listening ports only.
* **Example:** `sudo netstat -nlpt` (Shows active servers listening for connections).

## ⚙️ `tcpdump` (The Sniffer)
* **Purpose:** Captures and describes the contents of packets passing through a network interface.
* **Analogy:** **Wiretapping.** You are recording the actual conversation passing through the cable.
* **Syntax:** `tcpdump [options] [filter_expression]`
* **Cheatsheet:**
    * `tcpdump -i eth0`: Listen on interface `eth0`.
    * `tcpdump host 1.2.3.4`: Only show traffic to/from this IP.
    * `tcpdump port 80 -w capture.pcap`: Capture web traffic and **write** it to a file (readable by Wireshark).
    * **Complex Filter:**
      `tcpdump 'src 10.0.2.4 and (dst port 3389 or 22)'`
      *(Traffic FROM 10.0.2.4 going TO RDP or SSH ports).*

## See Also
- [[Network Troubleshooting]] (for `ss`)
- [[Network Configuration]]