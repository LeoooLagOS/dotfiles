---
tags:
  - concept
  - cs-fundamental
  - c
  - memory
category: <cs-fundamental>
status:
  - learning
related: "[[Variables and Memory]]"
date: 2025-09-23
---

# Pointers in C

## 📝 One-Sentence Summary
*This note covers the specific syntax and rules for implementing the abstract concept of [[Pointers]] in the C programming language.*

## 💡 Analogy
A pointer is like a **sticky note** with a home address written on it. The sticky note itself doesn't contain a valuable item, but it tells you exactly where to find the house (the memory location) that does contain the valuable item (the data).

## 🔑 Key Details
- **Declaration (`*`)**: 
	- A pointer is declared with an asterisk between the data type and the variable name. `int *ptr;` creates a pointer named `ptr` that can hold the address of an integer. 
- **Address-Of Operator (`&`)**: 
	- This operator gets the memory address of a regular variable. `ptr = &my_variable;` stores the address of `my_variable` in `ptr`. 
- **Dereference Operator (`*`)**: 
	- This operator, when used on an existing pointer, accesses the actual value at the stored memory address. `value = *ptr;` retrieves the data that `ptr` is pointing to.
## 🔗 Connections & Implementations
- Pointers are the mechanism behind [[Dynamic Memory Allocation in C]]. 
- They are essential for passing arguments to functions "by reference," allowing the function to modify the original variable, as seen in the [[Pointers in C (HackerRank)]] problem.
## See Also 
- [[Variables and Memory]] 
- [[Arrays]] (In C, an array name is essentially a pointer to its first element).