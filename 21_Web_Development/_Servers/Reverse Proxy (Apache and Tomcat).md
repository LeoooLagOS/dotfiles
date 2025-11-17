---
tags:
  - concept
  - networking
  - devops
  - server
  - apache
category: web-development
status:
  - learning
related: "[[Apache HTTP Server]]"
date: 2025-11-16
---
# Reverse Proxy (Apache and Tomcat)
## 📝 One-Sentence Summary
*A reverse proxy is a server technique where a primary web server ([[Apache HTTP Server|Apache]]) receives all requests and intelligently forwards specific ones to a backend application server ([[Apache Tomcat|Tomcat]]), then sends the response back to the client.*
## 💡 Analogy
*Apache is the **receptionist** 👩‍💼 at the front desk of a large building (accessible at `localhost`). Most requests are for the main office (your PHP projects). But when a call comes in for the "Java Department" (Tomcat), the receptionist patches the call through to that department's internal line (port `8009` or `8005`). The client never knows they spoke to anyone but the front-desk receptionist.*
## 🔑 Key Details
- **What it is:** 
	- Using Apache HTTP Server as a "front-man" for Apache Tomcat.
- **Why it exists:** 
	- To create a single, unified URL (`localhost/web-dev/`) for *all* your projects, regardless of their underlying technology (PHP or Java). It also adds security, as Tomcat itself is not directly exposed to the user.
## 🔗 Connections & Implementations
* **Apache Module:** Requires `mod_proxy` and `mod_proxy_ajp` to be enabled in `httpd.conf`.
* **Apache Config (`httpd.conf`):** Uses the `ProxyPassMatch` directive to define the forwarding rule. This **must** be placed *before* the `Alias` directive to be caught first.
    ```apache
    # 1. The Proxy rule (interceptor)
    ProxyPassMatch ^/web-dev/(proyecto1|proyecto2)(/.*)?$ ajp://127.0.0.1:8005/$1$2
    
    # 2. The Alias rule (general file serving)
    Alias /web-dev "C:/.../web-applications-development"
    ```
* **Tomcat Config (`server.xml`):** Must have an AJP connector enabled on the matching port (e.g., `8005`) to receive the forwarded requests.
## 👍 Pros & 👎 Cons
-   **✅ Pros:** 
	- Unified URLs, simplifies the user experience, allows multiple technologies to run on one server, adds a layer of security.
-   **❌ Cons:** 
	- Adds a layer of configuration complexity; troubleshooting (like we did) can be tricky as it involves two servers.
## See Also
- [[Apache HTTP Server]]
- [[Apache Tomcat]]
- [[Load Balancing]]