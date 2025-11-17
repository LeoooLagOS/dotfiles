---
tags:
  - concept
  - tool
  - server
  - networking
  - java
  - jsp
category: web-development
status:
  - learning
related: "[[_Java]]"
date: 2025-11-16
---
# Apache Tomcat
## 📝 One-Sentence Summary
*Apache Tomcat is an open-source web server and **servlet container** specifically designed to run Java-based web applications.*
## 💡 Analogy
*If the Apache HTTP Server is a post office (good at delivering mail and static files), Tomcat is a **specialized factory** 🏭. It's not a general-purpose server; it's built to do one thing: take requests for complex, custom-built products (Java applications) and run the machinery ([[Java Servlets and JSP]]) to build and serve them on the fly.*
## 🔑 Key Details
- **What it is:** 
	- A Java Servlet container, also known as a "web container." It executes Java code (Servlets and JSPs) to generate dynamic web pages.
- **Why it exists:** 
	- PHP can run within the Apache HTTP server (using a module), but Java applications need a dedicated Java Virtual Machine (JVM) and a container to manage their lifecycle. Tomcat provides this environment.
## 🔗 Connections & Implementations
* **Ports:** Runs on its own ports, typically `8080` (for HTTP) and `8009` (for AJP).
* **Configuration:**
    * `server.xml`: The main config file. We edited this to enable the AJP connector.
    * `conf/Catalina/localhost/`: We placed context `.xml` files  here to tell Tomcat where to find projects located *outside* its default `webapps` folder.
* **Deployment:** Can serve `.jsp` files or packaged `.war` files.
## 👍 Pros & 👎 Cons
-   **✅ Pros:** 
	- The industry standard for running Java Servlets and JSP. Stable and mature.
-   **❌ Cons:** 
	- Only runs Java applications. More complex to configure than a simple PHP server.
## See Also
- [[Apache HTTP Server]]
- [[Reverse Proxy (Apache and Tomcat)]]
- [[Java Servlets and JSP]]