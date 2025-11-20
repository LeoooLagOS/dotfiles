---
tags:
  - concept
  - laravel
  - forms
  - http
category: web-development
status:
  - learning
related: "[[Laravel Form Handling]]"
date: 2025-11-20
---
# Method Spoofing
## 📝 One-Sentence Summary
*Method Spoofing is the technique of simulating HTTP verbs like PUT, PATCH, and DELETE in a standard HTML form by sending a hidden input field that Laravel recognizes and handles.*
## 💡 Analogy
*HTML forms are like old **mailboxes that only accept letters (GET) and packages (POST)**. If you need to send a "Delete Order" (a DELETE request), you have to put it inside a "Package" (POST) and write a special, official note on the outside saying, "Attention: The actual method inside is DELETE." Laravel reads that note (`@method('DELETE')`) and processes the request correctly.*
## 🔑 Key Details
- **What it is:** 
	- A workaround for a technical limitation in HTML, which only natively supports `GET` and `POST` methods in the `<form>` tag.
- **Why it exists:** 
	- Modern RESTful applications require `PUT` or `PATCH` for updates and `DELETE` for removal, so frameworks need a way to support these verbs via an HTML form submission.
- **Laravel Solution (@method):** The `@method('VERB')` directive automatically generates a hidden input field that Laravel's framework middleware intercepts and uses to override the true HTTP method.

## 🔗 Connections & Implementations
* **Required Verb:** DELETE (Used for `destroy` CRUD method)
* **Required Verb:** PUT or PATCH (Used for `update` CRUD method)

**Example (Update Form):**
```html
<form action="{{ route('products.update', $product) }}" method="POST">
    @csrf
    @method('PUT') 
    ...
</form>
```
## See Also

- [[Laravel Form Handling]]
    
- [[REST]]
    
- [[HTTP Methods]]
