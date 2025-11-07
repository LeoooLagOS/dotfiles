---
tags:
  - concept
  - http
  - networking
category: web-development
status:
  - learning
related: "[[_Web Apis]]"
date: 2025-07-11
---

# HTTP Status Codes
## 📝 One-Sentence Summary
*HTTP Status Codes are standardized 3-digit codes a server sends in response to a client request, indicating the outcome of that request.*
## 💡 Analogy
*They are like **quick, standard replies** over the phone: `200` ("Got it, all good"), `404` ("This number doesn't exist"), `500` ("There's a problem on our end, can't connect you").*
## 🔑 Key Details
- **What it is:** 
	- A numerical code that classifies the server's response.
- **Why it exists:** 
	- To provide a universal, machine-readable way for a client to understand what happened to its request (success, failure, redirect, etc.).
## 🔗 Connections & Implementations
### 5 Classes of Codes:
* **1xx (Informational):** Request received, process continuing.
* **2xx (Success):** The request was successfully received, understood, and accepted.
    * `200 OK`: Standard success (for `GET`).
    * `201 Created`: A new resource was successfully created (for `POST`).
* **3xx (Redirection):** Further action needs to be taken.
* **4xx (Client Error):** The request contains bad syntax or cannot be fulfilled.
    * `400 Bad Request`: The server cannot understand the request.
    * `401 Unauthorized`: You are not authenticated (not logged in).
    * `403 Forbidden`: You are authenticated, but not allowed to access this resource.
    * `404 Not Found`: The requested resource does not exist.
    * `429 Too Many Requests`: You've hit a [[Rate Limiting]] threshold.
* **5xx (Server Error):** The server failed to fulfill a valid request.
    * `500 Internal Server Error`: A generic, catch-all server error.
## See Also
- [[REST]]
- [[Rate Limiting]]
- [[HTTP Methods]]