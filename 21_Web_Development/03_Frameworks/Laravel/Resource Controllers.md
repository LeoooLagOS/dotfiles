---
tags:
  - concept
  - laravel
  - controller
  - crud
  - architecture
category: web-development
status:
  - learning
related: "[[Laravel Controllers]]"
date: 2025-11-19
---
# Resource Controllers

## 📝 One-Sentence Summary
*A Resource Controller is a standardized Laravel controller that automatically includes methods for all seven standard CRUD operations required to manage a resource.*

## 💡 Analogy
*Think of a Resource Controller as a **Swiss Army Knife for Data**. Instead of carrying separate tools for "showing," "editing," and "deleting," this single tool comes pre-equipped with exactly the 7 blades (methods) you need to handle any object's lifecycle.*

## 🔑 Key Details
- **What it is:** 
	- A controller generated with the `--resource` flag that adheres to RESTful conventions.
- **Why it exists:** 
	- To enforce consistency and speed up development. It prevents developers from inventing random names for standard actions (e.g., using `saveProduct` instead of `store`).

## 🔗 Connections & Implementations
### The 7 Standard Methods:
1.  **`index()`**: Display a list of items (GET).
2.  **`create()`**: Show the form to create a new item (GET).
3.  **`store()`**: Save the new item to the database (POST).
4.  **`show($id)`**: Display a specific item (GET).
5.  **`edit($id)`**: Show the form to edit an item (GET).
6.  **`update($id)`**: Save changes to the item (PUT/PATCH).
7.  **`destroy($id)`**: Delete the item (DELETE).

**Creation Command:**
`php artisan make:controller ProductController --resource`

**Route Definition:**
`Route::resource('products', ProductController::class);` (This single line creates all 7 routes!)

## See Also
- [[Laravel Controllers]]
- [[REST]]
- [[CRUD]]