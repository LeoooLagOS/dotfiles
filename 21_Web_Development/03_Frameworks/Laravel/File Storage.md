---
tags:
  - concept
  - laravel
  - file-system
  - files
category: web-development
status:
  - learning
related: "[[_Laravel]]"
date: 2025-11-19
---
# File Storage

## 📝 One-Sentence Summary
*Laravel provides a powerful filesystem abstraction that allows you to store files on local disks or cloud services (like S3) interchangeably, with a specific `public` disk for user-generated content that needs to be accessible from the web.*

## 💡 Analogy
*Think of the `storage/app` folder as a **secure vault** 🏦 inside your server. The web browser cannot see inside it. The `public` folder is the **display window** 🪟 facing the street. To show an image from the vault in the window, you create a "tunnel" (symbolic link) connecting the two using `php artisan storage:link`. Without this tunnel, the files exist but are invisible to the world.*

## 🔑 Key Details
- **What it is:** 
	- A system for managing file uploads and retrieval.
- **The `public` Disk:** 
	- Used for files that should be publicly accessible (like profile avatars or product images).
- **The Symbolic Link:** Crucial for local development. It connects `public/storage` -> `storage/app/public`.

## 🔗 Connections & Implementations
**1. The Link Command:**
`php artisan storage:link` (Must run this once!)

**2. Storing Files (Controller):**
```php
// Automatically stores in storage/app/public/products
// Returns the relative path hash
$path = $request->file('image')->store('products', 'public');
````

**3. Deleting Files:**
```PHP
Storage::disk('public')->delete($oldImagePath);
```

**4. Displaying Files (View):**
```Blade
<img src="{{ asset('storage/' . $product->image) }}">
```

## See Also

- [[Blade Views and Asset Helper]]
    
- [[Artisan CLI]]