---
tags:
  - concept
  - cs-fundamental
  - c
  - memory
category: <cs-fundamental>
status:
  - learning
related: "[[Pointers in C]]"
date: 2025-09-23
---

# Dynamic Memory Allocation in C

## 📝 One-Sentence Summary
Dynamic memory allocation is the manual process of requesting a block of memory from the operating system at runtime, which is essential when the required memory size is not known at compile time.
## 💡 Analogy
It's like **renting a storage unit**. You tell the facility manager (`malloc`) exactly how much space you need. They give you a key (`pointer`) to a specific unit. You can use it as you wish, but you are responsible for telling the manager when you're done (`free`) so they can rent it to someone else.

## 🔑 Key Details
- **`malloc()`**: The "memory allocation" function. It takes a size in bytes as an argument and returns a `void` pointer to the start of the allocated block of memory on the heap. 
- **`sizeof()`**: An operator used to calculate the size (in bytes) of a data type. It's used with `malloc` to ensure you request the correct amount of memory (e.g., `malloc(10 * sizeof(int))`). 
- **`free()`**: Releases a block of memory that was previously allocated, returning it to the system. Failing to `free` memory results in a "memory leak.".

## 🔗 Connections & Implementations
- `malloc` always returns a `[[Pointers in C|pointer]]`. 
- This is the primary method for creating variable-sized `[[Arrays]]` in C. 
- Used in the `[[Array Reversal (HackerRank)]]` problem to create an array of a user-specified size.
