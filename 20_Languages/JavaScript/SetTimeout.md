---
tags:
  - concept
  - javascript
  - asynchronous
category: language
status:
  - learning
related: "[[AJAX]]"
date: 2025-11-18
---
# SetTimeout
## 📝 One-Sentence Summary
*`setTimeout` is a JavaScript function that executes a callback function or a piece of code once after a specified delay in milliseconds.*
## 💡 Analogy
*`setTimeout` is like setting a **kitchen timer** ⏲️. You tell the timer *what* to do (e.g., "check the cake") and *how long* to wait (e.g., "1500 milliseconds"). You can then go do other things. The timer will run in the background and only execute your function when the time is up. It is non-blocking.*
## 🔑 Key Details
- **What it is:** 
	- A high-level, asynchronous [[_Web Apis|Web API]]  provided by the browser to schedule tasks.
- **Why it exists:** 
	- To delay the execution of a function without halting the entire program. This is essential for animations, time-based events, and managing application flow.
## 🔗 Connections & Implementations
**Core Syntax:**
`setTimeout(callbackFunction, delayInMilliseconds);`

* **`callbackFunction`**: The function to be executed.
* **`delayInMilliseconds`**: The time to wait (e.g., `1000` = 1 second).

**Example (from P10):**
This code is used to create a 1.5-second pause *after* the user sees the answer, before the next question loads.
```javascript
function valida(id) {
    // ... code to check answer and show alert ...

    // 1. Reveal the correct Pokémon image
    $("#foto").html('<img src="...">');
            
    // 2. Set a timer. The 'cargarPokemon' function will
    //    be executed after 1500ms (1.5 seconds).
    setTimeout(cargarPokemon, 1500); 
}
````

## 👍 Pros & 👎 Cons

- **✅ Pros:** Simple way to schedule code, essential for UI/UX (like hiding notifications or creating game loops), asynchronous.
    
- **❌ Cons:** Can lead to "Callback Hell" if many are nested (though modern async/await patterns help).
    

## See Also

- [[SetInterval]] (For running code _repeatedly_ every X milliseconds)
    
- [[Asynchronous JavaScript]]
    
- [[JavaScript Functions]]