---
tags:
  - concept
  - javascript
  - design-pattern
category: language
status:
  - learning
related: "[[JavaScript Functions]]"
date: 2025-11-18
---
# IIFE (Immediately Invoked Function Expression)
## 📝 One-Sentence Summary
*An IIFE is a JavaScript function that is defined and executed at the same time, primarily to create a private scope for variables.*
## 💡 Analogy
*Think of an IIFE as a **private, soundproof workshop** 🏭. You can go inside, build a project, and use all the tools and materials you want. When you're done, you leave the workshop and close the door. All your tools and leftover materials (variables) stay locked inside, so they don't litter the main factory floor (the global scope) and won't conflict with anyone else's work.*
## 🔑 Key Details
- **What it is:** 
	- A common JavaScript design pattern. You wrap an anonymous function in parentheses `()` and then immediately call it with another set of parentheses `()`.
- **Why it exists:** 
	- To avoid "global scope pollution." Before modern JS modules, any variable declared outside a function was global, which could lead to conflicts if two different scripts used the same variable name (like `count`).
## 🔗 Connections & Implementations
**Syntax (from your P9):**
```javascript
(function() {
    // This code runs immediately.
    var count = 0; // 'count' is private to this function.
    
    $("#btn1").click(function(){
        count++; // It can be used by other functions *inside* the IIFE.
        // ...
    });

})(); // The final () executes the function.

// 'count' is not accessible here in the global scope.
```

## 👍 Pros & 👎 Cons

- **✅ Pros:** Prevents global variable conflicts, keeps code clean and modular.
    
- **❌ Cons:** Less necessary in modern JavaScript, which uses `let`/`const` (block-scoping) and [[JavaScript Modules]] (ES6 Modules) to achieve better scope control.
## See Also

- [[JavaScript Functions]]
    
- [[JavaScript Scope]]
    
- [[JavaScript Modules]]