---
tags:
  - concept
  - laravel
  - security
  - architecture
  - http
category: web-development
status:
  - learning
related: "[[_Laravel]]"
date: 2025-11-19
---
# Laravel Middleware

## 📝 One-Sentence Summary
*Middleware provide a convenient mechanism for inspecting and filtering HTTP requests entering your application, acting as layers that requests must pass through before reaching your application logic.*

## 💡 Analogy
*Middleware are like **security checkpoints** 🛂 at an airport. Before you (the request) can get to the gate (the Controller), you must pass through ID check (`auth` middleware) and metal detectors (`admin` middleware). If you fail any check, you are turned away (error 403/401) and never reach your destination.*

## 🔑 Key Details
- **What it is:** 
	- Classes that wrap around your application logic. They can run code *before* or *after* a request is handled.
- **Why it exists:** 
	- To separate cross-cutting concerns like authentication, logging, and CORS from the core business logic of your controllers.

## 🔗 Connections & Implementations
**Creation:** `php artisan make:middleware AdminMiddleware`

**Logic (The `handle` method):**
```php
public function handle(Request $request, Closure $next): Response
{
    if (auth()->user()->role !== 'admin') {
        abort(403); // Stop the request here!
    }
    return $next($request); // Pass the request to the next layer
}
````

**Registration:** You must register your middleware in `app/Http/Kernel.php` (aliases array) to use it in routes.

**Usage:** `Route::middleware(['auth', 'admin'])->group(...)`

## See Also

- [[Laravel Routing]]
    
- [[HTTP Status Codes]]