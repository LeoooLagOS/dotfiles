---
tags:
  - concept
  - tool
  - laravel
  - php
  - cli
category: web-development
status:
  - learning
related: "[[_Laravel]]"
date: 2025-11-17
---
# Artisan CLI (Command Line Interface)
## 📝 One-Sentence Summary
*Artisan is Laravel's built-in command-line interface that provides dozens of helpful commands for building, managing, and testing an application.*
## 💡 Analogy
*Artisan is the **"magic wand"  or "workshop assistant"** for your Laravel project. Instead of manually creating a file, writing boilerplate code, or running the server, you just tell the assistant what you want (e.g., "make a controller" or "start the server"), and it does the work for you.*
## 🔑 Key Details
- **What it is:** 
	- A command-line tool (based on the Symfony Console component) included with every Laravel installation.
- **Why it exists:** 
	- To speed up development and automate repetitive tasks, like creating files (controllers, models, migrations), running the server, and clearing caches.
## 🔗 Connections & Implementations
*You run it from the project's root folder using `php artisan [command]`.*

* **`php artisan serve`**: Starts the local development server.
* **`php artisan make:controller NameController`**: Generates a new controller file.
* **`php artisan make:model Name`**: Generates a new Eloquent model.
* **`php artisan migrate`**: Runs pending database migrations.
* **`php artisan breeze:install`**: A command provided by a package (Breeze) to set it up.
* **`php artisan list`**: Shows all available commands.
## 👍 Pros & 👎 Cons
-   **✅ Pros:** 
	- Enormously speeds up development, enforces code conventions, automates complex tasks, easily extensible.
-   **❌ Cons:** (None, really. It's essential to using Laravel).
## See Also
- [[_Laravel]]
- [[Laravel Controllers]]
- [[Migrations]]