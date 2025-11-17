---
tags:
  - concept
  - java
  - database
  - api
  - sql
category: language
status:
  - learning
related: "[[_Java]]"
date: 2025-11-16
---
# JDBC (Java Database Connectivity)
## 📝 One-Sentence Summary
*JDBC is a Java API that defines how a Java application can connect to and execute queries on a database, regardless of the specific database brand (like MySQL, PostgreSQL, etc.).*
## 💡 Analogy
*JDBC is like a **universal power adapter** for databases. Your Java application (your "laptop") has one standard plug. JDBC provides the interface, and you just attach the specific "plug head" (the `.jar` driver) for whatever "wall outlet" (database) you're using. This allows your Java code to connect to MySQL, PostgreSQL, or SQL Server just by swapping the driver and connection string.*
## 🔑 Key Details
- **What it is:** 
	- A standard API (part of the Java platform) consisting of classes and interfaces in the `java.sql` package.
- **Why it exists:** 
	- To create a standard, vendor-independent way for Java code to interact with relational databases.
## 🔗 Connections & Implementations
The core workflow involves 5 steps, as seen in `proyecto2/index.jsp`:
1.  **Load the Driver:** A `.jar` file specific to your database (e.g., `mysql-connector-j.jar`) must be on the classpath.
    * `Class.forName("com.mysql.cj.jdbc.Driver");`
2.  **Establish Connection:** Use the `DriverManager` to get a `Connection` object, using a connection string (URL), username, and password.
    * `String url = "jdbc:mysql://localhost:3306/serv";`
    * `conn = DriverManager.getConnection(url, "root", "");`
3.  **Create a Statement:** Use the connection to create a `Statement` object that will execute the query.
    * `stmt = conn.createStatement();`
4.  **Execute Query:** Run the SQL and get the results in a `ResultSet` object.
    * `rs = stmt.executeQuery("SELECT * FROM contacto");`
5.  **Process Results:** Loop through the `ResultSet` to extract the data.
    * `while (rs.next()) { out.println(rs.getString("nom")); }`
6.  **Close Resources:** Must always close the `ResultSet`, `Statement`, and `Connection` in a `finally` block to prevent resource leaks.
## See Also
- [[JSP]]
- [[SQL]]
- [[WEB-INF]]