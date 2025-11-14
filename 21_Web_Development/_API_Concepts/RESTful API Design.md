---
tags:
  - concept
  - api
  - rest
  - design-pattern
category: web-development
status:
  - learning
related: "[[REST]]"
date: 2025-11-13
---

# RESTful API Design
## 📝 One-Sentence Summary
*A set of best practices and conventions for designing [[REST]] APIs to be consistent, scalable, efficient, and easy for other developers to consume.*
## 💡 Analogy
*If [[REST]] is the **style** of architecture (like "Modernism"), then RESTful API Design is the **building code and blueprint**. It dictates that all doors should be the same height (consistency), all rooms should be clearly labeled (documentation), and the building should have a security desk (rate limiting) and a fire exit plan (error handling).*
## 🔑 Key Details
- **What it is:** 
	- A list of "good practices" that go beyond the basic definition of REST to create a high-quality, developer-friendly API.
- **Why it exists:** 
	- To ensure the API is predictable, stable, and easy to use.
## 🔗 Connections & Implementations
### Key Design Principles
* **Keep Consistency:** Use consistent naming conventions. A common practice is using plural nouns for resources (e.g., `/users`, `/products`, not `/user` and `/products`). Keep JSON responses in a standard format (e.g., `{"data": [...]}` or `{"error": "..."}`).
* **Use Caching:** Implement caching with HTTP headers like `Cache-Control` and `ETag` to reduce server load and improve response times.
* **Documentation:** Document your API using a standard like `[[OpenAPI (Swagger)]]`. This generates interactive documentation so frontend developers know exactly which endpoints exist and what data to send.
* **Handle Over/Underfetching:** Be aware of this common limitation.
    * **Overfetching:** A single endpoint returns too much information (e.g., `/users/1` returns the user's entire post history when you only needed their name).
    * **Underfetching:** Requiring too many separate API calls to build one view (e.g., calling `/users/1`, then `/users/1/posts`, then `/users/1/comments`).
    * This is solved by patterns like `[[Backend for Frontend (BFF)]]` or using `[[GraphQL]]`.
* **Statelessness:** Adhere to the REST principle that every request from a client must be independent and contain all information needed to be processed. The server should not store client session state.
## See Also
- [[REST]]
- [[_Web Apis]]
- [[BFF|Backend for Frontend (BFF)]]
- [[OpenAPI (Swagger)]]
- [[Web Caching]]
- [[Rate Limiting]]