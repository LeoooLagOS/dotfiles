---
tags:
  - concept
  - api
  - backend
  - architecture
  - bff
  - microservices
category: web-development
status:
  - learning
related: "[[_Web Apis]]"
date: 2025-11-13
---

# Backend for Frontend (BFF)
## 📝 One-Sentence Summary
*A Backend for Frontend (BFF) is an architectural pattern where a dedicated backend server is built to serve a *specific* frontend application, acting as a middle-layer between the client and general-purpose microservices.*
## 💡 Analogy
*Think of general microservices as a **huge warehouse** (like Costco) with bulk items. A BFF is a **personal shopper**. Your mobile app gives its shopper a simple list ("I need 3 things"). The shopper (BFF) goes all over the warehouse, gathers the items, unboxes them, and bundles them into a single, neat bag *perfectly* formatted for the mobile app. Your web app has its *own* personal shopper (a different BFF) who does the same for its specific needs.*
## 🔑 Key Details
- **What it is:** 
	- A server-side component (an API) that aggregates data from multiple downstream services (like microservices or third-party APIs) into a single response optimized for one, and only one, client.
- **Why it exists:** 
	- It solves the "one-size-fits-all" API problem. A mobile app may need less data and different formats than a web app. Instead of the client making 5 calls (underfetching) or getting too much data (overfetching), the BFF handles this complexity on the server side.
## 🔗 Connections & Implementations
* **BFF vs. General REST API:** A general REST API (`/api/v1/users`) serves the same data to everyone. A BFF provides client-specific endpoints (`/api/mobile/dashboard`) that are optimized for a particular view in the app.
* This pattern is extremely common in **microservice architectures**.
* The BFF is often built and maintained by the same team that builds the frontend, as it's part of the "frontend experience."
* An **"Endpoint for Frontend (EFF)"** is a simpler version of this pattern, where instead of a whole separate server, you just create a few specific endpoints on your main API for the same purpose.
## 👍 Pros & 👎 Cons
-   **✅ Pros:** 
	- Optimized data responses for each client, simpler frontend logic (fewer API calls), the "real" backend is insulated from frontend changes, teams can work independently.
-   **❌ Cons:** 
	- Adds another service to build, deploy, and maintain. Can lead to some code duplication between different BFFs.
## See Also
- [[_Web Apis]]
- [[Microservices]]
- [[REST]]
- [[EFF|Endpoint for Frontend (EFF)]]
