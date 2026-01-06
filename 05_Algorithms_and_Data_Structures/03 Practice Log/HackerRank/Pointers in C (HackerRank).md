---
tags:
  - algorithm-pattern
  - problem
  - c
  - pointers
difficulty:
  - easy 
source: https://www.hackerrank.com/challenges/pointer-in-c/
status:
  - solved
related: "[[Pointers in C]]"
date: 2025-09-23
---

# Pointers in C (HackerRank)

## 🧠 Problem Summary
Complete a function that takes two integer pointers and updates the value of the first to their sum, and the second to the absolute difference of their original values.
## 💡 Key Data Structure / Concept
- This problem is a direct application of using and dereferencing [[Pointers in C]] to modify variables outside a function's local scope.

## 📊 Complexity Analysis
- **Time**: O(1), as the operations are constant time. 
- **Space**: O(1), as only a single temporary variable is used.

## 💻 Code Implementation (`<Language>`)
```c
#include <stdio.h>
#include <stdlib.h> // Required for the abs() function

void update(int *a, int *b) {
    int temp_a = *a;
    *a = *a + *b;
    *b = abs(temp_a - *b);
}
````

## 🔧 Code Breakdown

- `void update(int *a, int *b)`: 
	- Defines a function that takes pointers as arguments, allowing it to modify the original variables passed from `main()`.
    
- `*a = ...`: 
	- The **dereference operator (`*`)** is used to access and change the value at the memory address stored in the pointer `a`.