---
tags:
  - concept
  - javascript
  - jquery
  - library
  - frontend
category: language
status:
  - learning
related: "[[JavaScript DOM Manipulation]]"
date: 2025-10-19
---

# jQuery Fundamentals

## 📝 One-Sentence Summary
jQuery is a fast, small, and feature-rich JavaScript library designed to simplify HTML DOM tree traversal and manipulation, as well as event handling and animation.
## 💡 Analogy
Think of JavaScript as a large, complex toolbox with many individual tools. jQuery is like a powerful, multi-purpose Swiss Army knife. It combines the most common tools (finding elements, reacting to clicks, changing styles) into one easy-to-use package, letting you work much faster.
## 🔑 Key Details
The motto of jQuery is "write less, do more." It achieves this through a clear and concise syntax.

### The Core Syntax: `$(selector).action()`
1.  **`$`**: 
	1. This is an alias for the `jQuery` function. It's the starting point for almost everything.
2.  **`selector`**: 
	1. A string containing a CSS selector (like `'#myId'`, `'.myClass'`, or `'div'`) that tells jQuery which HTML element(s) you want to work with.
3.  **`action()`**: 
	1. A jQuery method that performs an action on the selected element(s), like `.hide()`, `.css('color', 'red')`, or `.click()`.

### The "Document Ready" Handler
To prevent JavaScript from running before the page is fully loaded, all jQuery code should be wrapped in a "document ready" handler. This is a crucial best practice.

```javascript
// This function will only run once the DOM is ready for manipulation.
$(function() {
    // All your jQuery code goes here...
});
````

## 🔗 Common Actions & Examples

### DOM Selection

```JavaScript

// Select an element by its ID
$('#myId');

// Select all elements with a specific class
$('.myClass');

// Select all <p> tags
$('p');
```

### Event Handling

This code waits for a user to click a button, then runs a function.

```JavaScript
$('#myButton').click(function() {
    alert('Button was clicked!');
});
```

### DOM Manipulation

These actions change the HTML and CSS of the page dynamically.

```JavaScript
// Get or set the value of an input field
$('#myInput').val(); // Get value
$('#myInput').val('New value'); // Set value

// Change an element's CSS
$('.myClass').css('background-color', 'blue');

// Add or remove a CSS class (best practice)
$('#myDiv').addClass('is-active');
$('#myDiv').removeClass('is-active');
$('#myDiv').toggleClass('is-active'); // Adds if missing, removes if present
```

## See Also

- [[JavaScript DOM Manipulation]]
    
- [[CSS Selectors]]
    
- [[HTML Events]]