---
tags:
  - concept
  - php
  - backend
  - web-development
category: web-development
status:
  - learning
related: "[[PHP and MySQL (MySQLi)]]"
date: 2025-10-20
---

# PHP Sessions

## 📝 One-Sentence Summary
PHP sessions are a mechanism to store user information across multiple page requests, allowing you to maintain state and keep users logged in.
## 💡 Analogy
Think of a session as getting a numbered wristband when you enter a theme park. As you move from one ride to another (from one page to another), the park staff can look at your wristband to know who you are and that you've paid your entrance fee. 
The `session_start()` function is like getting the wristband, `$_SESSION` is the information attached to it, and `session_destroy()` is like cutting the wristband off when you leave.
## 🔑 Key Details
- **What it is:** 
	- A way to preserve data for a specific user across different pages of a website. 
	- PHP creates a unique session ID for the user and stores it in a cookie on their browser. 
	- The actual session data is stored on the server. 
- **Why it exists:** 
	- HTTP is a "stateless" protocol, meaning each request is independent and the server doesn't remember the user from one page to the next. 
	- Sessions solve this by creating a persistent state for the duration of a user's visit.
## 🔗 Connections & Implementations
The core of session management revolves around three key functions.

1.  **`session_start()`**: 
	* This function **must** be called at the very beginning of any PHP script that needs to access session data. It either resumes an existing session or creates a new one.
2.  **`$_SESSION` Superglobal**:
	* This is a special associative array where you can store and retrieve user data.
3.  **`session_destroy()`**:
	* This function completely removes all data associated with the current session, effectively logging the user out.

### Code Examples (from Web-Development-Apps/Project)

**Creating a Session (from `valida.php`)**
After successfully verifying a user's password, their information is stored in the `$_SESSION` array.
```php
// If the password is correct...
$_SESSION["nom"] = $usuario;
$_SESSION["roll"] = $roll;

// Now, any other page with session_start() can access these values.
header("Location: index.php");
````

**Protecting a Page (from `seguridad.php`)** This script checks if the session variable for the user's role exists and is correct. If not, it redirects them.
```PHP
session_start(); // Must be called first!

if (isset($_SESSION["roll"]) && $_SESSION["roll"] == "admin") {
    // User is an admin, allow them to see the page.
} else {
    // User is not an admin or not logged in, redirect.
    header("Location: login.php");
    exit();
}
```

**Destroying a Session (from `salir.php`)** This script ends the user's session, logging them out.
```PHP
session_start();
session_destroy();
header("Location: login.php");
exit();
```

## See Also

- [[HTTP Methods]]
    
- [[Cookies]]