---
tags:
  - concept
  - laravel
  - database
  - sql
category: web-development
status:
  - learning
related: "[[_Laravel]]"
date: 2025-11-17
---
# Migrations (Laravel)
## 📝 One-Sentence Summary
*Migrations are a form of version control for your database, allowing you to define, modify, and share your application's database schema using PHP code.*
## 💡 Analogy
*Migrations are like **"blueprints"  for your database**. Instead of going to phpMyAdmin and manually building tables, you write a blueprint (a migration file) in PHP. When you run `php artisan migrate`, Laravel reads all your blueprints and builds the database structure for you. If you need to add a column, you create a new blueprint.*
## 🔑 Key Details
- **What it is:** 
	- PHP classes stored in the `database/migrations/` folder that define the database schema (tables, columns, indexes).
- **Why it exists:** 
	- To keep the database structure in sync with the application's code. This allows teams to share the database design easily, and you can rebuild your database from scratch on any machine.
## 🔗 Connections & Implementations
* You create a new migration with `php artisan make:migration create_users_table`.
* You run pending migrations with `php artisan migrate` (as you did in your project setup).
* You roll back the last migration with `php artisan migrate:rollback`.
* Your `breeze:install` command automatically created the migration files for the `users`, `password_reset_tokens`, etc., tables.
## 👍 Pros & 👎 Cons
-   **✅ Pros:** 
	- Database schema is version-controlled with your code (via [[_Git]]), makes team collaboration easy, fully reproducible database.
-   **❌ Cons:** 
	- Can be complex for very advanced database changes; requires learning Laravel's Schema Builder syntax.
## See Also
- [[_Laravel]]
- [[Artisan CLI]]
- [[Database Fundamentals]]