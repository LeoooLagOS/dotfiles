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
# Longest Match Rule

## 📝 One-Sentence Summary
*The Longest Match Rule is the process a router uses to find the best path in its [[Routing Table]] by selecting the route with the greatest number of matching far-left bits (the longest prefix) for a given destination [[IP Address]].

## 💡 Analogy
*Imagine you have three sets of directions to a specific building:
    1.  Go to "New York City" (`/8` route)
    2.  Go to "Downtown Manhattan" (`/16` route)
    3.  Go to "123 Main St., Downtown Manhattan" (`/24` route)
*The Longest Match Rule says you must always use the **most specific directions** you have. You would use set #3 because it's the "longest match" and gets you closest to the final destination.

## 🔑 Key Details
-   **What it is:** 
	- The algorithm for searching the routing table. The route with the highest prefix length (e.g., `/26`) that matches the destination IP is always the preferred route over a less specific match (e.g., `/18`).
-   **Why it exists:** 
	- To allow for efficient and hierarchical routing. 
	- A router can have a general [[Default Route]] (`/0`), several summary routes, and many specific routes. This rule ensures the router always uses the most specific information it has.

## See Also
-   [[Routing Table]]
-   [[Packet Forwarding Decision Process]]
-   [[Default Route]]