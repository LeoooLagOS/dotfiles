---
tags:
  - concept
  - css
  - html
category: web-development
status:
  - learning
related: "[[CSS Positioning]]"
date: 2025-10-16
---

# Applying CSS to HTML

## 📝 One-Sentence Summary
CSS rules can be applied to [[_HTML]] documents using three methods—inline, internal, or external—with external stylesheets being the most efficient and standard professional practice.

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
    <style>
        .body-container {
            background-color: red;
            width: 100px;
            height: 100px;
            position: relative;
        }
        .right-circle {
            background: black;
            width: 50px;
            height: 50px;
            border-radius: 50%;
            position: absolute;
            right: 0px;
            top: 0px;
        }
    </style>
</head>
<body>
    <div class="body-container">
        <div class="right-circle"></div>
    </div>
</body>
```

### 3. External Stylesheet (Method 3 - Best Practice)

CSS rules are placed in a separate `.css` file and linked from the HTML document's `<head>`.

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

## See Also

- [[CSS Selectors]]
    
- [[HTML Structure]]
    
- [[CSS Specificity]]