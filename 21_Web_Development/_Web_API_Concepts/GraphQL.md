---
tags:
  - concept
  - api
  - networking
  - backend
category: web-development
status:
  - learning
related: "[[_Web Apis]]"
date: 2025-11-07
---
# GraphQL
## 📝 One-Sentence Summary
*GraphQL is a query language for APIs where the client requests *exactly* the data it needs, no more and no less, typically from a single endpoint.*
## 💡 Analogy
*If a [[REST|REST API ]]is like ordering from a **set menu** (you order "Meal #1" and get the soup, main, and dessert), GraphQL is like a **buffet**. You go to one counter (a single endpoint) and build your plate (the query) asking for "just the steak, double salad, and no soup." You get exactly what you want in one trip.*
## 🔑 Key Details
- **What it is:** 
	- A [[_QL|query language (QL)]] for APIs and a runtime for fulfilling those queries with your existing data.
- **Why it exists:** 
	- To solve the inefficiencies of REST, specifically "over-fetching" (getting extra data) and "under-fetching" (making multiple API calls to get all required data).
## 🔗 Connections & Implementations
* Unlike REST's many endpoints (`/users`, `/products`), GraphQL typically exposes a **single endpoint** (e.g., `/graphql`).
* The client sends a `POST` request with a query structure that mirrors the desired JSON response.
* **Example Query:**
    ```graphql
    query {
      user(id: "1") {
        name
        email
        friends {
          name
        }
      }
    }
    ```
## 👍 Pros & 👎 Cons
-   **✅ Pros:** Highly efficient (no over/under-fetching), strongly-typed (schema), great for complex frontends and mobile apps.
-   **❌ Cons:** More complex to implement on the backend than REST. Caching is more difficult.
## See Also
- [[_Web Apis]]