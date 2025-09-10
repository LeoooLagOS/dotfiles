---
tags:
  - concept
  - algorithm-pattern
  - dsa
category: <cs-fundamental>
status: <learning>
related: '"[[<Another Core Concept>]]"'
date: 2025-09-10
---

# Two-Pointer Technique.md

## 📝 One-Sentence Summary
*The Two-Pointer Technique is an algorithmic pattern that uses two pointers to iterate through a data structure, typically an array or list, until they meet or cross, often for searching or in-place modifications.*

## 💡 Analogy
*It's like two people reading the same book from opposite ends. One starts at the first page (left pointer) and one at the last page (right pointer). They read towards the middle, comparing notes or swapping pages until they meet.*

## 🔑 Key Details
- **What it is:** A method using two index variables to traverse a data structure. The pointers can move towards each other, away from each other, or in the same direction at different speeds. 
- **Why it exists:** It is a highly efficient way to solve problems involving sorted arrays, palindromes, or in-place reversals, typically reducing time complexity to O(n) and space complexity to O(1). 

## 🔗 Connections & Implementations
- Used to solve: '[[Reverse String (Python)]]'

## 👍 Pros & 👎 Cons
- **Advantages:** - 
	- Extremely efficient in both time (O(n)) and space (O(1)). 
- **Disadvantages:** - 
	- Often requires the input data to be sorted first.

## See Also
'[[Sliding Window Technique]]'
