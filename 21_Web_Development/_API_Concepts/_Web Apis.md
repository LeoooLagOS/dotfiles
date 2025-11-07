---
tags:
  - overview
  - concept
  - networking
  - backend
  - api
category: web-development
status: learning
related: "[[HTTP Methods]]"
date: 2025-11-07
---
# _Web Apis_
## 📝 One-Sentence Summary
*An API (Application Programming Interface) is a contract that allows different software systems to intercommunicate and exchange data in a standardized way.*
## 💡 Analogy
*An API is like a **waiter in a restaurant**. You (the "frontend") don't go into the kitchen (the "backend"). You give your order (a request) to the waiter (the API), who communicates it to the kitchen. The kitchen prepares the food (the data), and the waiter brings it back to you (the response).*
## 📜 History & Creator
*While the concept of APIs is old, modern Web APIs (those using HTTP) began to be popularized in the early 2000s by companies like Salesforce and eBay, leading to the formalization of architectures like SOAP and REST.*
## 🔑 Core Philosophy & Design
*The core philosophy is **abstraction**. An API hides the internal complexity of a system (how the database works, the business logic) and exposes only a set of simple, documented rules (endpoints) that other developers can consume.*
## ⚙️ Key Details
- **What it is:** 
	- A set of rules and protocols defining how software components should interact.
- **Why it exists:** 
	- To enable interoperability, modularity, and reusability of software functionality without needing to share the full codebase.
- **Core Functions/Components:** *Common Web API architectural styles include:*
    - [[REST]]
    - [[GraphQL]]
    - [[SOAP]]
    - [[gRPC]]
## 🔗 Connections & Implementations
*Frontend applications (like [[_React]] or [[_Next.js]]) use Web APIs to get and send data to a backend server (like [[_Node.js]] or [[_Python]]).*
## See Also
- [[HTTP Methods]]
- [[JSON]]