---
tags:
  - concept
  - api
  - networking
  - performance
category: web-development
status:
  - learning
related: "[[REST]]"
---

# Underfetching
## 📝 One-Sentence Summary
*Underfetching is an API inefficiency where a single endpoint doesn't provide enough data, forcing the client to make multiple additional requests to fetch everything it needs for one view.*
## 💡 Analogy
*It's like ordering a **burger combo**, but the API only gives you the burger (`/api/burger/1`). You then have to make a separate request for the fries (`/api/fries/1`) and another separate request for the drink (`/api/drink/1`). It's inefficient and slow.*
## 🔑 Key Details
- **What it is:** 
	- A performance issue where a client must make multiple API calls to different endpoints to gather all the information required to render a single view.
- **Why it exists:** 
	- A strict, resource-oriented [[REST]] API might have separate endpoints for `/user/1`, `/user/1/posts`, and `/user/1/friends`. To build a user's profile page, the frontend would have to make three separate requests.
## 🔗 Connections & Implementations
*This is the other main problem (along with [[Overfetching]]) that [[GraphQL]] (which lets you query related data in one go) and [[BFF|Backend for Frontend (BFF)]] (which combines the calls on the server-side) are designed to solve.*
## 👍 Pros & 👎 Cons
- **❌ Cons:** Creates a "waterfall" of network requests, making the application feel slow. Increases server load (more HTTP requests). Makes frontend code more complex, as it has to manage multiple asynchronous calls and combine the data.
## See Also
- [[Overfetching]]
- [[GraphQL]]
- [[BFF|Backend for Frontend (BFF)]]
- [[REST]]