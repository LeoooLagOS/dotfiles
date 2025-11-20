---
tags:
  - concept
  - laravel
  - security
  - forms
  - http
  - cybersecurity
category: web-development
status:
  - learning
related: "[[Laravel Form Handling]]"
date: 2025-11-19
---
# CSRF (Cross-Site Request Forgery)
## 📝 One-Sentence Summary
*CSRF (Cross-Site Request Forgery) is a vulnerability that tricks a user's browser into submitting an unintended request to a trusted site where the user is currently authenticated.*
## 💡 Analogy
*The CSRF token is like a **secret handshake** or a security ticket stamped with your session ID. When you submit a form, Laravel checks for this hidden token. If the token is missing or invalid, it means the request likely originated from a hacker's website, and Laravel instantly rejects it.*
## 🔑 Key Details
- **What it is:** 
	- A malicious exploit where a hacker forces a victim to submit a state-changing request (like deleting an item or changing a password) to an authenticated application.
- **Why it exists:** 
	- HTTP requests automatically include session cookies, which the browser sends even if the request comes from a third-party site.
- **Laravel Solution (@csrf):** 
	- Laravel automatically generates a unique, unguessable token for every active user session. When you include the `@csrf` Blade directive, it injects a hidden field containing this token into the form. Laravel validates this token on submission.
## 🔗 Connections & Implementations
* **Usage:** Must be included in every Blade form that uses `POST`, `PUT`, `PATCH`, or `DELETE`.
    ```html
    <form method="POST" action="/products">
        @csrf 
        ...
    </form>
    ```
* **Failure:** If the token fails verification, Laravel throws a `419 Page Expired` error.
## See Also
- [[Laravel Form Handling]]
