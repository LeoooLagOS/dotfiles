---
tags:
  - concept
  - laravel
  - security
  - forms
category: web-development
status:
  - learning
related: "[[Laravel Controllers]]"
date: 2025-11-19
---
# Laravel Validation

## 📝 One-Sentence Summary
*Laravel Validation provides a convenient way to validate incoming HTTP request data using a variety of powerful, pre-defined rules, ensuring data integrity and security before it reaches your application logic.*

## 💡 Analogy
*Validation is like the **quality control inspector** 🕵️ on a factory line. Before any raw material (user input) enters the machine (database/controller), the inspector checks it against a checklist: "Is this empty? Is this actually a number? Is this email unique?" If it fails any check, it gets rejected immediately with a note explaining why.*

## 🔑 Key Details
- **What it is:** 
	- A system to check incoming data against rules like `required`, `numeric`, `email`, `unique`, `max`, etc.
- **Why it exists:** 
	- To prevent bad data from crashing your app or compromising your database. It also handles redirecting the user back to the form with error messages automatically.

## 🔗 Connections & Implementations
**Basic Usage (Controller):**
```php
$validated = $request->validate([
    'name' => 'required|string|max:255',
    'price' => 'required|numeric|min:0',
    'email' => 'unique:users,email',
]);
```

**Automatic Redirect:** If validation fails, Laravel automatically redirects the user back to the previous location.

**Displaying Errors (Blade):**
``` Blade
@if ($errors->any())
    <div class="alert alert-danger">
        <ul>
            @foreach ($errors->all() as $error)
                <li>{{ $error }}</li>
            @endforeach
        </ul>
    </div>
@endif
```

## See Also

- [[Laravel Controllers]]
    
- [[Laravel Form Handling]]