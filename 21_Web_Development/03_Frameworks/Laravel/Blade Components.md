---
tags:
  - concept
  - laravel
  - blade
  - frontend
  - ui
category: web-development
status:
  - learning
related: "[[Blade Views and Asset Helper]]"
date: 2025-11-19
---
# Blade Components

## 📝 One-Sentence Summary
*Blade Components are reusable pieces of UI logic and HTML (like buttons, inputs, or layouts) that can be easily used across your Blade views using custom XML-like tags.*

## 💡 Analogy
*Components are like **custom rubber stamps** for your UI. Instead of handwriting the HTML for a "Primary Button" (with all its 15 Tailwind classes) every single time, you just use your `<x-primary-button>` stamp. It ensures every button looks exactly the same, and if you want to change the color, you just change the stamp (the component definition), not every page.*

## 🔑 Key Details
- **What it is:** 
	- A feature of the Blade templating engine that allows you to encapsulate HTML structure and styles into reusable tags (e.g., `<x-alert />`).
- **Why it exists:** 
	- To reduce code duplication and maintain consistency in the UI. It replaces the older `@include` directive with a more modern, expressive syntax.
- **[[Laravel Breeze|Breeze]]:** The starter kit you used is built almost entirely on anonymous Blade components.

## 🔗 Connections & Implementations
**1. Defining a Component:**
A file at `resources/views/components/primary-button.blade.php`:
```html
<button class="bg-blue-500 text-white px-4 py-2 rounded">
    {{ $slot }}
</button>
```
**2. Using a Component:** In any other view (like `welcome.blade.php`):
```HTML
<x-primary-button>
    Click Me
</x-primary-button>
```

**3. Layout Components:** Your `x-app-layout` is a component that wraps your content (the `$slot`) inside the main HTML structure (navbar, footer, etc.).

## See Also

- [[Blade Views and Asset Helper]]
    
- [[_Tailwind CSS]]