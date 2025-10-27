---
tags:
  - concept
  - css
category: web-development
status:
  - learning
related: "[[CSS Positioning]]"
date: 2025-10-19
---

# CSS z-index

## 📝 One-Sentence Summary
The `z-index` property specifies the stack order of positioned elements, allowing you to control which element appears in front of or behind others.
## 💡 Analogy
Think of `z-index` as numbering sheets of clear plastic on an overhead projector. A sheet with `z-index: 10` will be placed on top of a sheet with `z-index: 5`, making it appear in front. Elements without a `z-index` are like a single base drawing that all the numbered sheets are placed on top of.
## 🔑 Key Details
- **What it is:** 
	- A CSS property that controls the vertical stacking order (along the z-axis) of an element.
- **Why it exists:** 
	- To manage the layout of overlapping elements, which is common in complex UIs like dropdown menus, pop-up modals, and custom graphics.
- **Important Rule:** 
	- `z-index` **only works on positioned elements**. This means the element must have a `position` value of `absolute`, `relative`, `fixed`, or `sticky`. It has no effect on `position: static` (the default).

## 🔗 Stacking Context
Elements are not just stacked globally on a page. They are stacked within a **"stacking context."** A new stacking context is created by an element that has both a `position` value other than `static` and a `z-index` value.
* Child elements inside a stacking context are stacked relative to each other.
* The entire group of child elements then moves up or down the stack as a single unit in the parent's stacking context.

### Code Example
In this example from a "battery" component, the text needs to appear on top of all other layers.

```html
<div class="battery">
    <div class="battery-body">...</div>
    <div class="battery-cap-bottom">...</div>
    <div class="battery-text">50%</div>
</div>
````
```CSS

.battery {
    position: relative; /* Creates a stacking context */
}

.battery-body {
    position: absolute;
    /* z-index is auto (effectively 0) */
}

.battery-text {
    position: absolute;
    z-index: 1; /* A higher value places this element in front */
}
```

Because `.battery-text` has a `z-index` of `1` and the other positioned elements have a default `z-index` of `auto` (treated as `0`), the text is guaranteed to be rendered on top.

## See Also

- [[CSS Positioning]]
    
- [[CSS Box Model]]