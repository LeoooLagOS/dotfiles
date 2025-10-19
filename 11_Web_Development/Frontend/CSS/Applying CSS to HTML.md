---
tags:
  - concept
  - css
  - html
category: web-development
status:
  - learning
related: "[[Semantic HTML]]"
date: 2025-10-16
---

# Applying CSS to HTML

## 📝 One-Sentence Summary
[[_CSS]] rules can be applied to [[_HTML]] documents using three methods—inline, internal, or external—with external stylesheets being the most efficient and standard professional practice to separate a website's structure from its presentation

## 💡 Analogy
Think of styling a person. 
* **Inline:** 
	* Whispering a specific style instruction directly to one person (`<p style="...">`). It's private and doesn't affect anyone else. 
* **Internal:** 
	* Announcing a set of style rules for everyone in the room (`<style>`). It applies to everyone present on that one page. 
* **External:** 
	* Posting a "Dress Code" book outside the room (`<link rel="stylesheet">`). Anyone from any room can read and follow the same rules, ensuring consistency.
## 🔑 Key Details
The evolution from inline to external styles is a core principle of web development, promoting a "Separation of Concerns" between a page's structure ([[_HTML]]) and its presentation ([[_CSS]])

### Unstyled HTML (The Foundation)
This is the baseline document containing only the semantic structure and content, with no styling applied. This corresponds to your `index-no-css.html` file. 

**Example (`index-no-css.html`):** 
```html 
<body> 
	<header> 
		<h1>Mi Página Personal</h1> 
	</header> 
	<main> 
		<section> 
			<h2>Mi GIF Favorito</h2> 
			<img src="img/gato-programando.gif"...>
		</section> 
	</main> 
</body>
````

### 1. Inline Styles (Method 1)
CSS is written directly inside an element's `style` attribute. This is highly specific and generally discouraged.

**Example from notes:**
```html
<body>
    <div style="width: 100px; height: 100px; background: red; position: relative;">
        <div style="width: 50px; height: 50px; background: black; border-radius: 50%; position: absolute; right: 0; top: 0;"></div>
    </div>
</body>
````

### 2. Internal Stylesheet (Method 2)

CSS rules are placed within a `<style>` tag in the `<head>` of the HTML document. This is better, as it introduces reusable classes for that page.

**Example from notes :**
```HTML
<head> 
	<title>BUAP - Mi Página Personal (con CSS)</title> 
	<style> 
		body { 
			background-color: #fff5f0; 
			font-family: 'Segoe UI', sans-serif; 
			} 
		header { 
			text-align: center; 
			background: linear-gradient(135deg, #e84000, #a82c00); 
			} 
			/* ... all other styles ... */ 
	</style> 
</head> 
<body> 
	<header> ... </header> 
	<main> ... </main> 
</body>
```

### 3. External Stylesheet (Method 3 - Best Practice)

CSS rules are placed in a separate `.css` file and linked from the HTML document's `<head>`.
This is the best practice. All CSS rules are placed in a separate `.css` file (e.g., `style.css`), and the HTML file links to it. This allows you to use the same styles across many pages.

**Example from notes:**
```HTML
<head>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="body-container">
        <div class="left-circle"></div>
        <div class="right-circle"></div>
        <div class="head-element"></div>
    </div>
</body>
```

**CSS**
```CSS
/* style.css */
.body-container {
    background-color: red;
    width: 100px;
    height: 100px;
}
/* ... etc. */
```

## 👍 Pros & 👎 Cons

|**Method**|**👍 Pros**|**👎 Cons**|
|---|---|---|
|**Internal**|Good for single-page projects; keeps everything in one file.|Not reusable across multiple pages; mixes concerns.|
|**External**|**Best Practice.** Reusable, clean, easier to maintain, better for performance.|Requires managing at least two separate files.|
|**Inline**|Useful for very specific, one-time style overrides.|Bad for maintenance; clutters HTML; generally avoided|
## See Also

- [[HTML Structure]]
- [[Semantic HTML]]
- [[CSS Boc Model]]
- [[CSS Selectors]]
- [[CSS Specificity]]