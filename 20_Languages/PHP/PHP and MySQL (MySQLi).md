---
tags:
  - concept
  - php
  - mysql
  - database
  - backend
category: web-development
status:
  - learning
related: "[[PHP Sessions]]"
date: 2025-10-20
---

# PHP and MySQL (MySQLi)

## 📝 One-Sentence Summary
MySQLi (MySQL Improved) is a PHP extension that provides a procedural and object-oriented interface for connecting to and interacting with MySQL databases.
## 💡 Analogy
Think of your PHP script as a person who needs to get a book from a massive library (your MySQL database). The MySQLi extension is the **librarian**. You give your connection details (username, password) to the librarian to get access. Then, you give the librarian a specific request slip (an SQL query), and they go and fetch the exact book (data) you asked for.
## 🔑 Key Details
- **What it is:** 
	- A native driver in PHP for communicating with MySQL databases. It's the modern standard, replacing the older, deprecated `mysql` extension. 
- **Why it exists:** 
	- To provide a secure, efficient, and feature-rich way for PHP applications to manage data stored in a MySQL database. It notably supports **prepared statements**, which are essential for preventing SQL injection.
## 🔗 Connections & Implementations
The typical workflow involves connecting, querying, and fetching results. Your `sql.php` class is a great object-oriented example of this.

### The Connection
A new `mysqli` object is created with the server, username, password, and database name. It's crucial to check for connection errors.

**Example `sql.php` Class:**
```php
class sql {
    public $conn;

    public function __construct() {
        $user = "root";
        $pass = "";
        $serv = "localhost";
        $db = "base2025";
        
        // Create the connection object
        $this->conn = new mysqli($serv, $user, $pass, $db);

        // Best practice: always check for errors
        if ($this->conn->connect_error) {
            die("Connection failed: " . $this->conn->connect_error);
        }
    }
    // ...
}
````

### Executing Queries and Fetching Results

Once connected, you can execute SQL queries. For `SELECT` queries, the result is an object that you can loop through to get each row of data.

**Example  `index.php` File:**
```PHP
function tabla(): void {
    $conn = new sql(); // Creates the connection
    $result = $conn->select("SELECT * FROM usuario"); // Executes the query
    
    if ($result->num_rows > 0) {
        // fetch_assoc() gets one row at a time as an associative array
        while ($row = $result->fetch_assoc()) {
            echo "ID: " . $row["id"] . " - Name: " . $row["nom"];
        }
    }
}
```

## 👍 Pros & 👎 Cons

- **Pros:** 
	- Fast, secure (supports prepared statements), and well-integrated into PHP.
    
- **Cons:**
	- Only works with MySQL databases. For other databases, you would need a different extension like PDO (PHP Data Objects).
    

## See Also

- [[SQL Injection]]
    
- [[Database Fundamentals]]