---
tags:
  - overview
  - concept
  - framework
  - css
  - frontend
category: web-development
status: learning
related: "[[CSS Selectors]]"
date: 2025-11-05
---
# _Tailwind CSS_

## 📝 One-Sentence Summary
*Tailwind CSS is a utility-first framework that provides thousands of small, single-purpose classes to build custom designs directly in your HTML without writing custom CSS.*
## 💡 Analogy
*Tailwind is like a **giant box of tiny, single-purpose Lego blocks**. Instead of custom-building a "wall" component, you build it by combining small blocks like `flex`, `p-4` (padding), `bg-blue-500` (background color), and `rounded-lg` (border radius) directly in your HTML.*
## 📜 History & Creator
*Tailwind CSS was created by **Adam Wathan** and first released in 2017. It was created to solve the problem of "CSS-at-scale" by avoiding custom class names and the complexity of managing large, semantic stylesheets.*
## 🔑 Core Philosophy & Design
* **Utility-First:** 
	* The core idea. Every class does one small, specific thing.
* **No Pre-built Components:** 
	* Unlike Bootstrap, Tailwind doesn't give you ready-made components like `.card` or `.btn`. It gives you the *tools* to build your own custom ones.
* **Build-Process-Reliant:** 
	* It is designed to be used with a build tool that scans your files and generates an optimized CSS file with *only* the classes you actually used.
* **Mobile-First:** 
	* Uses responsive prefixes (e.g., `md:`, `lg:`) to apply styles at different screen sizes.
## ⚙️ Key Details
- **What it is:** 
	- A utility-first CSS framework.
- **Why it exists:** 
	- To allow for rapid prototyping and building custom designs without leaving your HTML, and to avoid the "cascade" and specificity wars of traditional CSS.
- **Core Functions/Components:** 
	- Utility classes, a `tailwind.config.js` file for customization, and a required build process (JIT/Just-in-Time engine).
## 🔗 Connections & Implementations
* Requires a [[Tailwind CSS Build Process]] using tools like [[Vite]] or [[PostCSS]].
* Extremely popular in [[_Laravel]] (where it's included by default) and [[_React]] communities.
* Used by writing classes like `flex justify-center p-6 md:text-left`.
## See Also
- [[Tailwind CSS Build Process]]
- [[Vite]]
- [[CSS Specificity]]