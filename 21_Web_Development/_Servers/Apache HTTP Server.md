---
tags:
  - command
  - tool
  - server
  - networking
  - http
category: web-development
status:
  - learning
related: "[[HTTP]]"
date: 2025-11-16
---
# Apache HTTP Server
## 📝 One-Sentence Summary
*The Apache HTTP Server (also called "Apache") is a free, open-source web server software that listens for HTTP requests and serves the corresponding web content ([[_HTML]], [[_CSS]], [[_Java Script|JS]], and [[_PHP]] files).*
## 💡 Analogy
*Apache is the **post office** 📮 of the web. When a browser (a client) sends a letter (an HTTP request) asking for a specific address (a URL), Apache receives the letter, finds the right file in its storage (like a `htdocs` or project folder), and sends it back to the client.*
## 🔑 Key Details
- **What it is:** 
	- The most widely used web server software. It's the "A" in XAMPP and LAMP.
- **Why it exists:** 
	- To act as the "front door" for a website, handling incoming traffic and delivering the correct files to users. It can also process dynamic content by passing requests to other programs (like PHP).
## 🔗 Connections & Implementations
* **Configuration:** Its main behavior is controlled by the `httpd.conf` file.
* **Modules:** It's highly extensible through modules. The modules we used, `mod_proxy` and `mod_proxy_ajp`, add the ability to act as a [[Reverse Proxy (Apache and Tomcat)|Reverse Proxy]].
* **Running:** In [[XAMPP]], you start this service to serve your PHP projects from port 80 (HTTP) and 443 (HTTPS).
## 👍 Pros & 👎 Cons
-   **✅ Pros:** 
	- Extremely powerful, stable, secure, and highly configurable via modules.
-   **❌ Cons:** 
	- Configuration files can be complex and intimidating for beginners.
## See Also
- [[Apache Tomcat]]
- [[Reverse Proxy (Apache and Tomcat)]]
- [[HTTP]]