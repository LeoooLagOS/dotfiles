---
tags:
  - algorithm-pattern
  - problem
  - c
  - array
  - memory
difficulty:
  - easy 
source: https://www.hackerrank.com/challenges/1d-arrays-in-c/
status:
  - solved
related: "[[Arrays]]"
date: 2025-10-09
---

# 1D Arrays in C

## 🧠 Problem Summary
Read an integer `n`, dynamically create an array of size `n`, read `n` integers into it, and print the sum of its elements.

## 💡 Key Data Structure / Concept
This problem introduces [[Dynamic Memory Allocation in C]], a crucial concept for creating [[Arrays|Arrays]] whose size is not known at compile time.

## 💻 Code Implementation (`<C>`)
```c
#include <stdio.h>
#include <stdlib.h> // Required for malloc and free

int main() {
    int n;
    scanf("%d", &n);
    
    // 1. Dynamically allocate memory
    int *arr = (int*)malloc(n * sizeof(int));
    
    int sum = 0;
    // 2. Populate the array and calculate the sum
    for (int i = 0; i < n; i++) {
        scanf("%d", &arr[i]);
        sum += arr[i];
    }
    
    printf("%d\n", sum);
    
    // 3. Free the allocated memory
    free(arr);
    
    return 0;
}
````

## 🔧 Code Breakdown

- `int *arr = (int*)malloc(n * sizeof(int));`: 
	This is the core of C-style dynamic arrays.
    - `sizeof(int)`: 
	    - Calculates the size in bytes of one integer.
    - `malloc(n * ...)`: 
	    - Asks the operating system for a contiguous block of memory large enough to hold `n` integers.
    - `(int*)`: 
	    - Casts the generic memory address returned by `malloc` into a "pointer to an integer."
    - `int *arr = ...`: 
	    - Stores this memory address in the integer pointer `arr`.
- `free(arr);`: 
	- This is the essential counterpart to `malloc`. Since we manually requested memory from the system, we are responsible for returning it when we're done to prevent a memory leak.
