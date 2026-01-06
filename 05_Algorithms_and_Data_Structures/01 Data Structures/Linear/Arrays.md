---
tags:
  - concept
  - dsa
  - data-structure
  - memory
category: <data-structure>
status:
  - learning
related: "[[Linked Lists]]"
date: 2025-10-09
---

# Arrays

## 📝 One-Sentence Summary
An array is a linear data structure that stores a collection of elements of the same data type in a contiguous block of memory, allowing for fast, constant-time access to any element via its index.

## 💡 Analogy
An array is like a **pill organizer or an egg carton**. It has a fixed number of slots, each slot is numbered (the index), and you can instantly access the contents of any slot if you know its number. All slots are physically right next to each other.

## 🔑 Key Details
- **What it is:** 
	- The simplest and most fundamental data structure. It's a collection of items stored at contiguous memory locations. 
- **Why it exists:** 
	- To store multiple elements of the same type together. Its contiguous memory layout allows for highly efficient **random access**. 
- **Random Access:** 
	- The location of any element can be calculated with a simple formula (`start_address + (index * element_size)`), which is why accessing an element by its index (e.g., `my_array[5]`) is an extremely fast O(1) operation. 
- **Fixed vs. Dynamic Size:** 
	- **Static Arrays:** 
		- Have a fixed size that is determined at compile time. 
	- **Dynamic Arrays:** 
		- (Like [[Java - Arraylist|Java's ]]`ArrayList` or [[Python - List|Python's ]]`list`) Can grow or shrink in size at runtime.
## 👍 Pros & 👎 Cons
- **✅ Pros:** 
	- Excellent performance for accessing elements (O(1)). Memory efficient as it has low overhead. 
- **❌ Cons:** 
	- Inefficient for inserting or deleting elements in the middle (O(n)), as it requires shifting subsequent elements. Static arrays have a fixed size.

## 🔗 Connections & Implementations
- [[_C]] requires manual memory management for dynamic arrays using [[Dynamic Memory Allocation in C]]. 
- [[_Java]] provides both basic `int[]` arrays and a more flexible `ArrayList` class. 
- [[_Python]]'s `list` type is a powerful implementation of a dynamic array.