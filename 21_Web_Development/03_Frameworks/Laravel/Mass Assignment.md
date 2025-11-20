---
tags:
  - concept
  - laravel
  - security
  - database
  - eloquent
category: web-development
status:
  - learning
related: "[[_Laravel]]"
date: 2025-11-19
---
# Mass Assignment

## 📝 One-Sentence Summary
*Mass Assignment is a feature in Laravel that allows you to set multiple model attributes at once by passing an array to methods like `create()` or `update()`, but it requires strict security configuration to prevent vulnerabilities.*

## 💡 Analogy
*Mass Assignment is like a **VIP Club Guest List**. When a crowd (form data) tries to enter your club (database), the bouncer (Model) checks the guest list (`$fillable`). If a name isn't on the list (like `role` or `is_admin`), they are blocked at the door, even if they try to sneak in. This prevents malicious users from promoting themselves to admin just by adding a field to a form.*

## 🔑 Key Details
- **What it is:** 
	- The ability to send an array of data to a model to save it: `User::create($request->all());`.
- **Why it exists:** 
	- To simplify code. Instead of setting `user->name = ...`, `user->email = ...` line by line, you do it in one shot.
- **The Security Risk:** 
	- A user could add a hidden field `<input name="is_admin" value="1">` to a form. Without protection, Mass Assignment would save this to the database.

## 🔗 Connections & Implementations
To use Mass Assignment safely, you **must** define the `$fillable` property in your Model.

**Example (`app/Models/User.php`):**
```php
protected $fillable = [
    'name',
    'email',
    'password',
    'role', // We had to add this manually to allow role updates!
];
```
Any field NOT in this array will be silently discarded during `create()` or `update()` operations.

## See Also

- [[_Laravel]]
    
- [[Database Fundamentals]]