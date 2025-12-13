---
tags: concept
category: cs-fundamental, networking
status: learning
related: "[[Asynchronous JavaScript]]"
date: 2025-12-13
---
# Node.js Event Loop
## 📝 One-Sentence Summary
The Event Loop is the architectural mechanism that enables Node.js to perform non-blocking I/O operations despite being single-threaded, by offloading operations to the system kernel whenever possible.

## 💡 Analogy
The Event Loop is like a **restaurant waiter** (the single thread). The waiter takes an order (an async task) and passes it to the kitchen (system kernel/Libuv). instead of waiting for the food to be cooked, the waiter immediately goes to take the next table's order. When the kitchen rings the bell (callback), the waiter serves the food only when their hands are free (Call Stack is empty).
## 🔑 Key Details
- **What it is:** 
	- A continuous loop that monitors the Call Stack and the Callback Queues. If the Call Stack is empty, it pushes the first task from the queue onto the stack for execution.
- **Why it exists:** 
	- It solves the limitation of single-threaded JavaScript, allowing it to handle high concurrency (thousands of connections) without freezing the server while waiting for slow database or file system operations.
## 🔗 Connections & Implementations
- **Libuv:** The C++ library that powers the Event Loop and handles the thread pool for file I/O.
- **Microtask Queue:** A high-priority queue for **Promises** (`.then`, `.catch`) and `process.nextTick()`. The loop empties this queue *completely* before moving to the next phase.
- **Macrotask Queue:** A lower-priority queue for `setTimeout`, `setInterval`, and I/O callbacks.
## 👍 Pros & 👎 Cons
- **👍 Pros:** 
	- Extremely efficient for I/O-heavy applications (APIs, real-time apps); low memory overhead compared to thread-per-request models.
- **👎 Cons:** 
	- Poor performance for CPU-intensive tasks (e.g., image processing, video encoding), which can block the single thread and freeze the entire loop.
## See Also
- [[Promises and Async-Await]]
- [[Concurrency vs Parallelism]]