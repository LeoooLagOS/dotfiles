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
# Remote Route

## 📝 One-Sentence Summary
*A remote route is an entry in the [[Routing Table]] for a network that is not directly connected to the router, which must be learned either manually (statically) or automatically (dynamically).

## 💡 Analogy
*These are the **"Cross-Town" or "Interstate"** directions in the router's GPS. The router doesn't know about these destinations by default; someone (an administrator or another router) must provide the information on how to reach them.

## 🔑 Key Details
-   **What it is:** 
	- A network destination that is not on one of the router's own interfaces. To reach it, the router must forward the packet to another router (a "next-hop").
-   **Why it exists:** 
	- To allow routers to build a map of the entire network topology, not just the networks they are physically attached to.
-   **Two Ways to Learn:**
    1.  **Static Routes:** A network administrator manually configures the route.
    2.  **Dynamic Routing Protocols:** The router automatically learns about remote networks by communicating with other routers using protocols like [[OSPF]] or [[EIGRP]].

## 🔗 Connections & Implementations
*When a router's [[Packet Forwarding Decision Process]] matches a remote route, it forwards the packet to the specified next-hop router.

## See Also
-   [[Routing Table]]
-   [[Directly Connected Route]]
-   [[Default Route]]
-   [[OSPF]]
-   [[EIGRP]]