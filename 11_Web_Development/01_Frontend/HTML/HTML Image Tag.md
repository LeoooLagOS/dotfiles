---
tags:
  - concept
  - html
category: web-development
status:
  - learning
related: "[[Semantic HTML]]"
date: 2025-10-19
---

# HTML Image Tag

## 📝 One-Sentence Summary
The `<img>` tag is used to embed images, including static formats like JPG/PNG and animated formats like GIFs, into an HTML document.

## 💡 Analogy
Think of the `<img>` tag as a picture frame on your wall. The `src` attribute is the actual photograph you put inside the frame, and the `alt` attribute is a label on the back describing the photo for someone who can't see it.
## 🔑 Key Details
The `<img>` tag is an "empty" tag, meaning it doesn't have a closing tag. It works through attributes that define the image source and its behavior.
### Core Attributes
- **`src` (Source):** 
	- The most important attribute. It specifies the path or URL to the image file. The path can be relative (within your project) or absolute (a full URL to another website).
- **`alt` (Alternative Text):** 
	- **Crucial for accessibility.** Provides a text description of the image for screen readers and search engines. It also appears if the image fails to load.
- **`width` / `height`:** 
	- Sets the dimensions of the image in pixels. While functional, it's considered best practice to control sizing with CSS for better flexibility and responsiveness.

## 🔗 Implementation & Best Practices

**Code Example (from P1):**
```html
<img src="img/salchi-mexicano.gif" alt="A dachshund dog wearing a sombrero and a sarape" width="300">

<img src="img/carro.jpg" alt="A photo of a classic Porsche 911" width="100">
````

### 👍 Best Practices

1. **Always use the `alt` attribute.** Be descriptive but concise.
    
2. **Use correct file paths.** Relative paths (`img/photo.jpg`) are best for project images.
    
3. **Do not use spaces in filenames.** Use hyphens (`-`) or underscores (`_`) instead (e.g., `my-cool-image.png`). This prevents broken links on some web servers.
    
4. **Optimize images for the web.** Large image files slow down your website. Use tools to compress them without losing too much quality.
    
5. **Prefer CSS for sizing.** Use CSS `width` and `height` properties instead of HTML attributes for better control over layout and responsiveness.
    

## See Also

- [[File Paths]]
    
- [[Applying CSS to HTML]]