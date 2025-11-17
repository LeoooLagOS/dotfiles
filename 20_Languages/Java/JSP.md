---
tags:
  - concept
  - java
  - jsp
  - backend
category: language
status:
  - learning
related: "[[_Java]]"
date: 2025-11-16
---
# JSP (JavaServer Pages)
## 📝 One-Sentence Summary
*JSP is a server-side technology that allows developers to write dynamic, data-driven web pages by embedding Java code directly into HTML/XML documents.*
## 💡 Analogy
*Think of a `.jsp` file as an **HTML document that is also a "magic spellbook"** 📜. The web server (like [[Apache Tomcat]]) reads the HTML normally, but when it sees a magic incantation (a `<% ... %>` tag), it executes the Java code inside. This allows it to do things like `out.println("Hello World!")` or fetch data from a database **before** sending the final, plain HTML page to the user.*
## 🔑 Key Details
- **What it is:** 
	- A Java technology that allows embedding Java code (called "scriptlets") into HTML pages using special tags like `<% ... %>` (for code), `<%= ... %>` (to print a value), and `<%@ ... %>` (for directives like imports).
- **Why it exists:** 
	- To simplify the creation of dynamic web content in Java. It's an abstraction on top of Java Servlets, making it easier to write the "View" (the V in [[MVC]]) by focusing on HTML and inserting Java only where needed.
## 🔗 Connections & Implementations
* JSP files are compiled into Java Servlets by the server (Tomcat) the first time they are accessed.
* **Scriptlet (`<% ... %>`):** A block of Java code to be executed.
    ```jsp
    <%
      String name = "Gemini";
      out.println("Hello, " + name);
    %>
    ```
* **Expression (`<%= ... %>`):** A Java expression whose result is printed to the page.
    ```jsp
    <p>Hello, <%= name %></p>
    ```
* **Directive (`<%@ ... %>`):** Provides instructions to the server, such as importing Java classes.
    ```jsp
    <%@ page import="java.sql.Connection" %>
    <%@ page import="java.util.Date" %>
    ```
## 👍 Pros & 👎 Cons
-   **✅ Pros:** 
	- Convenient for adding small bits of dynamic logic to HTML; easier to write than a full Java Servlet for simple views.
-   **❌ Cons:** 
	- Mixing logic and presentation in one file can become messy and hard to maintain. Modern frameworks (like [[Spring MVC]]) often separate this logic completely.
## See Also
- [[_Java]]
- [[Apache Tomcat]]
- [[JDBC]]