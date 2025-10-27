---
tags:
  - concept
  - css
  - frontend
category: web-development
status:
  - learning
related: "[[CSS Box Model]]"
date: 2025-10-26
---

# CSS Units

## 📝 One-Sentence Summary
CSS units define the size and magnitude of properties like length, padding, margin, and font size, and can be absolute (fixed) or relative (based on another value).

## 💡 Analogy
Think of units like measuring tools. 
* **Absolute Units (`px`)**: 
	* Like using a **fixed ruler** measured in centimeters or inches. The size is always the same regardless of context. 
* **Relative Units (`rem`, `em`, `%`, `vw`/`vh`)**: 
	* Like using measurements **based on something else**. `rem`/`em` are like saying "twice the standard text size," `%` is like "half the width of the container," and `vw`/`vh` are like "10% of the screen's width/height."
## 🔑 Key Details

### Absolute Units
* **`px` (Pixels)**: The most common absolute unit. Represents one pixel on the screen. Useful for things that should not scale, like border widths.

### Relative Units
* **`rem` (Root Em)**: Relative to the font size of the root `<html>` element. **Highly recommended for sizing layouts, padding, margins, and text** because it scales predictably with user preferences and accessibility settings. (e.g., `padding: 2rem;` is typically `2 * 16px = 32px`).
* **`em`**: Relative to the font size of the *parent element*. Can be tricky as nesting elements changes the base size. Often used for sizing elements relative to the text within them.
* **`%` (Percentage)**: Relative to the size of the *parent element*. Commonly used for widths (`width: 50%;`).
* **`vw` (Viewport Width)**: Represents 1% of the browser window's width. `100vw` is the full width.
* **`vh` (Viewport Height)**: Represents 1% of the browser window's height. `100vh` is the full height.

## 🔗 Connections & Implementations
Choosing the right unit is crucial for **Responsive Design** and **Accessibility**.
* Using `rem` for spacing and typography allows layouts to scale gracefully if the user changes their default browser font size.
* Using `%`, `vw`, and `vh` is essential for creating fluid layouts that adapt to different screen sizes.
* Using `px` is best for fine details like borders where consistent rendering across devices is needed.

**Example:**
```css
.container {
  max-width: 1200px; /* Fixed maximum width */
  margin: 0 auto; /* Center the container */
  padding: 2rem; /* Spacing scales with root font size */
  font-size: 1rem; /* Base font size */
}

.title {
  font-size: 1.5rem; /* 1.5 times the container's font size */
  margin-bottom: 1rem; /* Spacing scales with root font size */
}

.sidebar {
  width: 25%; /* Takes 1/4 of the parent container's width */
}
````

## See Also

- [[CSS Box Model]]
    
- [[Responsive Design]]
    
- [[Accessibility]]
