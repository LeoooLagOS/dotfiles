---
tags:
  - concept
  - laravel
  - security
  - forms
  - html
category: web-development
status:
  - learning
related: "[[Blade Views and Asset Helper]]"
date: 2025-11-19
---
# Laravel Form Handling

## 📝 One-Sentence Summary
*Laravel provides specific Blade directives to secure forms against cross-site attacks and to support HTTP verbs (PUT, DELETE) that HTML forms do not natively support.*

## 💡 Analogy
* **CSRF (`@csrf`)**: Is like a **secret handshake** or a stamped ticket. When you submit a form, Laravel checks for this stamp. If it's missing (meaning the form didn't come from your actual website, but from a hacker's site), the request is rejected.
* **Method Spoofing (`@method`)**: HTML forms are like old mailboxes that only accept "Letters" (GET) and "Packages" (POST). If you want to send a "Delete Order" (DELETE request), you have to put it inside a "Package" (POST) and write a special note on top saying "This is actually a DELETE request." Laravel reads that note and handles it correctly.

## 🔑 Key Details
- **Why it exists:** 
	- HTML forms strictly support only `GET` and `POST`. Modern apps need `PUT`, `PATCH`, and `DELETE`. Also, web security requires protection against Cross-Site Request Forgery (CSRF).

## 🔗 Connections & Implementations
**1. CSRF Protection:**
You **must** include `@csrf` inside every HTML form pointing to a `POST`, `PUT`, or `DELETE` route.
```html
<form method="POST" action="/profile">
    @csrf
    </form>
````

**2. Method Spoofing:** Used for `PUT` (Update) and `DELETE` (Destroy) actions.
```HMTL
<form action="/products/1" method="POST">
    @csrf
    @method('PUT')
    </form>
```

**3. Old Input:** Repopulating forms after validation errors so users don't have to re-type everything.
```HTML
<input type="text" name="name" value="{{ old('name', $product->name) }}">
```

## See Also

- [[HTTP Methods]]
    
- [[Laravel Routing]]
    
- [[Laravel Validation]]