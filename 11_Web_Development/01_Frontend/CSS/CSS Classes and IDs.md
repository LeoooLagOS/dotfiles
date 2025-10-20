---
tags:
  - concept
  - css
  - html
category: web-development
status:
  - learning
related: "[[Applying CSS to HTML]]"
date: 2025-10-19
---

# CSS Classes and IDs

## 📝 One-Sentence Summary
Classes and IDs are CSS selectors used to target specific HTML elements, with classes being reusable for multiple elements and IDs being unique to a single element.

## 💡 Analogy
Think of people in a room. 
* An **ID** is like a person's unique name (`#john-doe`). You use it to address only one specific person. 
* A **Class** is like a group description (`.students`, `.teachers`). You can apply it to multiple people, and a single person can belong to multiple groups (e.g., `<p class="student leader">`).
## 🔑 Key Details
- **Class Selectors (`.`):**
    - The most common way to style elements.
    - **Reusable:** A class can be applied to many elements on a page.
    - An element can have multiple classes, separated by spaces (`<div class="box red-box">`).
    - The selector in CSS starts with a dot (e.g., `.box`).

- **ID Selectors (`#`):**
    - **Unique:** An ID should only be used once per HTML page.
    - They have a higher specificity than classes, meaning their styles are harder to override.
    - Primarily used for major page landmarks or for targeting with JavaScript.
    - The selector in CSS starts with a hash (e.g., `#main-header`).

## 🔗 Implementation Example
This example refactors a shape from inline styles to using reusable classes.

**Before (Inline CSS):**
```html
<div style="background-color: red; width: 150px; height: 150px; position: relative;">
    <div style="background: black; width: 50px; ..."></div>
    <div style="background: black; width: 50px; ..."></div>
</div>
````

**After (Using Classes):** The HTML is cleaner and describes the elements' roles. The CSS is centralized and reusable.

```HTML
<div class="mickey-head">
    <div class="circle ear-left"></div>
    <div class="circle ear-right"></div>
</div>
```

```CSS
/* style.css */
.mickey-head {
    background-color: red;
    width: 150px;
    height: 150px;
    position: relative;
}

/* This class can be reused for all circles */
.circle {
    background: black;
    border-radius: 100%;
    position: absolute;
}

.ear-left { ... }
.ear-right { ... }
```

## See Also

- [[CSS Specificity]]
    
- [[Applying CSS to HTML]]