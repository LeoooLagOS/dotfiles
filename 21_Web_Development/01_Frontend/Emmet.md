---
tags:
  - concept
  - tool
  - frontend
  - productivity
  - html
  - css
category: web-development
status:
  - learning
related: "[[HTML Structure]]"
date: 2025-10-26
---

# Emmet

## 📝 One-Sentence Summary
Emmet is a web-developer toolkit that enables high-speed HTML and CSS coding and editing via content-assist abbreviations that expand into full code structures.
## 💡 Analogy
Emmet is like using **shorthand** or **text expansion** specifically for writing HTML and CSS. Instead of typing out every tag and attribute, you type a concise abbreviation (like `ul>li*5>a[href="#"]{Item $}`), press a key (usually `Tab`), and Emmet instantly expands it into the full code structure. It saves a lot of typing! 
## 🔑 Key Details
- **What it is:** 
	- A plugin/feature available in many popular code editors (like VS Code, Sublime Text, etc.). 
- **Why it exists:** 
	- To dramatically speed up the process of writing repetitive HTML and CSS markup. 
- **Core Syntax:** 
	- Uses CSS selector-like syntax to define element structure, nesting, attributes, and content. 
## 🔗 Common Emmet Abbreviations 
* **Element Names:** 
	* `div` -> `<div></div>` 
* **Child:** 
	* `>` (e.g., `ul>li` -> `<ul><li></li></ul>`) 
* **Sibling:** 
	* `+` (e.g., `h1+p` -> `<h1></h1><p></p>`) 
* **Climb-up:** 
	* `^` (Used to move up one level in structure, less common) 
* **Multiplication:** 
	* `*` (e.g., `li*3` -> `<li></li><li></li><li></li>`) 
* **Grouping:** 
	* `()` (e.g., `div>(header>ul>li*2>a)+footer>p` creates a div containing a header and a footer). 
* **ID and Class:** 
	* `#` and `.` (e.g., `div#main.container` -> `<div id="main" class="container"></div>`) 
* **Attributes:** 
	* `[]` (e.g., `a[href="#"]` -> `<a href="#"></a>`) 
* **Text:** 
	* `{}` (e.g., `p{Click Me}` -> `<p>Click Me</p>`) 
* **Item Numbering:** 
	* `$` (e.g., `li.item$*3` -> `<li class="item1"></li><li class="item2"></li><li class="item3"></li>`) 
## See Also 
- [[HTML Structure]] 
- [[CSS Selectors]]