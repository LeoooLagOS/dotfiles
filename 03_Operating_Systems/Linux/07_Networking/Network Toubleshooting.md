---
tags:
  - tool
  - linux
  - networking
  - troubleshooting
  - cli
category: os
status: learning
related: "[[Network Configuration]]"
date: 2025-11-24
---
# Network Troubleshooting (ping, ss, mtr)
## 📝 One-Sentence Summary
*A suite of command-line tools used to verify connectivity (`ping`), trace paths (`mtr`), and inspect active network sockets (`ss`).*
## ⚙️ Core Tools
### 1. `ping` (Connectivity)
* **Usage:** `ping google.com`
* **Purpose:** Sends [[ICMP]] Echo Requests to verify if a host is reachable and measure latency ([[RTT]]).
* **Linux vs Windows:** On Linux, `ping` runs **forever** until you stop it (`Ctrl+C`). On Windows, it stops after 4 tries.

### 2. `ss` (Socket Statistics)
* **Replaces:** `netstat`
* **Purpose:** Shows which ports are open and listening on your machine.
* **Key Flags:** `-tulpn` (The "Tulip" mnemonic).
    * **t**: TCP
    * **u**: UDP
    * **l**: Listening sockets
    * **p**: Show Process name/PID (requires sudo)
    * **n**: Numeric (don't resolve port names like '80' to 'http')
* **Example:** `sudo ss -tulpn` (Show me exactly what ports are open and what program opened them).

### 3. `mtr` (My Traceroute)
* **Replaces:** `traceroute`
* **Purpose:** Combines `ping` and `traceroute` into a real-time, dynamic display. It shows packet loss at every hop along the path.

## 🔗 Connections & Implementations
* **Troubleshooting Workflow:**
    1.  `ip a`: Do I have an IP?
    2.  `ping 8.8.8.8`: Can I reach the internet?
    3.  `ping google.com`: Is DNS working?
    4.  `ss -tulpn`: Is my web server actually listening on port 80?
## See Also
- [[Network Configuration]]
- [[DNS Configuration]]