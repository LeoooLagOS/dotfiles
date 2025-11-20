---
tags:
  - concept
  - laravel
  - routing
  - eloquent
  - productivity
category: web-development
status:
  - learning
related: "[[Laravel Routing]]"
date: 2025-11-19
---
# Route Model Binding 
## 📝 One-Sentence Summary 
*Route Model Binding is a Laravel feature that automatically injects model instances into your routes and controllers based on the ID present in the URL.* 
## 💡 Analogy 
*Without binding, your controller is like a receptionist who gets a room number and has to go look up the guest manualy (`$guest = User::find($id)`). With **Route Model Binding**, the receptionist is handed the guest's actual file immediately. You define the route as `/users/{user}`, and Laravel automatically fetches the User with that ID and hands it to you.* 
## 🔑 Key Details 
- **What it is:** 
	- A mechanism to automatically resolve Eloquent models based on route parameters. 
- **Why it exists:** 
	- To reduce boilerplate code. It eliminates the need to manually query the database (e.g., `Product::findOrFail($id)`) at the start of every controller method. 

## 🔗 Connections & Implementations 
- **1. Implicit Binding (Standard):** Use a type-hinted variable name in the controller that matches the route segment name. 
	* **Route:** `Route::get('/products/{product}', ...)` 
	* **Controller:** 
``` php 
	 // Instead of ($id) 
	  public function show(Product $product) { 
	  // Laravel has already run Product::findOrFail($id) for you! 
	  return view('products.show', compact('product')); } 
	  ``` 
- **2. Custom Keys:** You can bind to columns other than ID (e.g., slug) by modifying the route definition: `Route::get('/products/{product:slug}', ...)` 
## See Also 
- [[_Eloquent ORM]] 
- [[Laravel Routing]] 
- [[Laravel Controllers]]