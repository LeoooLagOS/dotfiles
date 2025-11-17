---
tags:
  - concept
  - java
  - web-development
  - server
category: language
status:
  - learning
related: "[[JSP]]"
date: 2025-11-16
---
# WEB-INF
## 📝 One-Sentence Summary
*`WEB-INF` is a special, protected directory inside a Java web application that contains the application's private files, including libraries (`.jar` files) and configuration, making them inaccessible directly from a browser.*
## 💡 Analogy
*The `WEB-INF` directory is the **"Employees Only" back office** of your web application. Public users (browsers) can access the main store (like `index.jsp` in the root), but they are not allowed to go into the back office. This is where you keep all your tools (`/lib`), internal manuals (`web.xml`), and sensitive materials, safe from public access.*
## 🔑 Key Details
- **What it is:** 
	- A standard directory in Java web applications. The name is case-sensitive.
- **Why it exists:** 
	- To provide a secure, standard location for application resources that should **not** be served directly to the client. The server (e.g., [[Apache Tomcat]]) knows to protect this folder.
## 🔗 Connections & Implementations
### Standard Subdirectories:
* **`WEB-INF/lib/`**:
    * This is the most important subfolder for simple projects.
    * You place all third-party `.jar` files (like the [[JDBC|MySQL Connector .jar]]) here.
    * The server automatically loads these libraries into the application's classpath, making them available for your code (e.g., for `Class.forName(...)`).
* **`WEB-INF/classes/`**:
    * Where your compiled `.class` files (Java Servlets) would go.
* **`web.xml`**:
    * The "Deployment Descriptor" file that configures the application (e.g., mapping servlets to URLs). It's less critical for simple JSP-only projects.

## See Also
- [[Apache Tomcat]]
- [[JDBC]]
- [[JSP]]