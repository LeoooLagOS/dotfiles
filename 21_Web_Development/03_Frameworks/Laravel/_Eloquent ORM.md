---
tags:
  - overview
  - concept
  - laravel
  - database
  - php
  - orm
category: web-development
status:
  - learning
related: "[[_Laravel]]"
date: 2025-11-19
---
# _Eloquent ORM_

## 📝 One-Sentence Summary
*Eloquent is Laravel's active record Object-Relational Mapper (ORM) that allows you to interact with your database using PHP syntax and objects instead of writing raw SQL queries.*

## 💡 Analogy
*Eloquent is like a **universal translator** 🗣️ between your code and your database. Instead of speaking the database's difficult native language (SQL) like `SELECT * FROM products WHERE price > 100`, you speak simple PHP objects like `Product::where('price', '>', 100)->get()`. Eloquent handles the translation instantly.*

## 🔑 Core Philosophy & Design
* **Active Record Implementation:** Each database table has a corresponding "Model" (e.g., `products` table has a `Product` model).
* **Expressive Syntax:** Queries read like English sentences (e.g., `User::find(1)`).
* **Convention over Configuration:** It assumes standard names (table `users` for model `User`, primary key `id`) unless you tell it otherwise, saving setup time.

## ⚙️ Key Details
- **What it is:** 
	- The default database abstraction layer in Laravel.
- **Why it exists:** 
	- To make database interactions safer (automatic protection against SQL injection), faster to write, and easier to read.
- **Core Components:** Models, Collections, Relationships (HasOne, HasMany), Accessors/Mutators.

## 🔗 Connections & Implementations
* **Defining a Model:** `class Product extends Model {}`
* **Retrieving Data:**
    * `Product::all()` - Get everything.
    * `Product::find(1)` - Get row with ID 1.
    * `Product::where('stock', '>', 0)->get()` - Filter data.
* **Creating Data:** `Product::create(['name' => 'Ring', ...])` (Requires `[[Mass Assignment]]` setup).
* **Updating Data:**
    ```php
    $product = Product::find(1);
    $product->name = 'New Name';
    $product->save();
    ```
* **Deleting Data:** `$product->delete();`

## See Also
- [[_Laravel]]
- [[Mass Assignment]]
- [[Migrations (Laravel)]]