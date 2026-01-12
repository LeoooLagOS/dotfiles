---
tags: concept
category: cs-fundamental, networking
status: learning
related: "[[Communication Models]]"
date: 2026-01-12
---
# Client-Server Model

## 📝 One-Sentence Summary
A distributed application architecture that partitions tasks between providers of a service (servers) and service requesters (clients).

## 💡 Analogy
A **Restaurant Kitchen**: The Waiter (Client) submits a ticket (Request) for a specific dish. The Kitchen (Server) uses its specialized equipment and ingredients to prepare the meal and sends it back. The client doesn't need to know how the stove works.

## 🔑 Key Details
- **What it is:** A centralized model where servers host resources that are accessed by multiple remote clients.
- **Why it exists:** Centralized security, easier management of shared data, and offloading heavy processing from low-power client devices.

## 🔗 Connections & Implementations
- **Web:** HTTP/HTTPS protocols.
- **Administration:** SSH (Secure Shell) protocol.
- **Architecture:** Foundational for [[_Distributed Systems]].

## 👍 Pros & 👎 Cons
- **Pros:** Centralized data backups, higher security, easier to scale the server hardware.
- **Cons:** **Single Point of Failure**—if the server goes down, the entire system is paralyzed.

## See Also
[[P2P Networking]]