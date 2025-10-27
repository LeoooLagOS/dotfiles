---
tags:
  - concept
  - cybersecurity
  - sql
  - php
  - vulnerability
category: cybersecurity
status:
  - learning
related: "[[PHP and MySQL (MySQLi)]]"
date: 2025-10-20
---

# SQL Injection

## 📝 One-Sentence Summary
SQL Injection is a code injection technique used to attack data-driven applications, in which malicious SQL statements are inserted into an entry field for execution (e.g., to dump database contents to the attacker).
## 💡 Analogy
Imagine a login form is a security guard asking for your name. 
* **Normal User:** 
	* You say your name is "admin". The guard looks at their list and checks for "admin". 
* **Attacker:** 
	* You tell the guard your name is "**admin' OR '1'='1**". If the guard is naive (a vulnerable query), they will look at their list and check for a user named "admin" OR they will check if 1 is equal to 1. Since `'1'='1'` is always true, the guard lets you in without even checking your real name.

## 🔑 Key Details
- **What it is:** 
	- A major web security vulnerability that allows an attacker to interfere with the queries that an application makes to its database.
- **Why it exists:** 
	- It happens when an application takes user input (from a form, URL, etc.) and directly concatenates it into an SQL query string without sanitizing it first.

### A Vulnerable Query Example
This is how a login query might look if it's vulnerable. The user's input is directly stitched into the SQL string.
```php
// DANGEROUS - DO NOT USE
$usuario = $_POST["usuario"]; // e.g., "admin'--"
$sql = "SELECT * FROM usuario WHERE nom='" . $usuario . "'";
// The final query becomes:
// SELECT * FROM usuario WHERE nom='admin'--'
// The '--' comments out the rest of the query, bypassing the password check.
````

## 🔗 The Solution: Prepared Statements

Prepared statements are the primary defense against SQL Injection. They separate the SQL command from the user-provided data.

**How it Works:**

1. **Prepare:** An SQL query template is sent to the database with placeholders (`?`) instead of user data.
    
2. **Bind:** The user's data is sent to the database separately. The database engine then binds this data to the placeholders.
    
3. **Execute:** The query is executed.
    

Because the data is sent separately, the database treats it as pure data and never as part of the executable SQL command.

### Example  `valida.php`

This is the secure way to handle the login.
```PHP
// 1. Prepare the query with a placeholder
$stmt = $conn->conn->prepare("SELECT pass, roll FROM usuario WHERE nom = ?");

// 2. Bind the user input to the placeholder
// "s" means the variable is a string
$stmt->bind_param("s", $usuario);

// 3. Execute the query
$stmt->execute();
$result = $stmt->get_result();

// Now you can safely process the result...
```

## See Also

- [[PHP and MySQL (MySQLi)]]
    
- [[Cybersecurity Fundamentals]]