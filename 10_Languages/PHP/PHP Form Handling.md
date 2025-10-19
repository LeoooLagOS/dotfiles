---
tags:
  - concept
  - php
  - backend
category: language
status:
  - learning
related: "[[HTML Forms]]"
date: 2025-10-19
---

# PHP Form Handling

## 📝 One-Sentence Summary
PHP processes data sent from HTML forms using superglobal arrays (`$_GET`, `$_POST`, `$_REQUEST`) to access the information submitted by the user.
## 💡 Analogy
If an HTML form is a mailed application, the PHP script is the person at the receiving office. 
They have different inboxes for different mail types: a public tray on their desk for postcards (`$_GET`) and a private drawer for sealed envelopes (`$_POST`). `$_REQUEST` is like checking all inboxes at once.
## 🔑 Key Details
PHP automatically populates special associative arrays called **superglobals** with data from a submitted form. You can access the value of an input field by using its `name` attribute as the key.

### GET vs. POST
- **`method="get"`**:
    - Data is sent in the URL (e.g., `.../script.php?nom=Leo&app=Lagos`).
    - Processed in PHP using the `$_GET` superglobal.
    - **Use for**: Non-sensitive data, search queries, or pages you want to bookmark.
    - **Limitations**: Data is visible, and the URL length is limited.

- **`method="post"`**:
    - Data is sent in the body of the HTTP request, hidden from the user.
    - Processed in PHP using the `$_POST` superglobal.
    - **Use for**: Sensitive data (passwords), large amounts of data, or actions that modify the server (like creating a user).

### PHP Superglobals for Form Data
- **`$_GET`**: An array containing data sent via the GET method.
- **`$_POST`**: An array containing data sent via the POST method.
- **`$_REQUEST`**: An array that contains the contents of `$_GET`, `$_POST`, and `$_COOKIE`. It's convenient but can be less secure and explicit than using the specific method's array.

### Example from P2
This PHP script handles data from a form that used `method="get"`.
```php
<?php
// Accessing the 'nom' value from the URL query string
echo $_GET["nom"] . "<br>";

// Accessing the 'pass' value
echo $_GET["pass"] . "<br>";
?>
````

It's also good practice to check if the data exists before using it to prevent errors.

```PHP
<?php
// Using isset() as a safety check
if (isset($_POST["username"])) {
    echo "Welcome, " . $_POST["username"];
} else {
    echo "Username not provided.";
}
?>
```

## See Also

- [[HTML Forms]]
    
- [[HTTP Methods]]
    
- [[PHP Variables]]