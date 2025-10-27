---
tags:
  - concept
  - css
  - html
  - frontend
category: web-development
status:
  - learning
related: "[[Applying CSS to HTML]]"
date: 2025-10-26
---

# CSS Selectors

## 📝 One-Sentence Summary
CSS Selectors are the patterns used in stylesheets to target specific HTML elements to which a set of CSS rules should apply.
## 💡 Analogy
Think of HTML elements as people in a large room. A CSS selector is how you **call out** specific people or groups to give them instructions (styles). You could call out: 
* "Everyone wearing a blue shirt" (a **Class selector**). 
* "The person named 'Alice'" (an **ID selector**). 
* "All children in the room" (a **Type selector** like `p`). 
* "Only the first person in line" (a **Pseudo-class** like `:first-child`).
## 🔑 Key Details

Selectors are the first part of a CSS rule. They define *which* elements the declarations (like `color: blue;` or `margin: 10px;`) will affect. 
### Common Selector 
Types 
1. **Type Selectors (Tag Name)**: Selects all elements of a given type. 
	* **Syntax**: `elementName` 
	* **Example**: `p { color: gray; }` (Selects all `<p>` tags). 
2. **Class Selectors (`.`)**: Selects all elements that have a specific `class` attribute. 
	* **Syntax**: `.className` 
	* **Example**: `.highlight { background-color: yellow; }` (Selects `<p class="highlight">` and `<div class="highlight">`). 
	* **Reusability**: Highly reusable; an element can have multiple classes (`<div class="card featured">`). The core of most CSS methodologies. 
3. **ID Selectors (`#`)**: Selects a single element that has a specific `id` attribute. 
	* **Syntax**: `#idName` 
	* **Example**: `#main-header { font-size: 2rem; }` (Selects `<header id="main-header">`). 
	* **Uniqueness**: An ID **must be unique** within an HTML document. Primarily used for JavaScript targeting or page anchors. 
4. **Attribute Selectors (`[]`)**: Selects elements based on the presence or value of an attribute. 
	* **Syntax**: `[attribute]`, `[attribute=value]`, `[attribute^=value]` (starts with), `[attribute$=value]` (ends with), etc. 
	* **Example**: `input[type="text"] { border: 1px solid gray; }` (Selects text input fields). 
5. **Pseudo-classes (`:`)**: Select elements based on their state or position. 
	* **Syntax**: `:pseudo-class` 
	* **Example**: `a:hover { text-decoration: underline; }` (Styles links when the mouse hovers over them). 
	* Other examples: `:first-child`, `:last-child`, `:nth-child(n)`, `:focus`, `:checked`. 
6. **Pseudo-elements (`::`)**: Select and style a specific part *of* an element. 
	* **Syntax**: `::pseudo-element` 
	* **Example**: `p::first-line { font-weight: bold; }` (Styles the first line of every paragraph). 
	* Other examples: `::before`, `::after`, `::selection`. 
### Combinators (Combining Selectors) 
These specify the relationship between elements. 
* **Descendant Combinator (` ` space)**: 
	* Selects elements that are descendants (nested inside) another element. Ex: `div p` (selects all `<p>` inside a `<div>`). 
* **Child Combinator (`>`)**: 
	* Selects elements that are direct children of another element. Ex: `ul > li` (selects `<li>` directly inside a `<ul>`, but not nested further). 
* **Adjacent Sibling Combinator (`+`)**: 
	* Selects an element that immediately follows another element at the same level. Ex: `h2 + p` (selects the first `<p>` right after an `<h2>`). 
* **General Sibling Combinator (`~`)**: 
	* Selects elements that follow another element at the same level (not necessarily immediately). Ex: `h2 ~ p` (selects all `<p>` tags that come after an `<h2>`). 
## See Also 
- [[Applying CSS to HTML]] 
- [[HTML Structure]] 
- [[CSS Specificity]] 
- [[CSS Box Model]]