---
tags:
  - cli
  - troubleshooting
  - networking
  - linux
  - tool
category: os
status: learning
related: "[[Network Troubleshooting]]"
date: 2025-11-24
---
# Route Tracing (Traceroute & Tracepath)
## 📝 One-Sentence Summary
*Utilities that map the path packets take across the internet by listing every router (hop) between your machine and the destination.*
## 💡 Analogy
* **Ping:** Checking if a friend is home.
* **Traceroute:** Tracking every bus stop you pass to get to your friend's house to see where the traffic jam is.
## ⚙️ The Tools
### 1. `traceroute`
* **Usage:** `traceroute google.com`
* **Mechanism:** Sends packets with increasing TTL (Time To Live). When the TTL expires at a router, that router sends back an error, identifying itself.
* **Note:** Often installed separately (`yum install traceroute`).

### 2. `tracepath`
* **Usage:** `tracepath ya.ru`
* **Difference:** Simpler, installed by default on many modern distros, and doesn't require root privileges. It also discovers the **MTU** (Maximum Transmission Unit) along the path.

## 🔗 Connections & Implementations
* **Stars (`* * *`):** If you see rows of asterisks, it means that router is configured to ignore or drop the packets `traceroute` sends (often a firewall).
## See Also
- [[Network Troubleshooting]] (for `mtr`)