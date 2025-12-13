---
tags: concept
category: language, cs-fundamental
status: learning
related: "[[Event Loop]]"
date: 2025-12-13
---
# Promises and Async-Await
## 📝 One-Sentence Summary
Promises are objects representing the eventual completion (or failure) of an asynchronous operation, while `async/await` is syntactic sugar that allows writing asynchronous code in a cleaner, synchronous-looking style.

## 💡 Analogy
A Promise is like a **buzzer at a busy restaurant**. When you order (start async task), the host gives you a buzzer (Promise object in `Pending` state). You can go do other things. When your table is ready, the buzzer goes off (`Fulfilled`), allowing you to be seated (`.then()`). If the restaurant runs out of food, they tell you (`Rejected`), and you leave (`.catch()`).
## 🔑 Key Details
- **What it is:** 
	- A proxy for a value not necessarily known when the promise is created. It has three states: **Pending**, **Fulfilled** (resolved), and **Rejected**.
- **Why it exists:** 
	- To escape "Callback Hell" (deeply nested callbacks) and provide a standardized way to handle asynchronous errors and success states.
## 🔗 Connections & Implementations
- **[[Fetch API]]:** The modern standard for network requests returns a Promise.
- **[[Node.js Event Loop|Event Loop]]:** Promise callbacks are processed in the **Microtask Queue**, giving them higher priority than `setTimeout`.
- **`try...catch`:** The standard error handling block used with `async/await`.
## 👍 Pros & 👎 Cons
- **👍 Pros:** 
	- greatly improves code readability; standardizes error propagation; allows parallel execution via `Promise.all()`.
- **👎 Cons:** 
	- "awaiting" in a loop can accidentally serialize tasks that should be parallel, slowing down performance.
## See Also
- [[Error Handling in JavaScript]]
- [[Fetch API]]