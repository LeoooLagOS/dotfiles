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

# calloc in C

## 📝 One-Sentence Summary
The `calloc()` function ("contiguous allocation") allocates a block of memory for an array of elements and initializes all bytes in the allocated block to zero.

## 💡 Analogy
If `malloc()` is like renting a random, empty storage unit (it might have dust or leftover junk inside), `calloc()` is like renting a **brand new, professionally cleaned storage unit**. You're guaranteed that it's completely empty and set to a known state (zero).

## 🔑 Key Details
- **Function Signature:** `void* calloc(size_t num_elements, size_t element_size);` 
- **Key Difference from `malloc`:** 
	- `calloc` takes two arguments: the number of elements and the size of each element. 
	- `calloc` **zero-initializes** the memory block. `malloc` does not; the memory contains garbage values. 
- **Use Case:** 
	- It is preferred over `malloc` when you need to be certain that your allocated memory starts in a clean, zeroed state.
## 🔗 Connections & Implementations
-   Part of the `<stdlib.h>` library.
-   Used in the [[Dynamic Array in C (HackerRank)]] problem to initialize the helper arrays for size and capacity.
