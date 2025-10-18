---
tags:
  - concept
  - c
  - memory
  - function
category: language
status:
  - learning
related: "[[Dynamic Memory Allocation in C]]"
date: 2025-10-17
---

# realloc in C

## 📝 One-Sentence Summary
The `realloc()` function ("re-allocate memory") is a powerful C standard library function used to resize a previously allocated block of memory.

## 💡 Analogy
`realloc()` is like asking your storage unit manager to **resize your unit**. 
	- If the space next to your unit is free, they might just knock down a wall and **extend your existing unit**. 
	- If there's no adjacent space, they will find a **brand new, larger unit** for you, move all your stuff over automatically, and give you the new key. 
	In both cases, you get a correctly sized unit with all your old data intact.
## 🔑 Key Details
- **Function Signature:** 
	- `void* realloc(void* ptr, size_t new_size);` 
- **What it does:** 
	- It takes a pointer to an existing memory block and a new size. It returns a pointer to the resized memory block. 
- **Important:** 
	- The returned pointer might be different from the original if the data was moved. You must always update your pointer variable with the return value of `realloc()`.
## 🔗 Connections & Implementations
-   Part of the `<stdlib.h>` library, alongside `malloc` and `free`.
-   Used in the [[Dynamic Array in C (HackerRank)]] problem to double the capacity of an inner array when it becomes full.
