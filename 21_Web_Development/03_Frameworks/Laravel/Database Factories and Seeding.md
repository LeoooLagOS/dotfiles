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
# Database Factories and Seeding

## 📝 One-Sentence Summary
*Factories and Seeding are Laravel tools used to automatically populate your database with dummy test data, allowing you to quickly test your application with realistic content.*

## 💡 Analogy
*Imagine you are building a bookshelf (your app). You need to test if it holds books correctly.
* **Factories** are like a **3D printer for books**. You tell it "Print me a generic book with a random title and author," and it generates one instantly.
* **Seeding** is like a **moving crew**. You tell them "Take 50 books from the printer and put them on the shelves."
Instead of typing 10 users into phpMyAdmin manually, you just push a button.*

## 🔑 Key Details
- **Factories:** 
	- Define the *structure* of fake data for a model (e.g., "A User has a random name and a safe email"). Uses the Faker library.
- **Seeders:** 
	- Define the *process* of inserting that data (e.g., "Create 1 Admin user and 50 random users").

## 🔗 Connections & Implementations
**1. Defining a Factory (`UserFactory.php`):**
```php
return [
    'name' => fake()->name(),
    'email' => fake()->unique()->safeEmail(),
    'password' => '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', // password
];
````

**2. Using Tinker (Quick Seeding):** This is how you created your test users: `User::factory()->count(10)->create();`

**3. Running Seeders:** `php artisan db:seed` (Runs the logic in `DatabaseSeeder.php`).

## See Also

- [[_Eloquent ORM]]
    
- [[Artisan CLI]]