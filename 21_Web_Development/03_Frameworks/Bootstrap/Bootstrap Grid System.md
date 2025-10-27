---
tags:
  - concept
  - bootstrap
  - css
  - framework
  - frontend
category: web-development
status:
  - learning
related: "[[CSS Flexbox]]"
date: 2025-10-19
---

# Bootstrap Grid System

## 📝 One-Sentence Summary
The Bootstrap grid is a powerful, mobile-first flexbox system for building responsive layouts of all shapes and sizes using a twelve-column structure.
## 💡 Analogy
Think of your webpage as a sheet of graph paper that is always **12 squares wide**. 
The Bootstrap grid provides "Lego blocks" of different widths (from 1 to 12 squares) that you can use to fill up each row. 
You can set different rules for how these blocks should arrange themselves based on how wide the paper is (the screen size).
## 🔑 Key Details
The grid is built with three main components that work together:

1.  **Container (`.container` or `.container-fluid`)**: 
	* The outermost wrapper that centers and pads your content. `.container` has a fixed max-width, while `.container-fluid` is always 100% wide.
2.  **Row (`.row`)**: 
	* A horizontal wrapper for columns. All columns must be placed inside a row. Rows use flexbox to arrange the columns.
3.  **Column (`.col-*`)**: 
	* The actual content containers. You can specify their width out of the 12 available units for different screen sizes.

## 🔗 Core Concepts

### Breakpoints
Bootstrap is mobile-first. The breakpoints are the screen widths at which your layout can change.
* `xs` (Extra small): `<576px` (This is the default, e.g., `.col-6`)
* `sm` (Small): `≥576px` (e.g., `.col-sm-6`)
* `md` (Medium): `≥768px` (e.g., `.col-md-6`)
* `lg` (Large): `≥992px` (e.g., `.col-lg-6`)
* `xl` (Extra large): `≥1200px` (e.g., `.col-xl-6`)
* `xxl` (Extra extra large): `≥1400px` (e.g., `.col-xxl-6`)

### Column Sizing
You define how many of the 12 columns an element should span at a specific breakpoint.
* `.col-8`: Spans 8 columns on `xs` screens and up.
* `.col-md-4`: Spans 4 columns on `md` screens and up. On smaller screens, it will stack to be 100% wide.
* A common pattern is `.col-12 .col-md-6`, meaning "be full-width on mobile, but half-width on medium screens and larger."

### Ordering
You can change the visual order of columns with `order-*` classes.
* `.order-2`: Will have an order of 2.
* `.order-md-1`: Will have an order of 1 on `md` screens and up.

### Display Utilities
You can responsively show or hide elements using `d-*` classes.
* `.d-none`: Hides the element on all screen sizes.
* `.d-md-block`: Hides the element by default, but displays it as a `block` on `md` screens and up.
* `.d-lg-none`: Displays the element by default, but hides it on `lg` screens and up.

### Code Example
This creates a layout that is a single column on mobile but a two-column layout on medium screens and larger.
```html
<div class="container">
  <div class="row">
    <div class="col-12 col-md-8">Main Content</div>
    <div class="col-12 col-md-4">Sidebar</div>
  </div>
</div>
````

## See Also

- [[CSS Flexbox]]
    
- [[Responsive Design]]