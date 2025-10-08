---
tags:
  - concept
  - cs-fundamental
  - memory
category: <cs-fundamental>
status:
  - learning
related:
date: 2025-09-23
---

# Dynamic Memory Allocation

## 📝 One-Sentence Summary
Dynamic memory allocation is the process of assigning memory for variables at runtime from a pool of memory called the heap, which is necessary when the amount of memory needed is not known at compile time.

## 💡 Analogy
It's like **renting a storage unit** during a move. You don't know exactly how many boxes you'll have beforehand, so you go to a facility (the heap) and request a unit of a specific size at that moment. You are given a key (a pointer), and you are responsible for emptying the unit and returning the key when you're done.

## 🔑 Key Details
- **Heap vs. Stack:** 
	- Stack memory is small, fast, and managed automatically for local variables. 
	- Heap memory is a large pool of memory that must be managed manually (in languages like C) or automatically by a garbage collector (in languages like Java/Python). 
- **The Process:** 
	1. Request memory. 
	2. Use the memory. 
	3. Release (free) the memory.

## 🔗 Connections & Implementations
- **In C:** Managed manually with `malloc()` and `free()`. See [[Dynamic Memory Allocation in C]]. 
- **In Java/Python:** Managed automatically by a [[Garbage Collection|Garbage Collector]].
