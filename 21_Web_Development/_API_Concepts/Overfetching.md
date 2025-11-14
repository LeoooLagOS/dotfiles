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
date: 2025-11-13
---
# Overfetching
## 📝 One-Sentence Summary
*Overfetching is an API inefficiency where a client downloads more data than it actually needs from a single endpoint.*
## 💡 Analogy
*It's like ordering a **whole pizza** (`/api/user/1`) just to get **one slice** (the user's name). You got the slice you needed, but you were forced to download the entire pizza (all user data like address, post history, etc.), wasting resources.*
## 🔑 Key Details
- **What it is:** 
	- A performance issue where a single API endpoint returns a large, fixed data structure, forcing the client (especially mobile apps) to receive and parse unnecessary information.
- **Why it exists:** 
	- Often a result of "one-size-fits-all" [[REST]] API design, where an endpoint like `/users/1` is built to serve *all* potential data for a user, even if the client only needs their name.
## 🔗 Connections & Implementations
*This is one of the key problems that [[GraphQL]] (which lets you ask for specific fields) and [[BFF|Backend for Frontend (BFF)]] (which creates an optimized endpoint) are designed to solve.*
## 👍 Pros & 👎 Cons
- **❌ Cons:** Wastes bandwidth, increases mobile data usage, slows down the client application (more data to parse), increases client-side complexity (filtering unneeded data).
## See Also
- [[Underfetching]]
- [[GraphQL]]
- [[BFF|Backend for Frontend (BFF)]]
- [[REST]]