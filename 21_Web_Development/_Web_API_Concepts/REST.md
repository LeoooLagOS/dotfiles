---
tags:
  - overview
  - concept
  - networking
  - backend
  - api
category: web-development
status:
  - learning
related: "[[HTTP Methods]]"
date: 2025-11-07
---
# REST (Representational State Transfer)
## 📝 One-Sentence Summary
*REST is a software architectural style that uses the standard [[HTTP Methods]] (like GET, POST, PUT, DELETE) to perform CRUD operations on "resources."*
## 💡 Analogy
*A REST API is like a **vending machine**. Each product has a unique address (a URL or "endpoint," like `/product/123`). You use specific buttons (HTTP verbs) to interact with it: `GET` (look at the product), `POST` (add a new product), `PUT` (replace a product), `DELETE` (remove the product).*
## 🔑 Key Details
- **What it is:** 
	- A set of conventions and design constraints for building web services. It is not a strict protocol like SOAP.
- **Why it exists:** 
	- To provide a simple, scalable, and stateless way to build web services that work over the existing infrastructure of the internet (HTTP).
## 🔗 Connections & Implementations
### RESTful Conventions:
* **Resource-Oriented URLs:** URLs should identify resources (e.g., `/user`, `/product`).
* **Use of HTTP Verbs for CRUD:**
    * `GET /user`: Read all users.
    * `GET /user/1`: Read user with ID 1.
    * `POST /user`: Create a new user.
    * `PUT /user/1`: Replace/Update user 1.
    * `DELETE /user/1`: Delete user 1.
* **URL Versioning:** (e.g., `/v1/user`).
* **Standard JSON Responses:** JSON is the de facto standard for data transfer.
* **Stateless:** Each request from the client must contain all information needed by the server to fulfill it. The server does not store client state between requests.
## 👍 Pros & 👎 Cons
-   **✅ Pros:** Simple, flexible, leverages standard HTTP methods, scalable, data format-agnostic (though JSON is standard).
-   **❌ Cons:** Can lead to "over-fetching" (getting more data than needed) or "under-fetching" (requiring multiple requests), which [[GraphQL]] aims to solve.
## See Also
- [[_Web Apis]]
- [[GraphQL]]
- [[HTTP Status Codes]]
- [[CRUD]]