---
tags:
  - concept
  - html
category: web-development
status:
  - learning
related: "[[HTML Structure]]"
date: 2025-10-19
---

# Semantic HTML

## 📝 One-Sentence Summary
Semantic HTML uses tags that describe the meaning and structure of the content they contain, making websites more accessible, readable, and SEO-friendly.

## 💡 Analogy
Think of a document. A non-semantic document uses generic boxes (`<div>`) for everything. A semantic document is like a well-structured newspaper with clear sections: a main title (`<header>`), a primary content area (`<main>`), different articles (`<article>`), and contact information at the bottom (`<footer>`). You know what each part is just by its name.

## 🔑 Key Details
- **What it is:** 
	- A practice of using HTML tags that accurately describe their purpose. Instead of just using `<div>` for everything, you use tags that convey meaning. 
- **Why it exists:** 
	- **Accessibility:** 
		- Screen readers use semantic tags to navigate a page and explain its structure to visually impaired users. 
	- **SEO:** 
		- Search engines like Google better understand the content and hierarchy of your page, which can improve your ranking. 
	- **Readability:** 
		- Your code becomes easier for you and other developers to read and maintain.
## 🔗 Connections & Implementations
- **`<header>`**: 
	- Introductory content for a section or the entire page. Usually contains the logo, navigation, and main title. 
- **`<footer>`**: 
	- The footer of a section or the page. Contains copyright info, contact details, or related links. 
- **`<main>`**: 
	- Represents the dominant, central content of the `<body>`. There should only be one `<main>` tag per page. 
- **`<section>`**: 
	- A thematic grouping of content. It should almost always have a heading (`<h1>`-`<h6>`) as a child. 
- **`<article>`**: 
	- Self-contained content that could be distributed independently (e.g., a blog post, a news story). 
- **`<nav>`**: 
	- Contains major navigation links. 
- **`<aside>`**: 
	- Content that is tangentially related to the main content (e.g., a sidebar, a callout box).

### Example: Refactoring a `<div>`-based layout
This example refactors the structure of a personal webpage to be more semantic.

**Before (Non-Semantic):**
```html
<body>
    <div> <h1>My Page</h1>
    </div>
    <div> <div> <h2>About Me</h2>
            <p>...</p>
        </div>
        <div> <h2>My Hobbies</h2>
            <ul>...</ul>
        </div>
    </div>
    <div> <p>&copy; 2025</p>
    </div>
</body>
````

**After (Semantic):**

**HTML**

``` html
<body>
    <header>
        <h1>My Page</h1>
    </header>
    <main>
        <section>
            <h2>About Me</h2>
            <p>...</p>
        </section>
        <section>
            <h2>My Hobbies</h2>
            <ul>...</ul>
        </section>
    </main>
    <footer>
        <p>&copy; 2025</p>
    </footer>
</body>
```

## See Also

- [[HTML Structure]]
    
- [[Accessibility]]