---
tags:
  - concept
  - laravel
  - database
  - frontend
  - performance
category: web-development
status:
  - learning
related: "[[_Eloquent ORM]]"
date: 2025-11-19
---
# Laravel Pagination

## 📝 One-Sentence Summary
*Laravel Pagination is a built-in feature that splits large datasets into smaller, manageable pages and automatically generates the necessary HTML links for navigation.*

## 💡 Analogy
*Imagine trying to read a book that is printed on a **single, kilometer-long scroll** (displaying all records at once). It would be heavy, slow to unroll, and hard to find anything. Pagination turns that scroll into a **book with numbered pages**. You only load and read one page at a time, which is faster and easier to handle.*

## 🔑 Key Details
- **What it is:** 
	- A method to limit database results and provide navigation links.
- **Why it exists:** **Performance.** Loading 10,000 records at once (`all()`) crashes browsers and slows down servers. Pagination (`paginate(10)`) loads only 10 records.

## 🔗 Connections & Implementations
**1. In the Controller:**
Replace `all()` with `paginate($number_per_page)`.
```php
// Before: $products = Product::all();
$products = Product::paginate(10);
```
**2. In the View (Blade):** Laravel provides a method to render the navigation links (Next, Previous, 1, 2, 3...) automatically.
```Blade
<div class="mt-4">
    {{ $products->links() }}
</div>
```

_Note: By default, it uses Tailwind CSS styles, so it looks professional out of the box._

## See Also

- [[_Eloquent ORM]]   
- [[Blade Views and Asset Helper]]