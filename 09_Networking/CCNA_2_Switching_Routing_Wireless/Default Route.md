---
tags:
  - concept
  - networking
  - routing
category: networking
status: learning
related: "[[Routing Table]]"
date: 2025-11-07
---
# Default Route

## 📝 One-Sentence Summary
*A default route, or "Gateway of Last Resort," is a special route that tells a router where to send a packet if it does not have a specific or longer match in its [[Routing Table]].

## 💡 Analogy
*A default route is the **"Send to Head Office"** instruction for a mailroom. If the mail sorter finds a letter with a zip code they don't recognize, they don't just drop it; they send it to the central head office (the next-hop router) and let *them* figure it out.

## 🔑 Key Details
- **What it is:** 
	- A "catch-all" route that matches any destination. It is the shortest possible match (a prefix length of 0).
- **Why it exists:** 
	- It is highly inefficient to store all routes for the entire internet on one router. A default route allows a router to simply forward all unknown traffic to an upstream provider or main router.
-   **Prefixes:**
    -   **IPv4:** `0.0.0.0/0`
    -   **IPv6:** `::/0`
- **How it's used:** 
	- If a router performs a lookup, finds no match, and has a default route, it forwards the packet to the default route's next-hop. If there is no match and *no* default route, the [[Packet Forwarding Decision Process]] is to drop the packet.

## See Also
-   [[Routing Table]]
-   [[Longest Match Rule]]
-   [[Packet Forwarding Decision Process]]