---
tags:
  - algorithm-pattern
  - problem
  - c
  - array
  - two-pointer
difficulty:
  - easy 
source: '"https://www.hackerrank.com/challenges/reverse-array-c/"'
status:
  - solved
related: "[[Two-Pointer Technique]]"
date: 2025-09-23
---

# Array Reversal (HackerRank)

## 🧠 Problem Summary
Given an array of a user-defined size, reverse its elements in-place.

## 💡 Key Data Structure / Concept
- This problem combines two key ideas: creating an array using [[Dynamic Memory Allocation in C]] and reversing it efficiently with the [[Two-Pointer Technique]].

## 📊 Complexity Analysis
- **Time**: O(n), for both reading and reversing the array. 
- **Space**: O(n), for storing the array itself. The reversal is O(1) auxiliary space.
## 💻 Code Implementation (`<C>`)
```c
#include <stdio.h>
#include <stdlib.h>

int main() {
    int num, *arr, i;
    scanf("%d", &num);
    arr = (int*) malloc(num * sizeof(int));
    
    for(i = 0; i < num; i++) {
        scanf("%d", arr + i);
    }

    int left = 0;
    int right = num - 1;
    while (left < right) {
        int temp = arr[left];
        arr[left] = arr[right];
        arr[right] = temp;
        left++;
        right--;
    }

    for(i = 0; i < num; i++) {
        printf("%d ", *(arr + i));
    }
    
    free(arr);
    return 0;
}
````

## 🔧 Code Breakdown

- `arr = (int*) malloc(num * sizeof(int))`: 
	- Allocates a block of memory on the heap large enough to hold `num` integers and stores the starting address in the pointer `arr`.
    
- `scanf("%d", arr + i)`: 
	- An example of pointer arithmetic. `arr + i` calculates the memory address of the i-th element.
    
- `free(arr)`: 
	- Releases the memory we manually requested, preventing a memory leak.