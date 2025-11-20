---
tags:
  - concept
  - laravel
  - architecture
  - php
  - design-pattern
category: web-development
status:
  - learning
related: "[[Laravel Controllers]]"
date: 2025-11-19
---
# Dependency Injection

## 📝 One-Sentence Summary
*Dependency Injection (DI) in Laravel is the practice of "asking" for the objects your code needs (dependencies) via the constructor or method signature, rather than creating them manually.*

## 💡 Analogy
*Imagine you are a chef (Controller Method).
* **Without DI:** You have to stop cooking, walk to the store, buy a specific knife, and then come back to cut the vegetables. (`$request = new Request();`)
* **With DI:** You just shout "I need a Knife!" (type-hint `Request $request`), and your assistant (Laravel's Service Container) instantly hands you the tool you asked for. You don't care where it came from; you just use it.*

## 🔑 Key Details
- **What it is:** 
	- A design pattern where dependencies are injected into a class/method by an external entity (The Service Container).
- **Why it exists:** 
	- It makes code testable, decoupled, and cleaner. You don't need to know *how* to create complex objects (like the HTTP Request); Laravel does it for you.

## 🔗 Connections & Implementations
You used this in **every controller method** without realizing it!

**Example:**
```php
// You "asked" for the Request object and the Product model
public function update(Request $request, Product $product) 
{
    // Laravel injected them automatically. 
    // You didn't have to say $request = new Request();
    $validated = $request->validate(...);
}
````

Laravel saw the type hint `Request` and automatically passed the current HTTP request object into your variable `$request`.

## See Also

- [[Laravel Controllers]]
    
- [[Route Model Binding]]