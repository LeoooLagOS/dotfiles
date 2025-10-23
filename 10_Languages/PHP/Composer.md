---
tags:
  - concept
  - tool
  - php
  - dependency-manager
category: language
status:
  - learning
related: "[[_PHP]]"
date: 2025-10-22
---

# Composer

## 📝 One-Sentence Summary
Composer is the standard dependency manager for PHP, used to declare, install, and manage the libraries your PHP project needs.
## 💡 Analogy
Composer is like a **librarian and package delivery service** for your PHP project. You give it a list (`composer.json`) of the books (libraries/packages) your project needs. Composer finds the correct editions (versions) of those books, downloads them, and organizes them neatly on a specific shelf (`vendor/` directory) in your project, ensuring everything works together correctly.
## 🔑 Key Details
- **What it is:** 
	- An application-level package manager for PHP. 
- **Why it exists:** 
	- To manage the complex web of dependencies that modern PHP projects (especially frameworks like [[_Laravel]]) rely on. It ensures you have the right versions of the right libraries installed. 
	- **Core Files:** 
	- `composer.json`: The file where you declare your project's dependencies.
	- `composer.lock`: Records the exact versions of packages that were installed. This ensures consistent installations across different environments. 
	- `vendor/`: The directory where Composer downloads and stores all the external libraries.
## 🔗 Connections & Implementations
-   Essential for working with modern PHP frameworks like [[_Laravel]], Symfony, etc.
-   Included by default in development environments like [[Laragon]].
-   Used via commands like `composer install`, `composer update`, `composer require`.