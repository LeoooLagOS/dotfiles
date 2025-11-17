---
tags:
  - concept
  - javascript
  - web-development
  - networking
  - frontend
category: language
status:
  - learning
related: "[[JavasScript Fetch API]]"
date: 2025-11-18
---
# AJAX (Asynchronous JavaScript and XML)
## 📝 One-Sentence Summary
*AJAX is a technique that allows a web page to send and receive data from a server in the background, updating parts of the page without requiring a full reload.*
## 💡 Analogy
*Imagine you're in a restaurant (a webpage). **Without AJAX**, if you want more water, you have to get up, leave the restaurant, go to the kitchen (a new page request), get your water, and come back to your table (the page reloads). **With AJAX**, you just signal a waiter (JavaScript) who goes to the kitchen for you (asynchronous request) and brings the water (data) back to your table without you ever having to leave your seat (no page reload).*
## 🔑 Key Details
- **What it is:** 
	- A set of web development techniques to create asynchronous web applications. It lets JavaScript communicate with a server after the page has loaded.
- **Why it exists:** 
	- To create fast, dynamic, and responsive web applications that feel like desktop software (e.g., live search, auto-saving, updating a score).
## 🔗 Connections & Implementations
* Despite the "X" for "XML", **[[JSON]]** is the modern standard format for transferring data with AJAX.
* It's the core technology behind interactive web apps. 
	* The Pokémon quiz used it to fetch new questions without reloading the page.
* **Implementations:**
    1.  **jQuery:** `$.ajax()`, `$.get()`, `$.post()`
    2.  **Modern JavaScript:** [[JavaScript Fetch API]] (Promise-based, the new standard).
    3.  **Older JavaScript:** `XMLHttpRequest` (The original browser object, more complex).
## 👍 Pros & 👎 Cons
-   **✅ Pros:** 
	- Vastly improved user experience, reduced server load (only small data packets are sent), increased responsiveness.
-   **❌ Cons:** 
	- Can be complex to manage state on the frontend; back/forward browser buttons can be tricky to handle without a proper framework.
## See Also
- [[JavaScript Fetch API]]
- [[jQuery Fundamentals]]
- [[HTTP Methods]]
- [[JSON]]