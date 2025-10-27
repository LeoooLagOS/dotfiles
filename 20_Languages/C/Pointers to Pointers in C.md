---
tags:
  - concept
  - c
  - memory
  - pointers
category: language
status:
  - learning
related: "[[Pointers in C]]"
date: 2025-10-17
---

# Pointers to Pointers in C

## 📝 One-Sentence Summary
A pointer-to-a-pointer (e.g., `int **ptr`) is a variable that stores the memory address of another pointer, enabling the creation of dynamic, multi-dimensional array-like structures.

## 💡 Analogy
If a regular [[Pointers in C|pointer]] is a sticky note with a **home address** written on it, a pointer-to-a-pointer is a sticky note with the **address of a different sticky note** written on it. 
You have to follow two addresses to get to the final house. It's a level of indirection.
## 🔑 Key Details
- **What it is:** 
	- A variable that holds the address of a pointer variable. 
- **Why it exists:** 
	- It is the primary mechanism in C for creating a "dynamic array of arrays," where each inner array can have a different, changeable size. `int **arr` can be thought of as an array where each element is an `int *`.

## 🔗 Connections & Implementations
- This is the core data structure used to solve the [[Dynamic Array in C (HackerRank)]] problem.