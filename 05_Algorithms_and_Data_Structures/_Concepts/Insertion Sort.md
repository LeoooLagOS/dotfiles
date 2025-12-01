---
tags:
  - sorting
  - algorithm-pattern
  - concept
category: algorithm
status: learning
related: "[[Big O Notation]]"
date: 2025-12-01
---
# Insertion Sort
## 📝 One-Sentence Summary
A simple sorting algorithm that builds the final sorted array one item at a time by comparing the current element to its predecessors and shifting them if necessary.

## 💡 Analogy
**Sorting a hand of playing cards:** You hold the sorted cards in your left hand. You pick up a new card with your right hand and insert it into the correct position in your left hand by moving larger cards to the right to make space.

## 🔑 Key Details
- **What it is:** A comparison-based sorting algorithm. It iterates through an input array and removes one element per iteration, finding the place the element belongs in the sorted list and inserting it there.
- **Why it exists:** It is inefficient for large lists ($O(n^2)$), but it provides significant advantages for:
    1.  **Small data sets:** It has low overhead.
    2.  **Nearly sorted data:** It is adaptive; if the list is already sorted, it runs in $O(n)$ time.
    3.  **Online algorithms:** It can sort a list as it receives it, piece by piece.

## 🔗 Connections & Implementations
This concept relies heavily on **shifting elements** in memory, similar to how we manage **[[Arrays]]**.

### Complexity Analysis
- **Time Complexity:**
    - Worst Case: $O(n^2)$ (Array is in reverse order).
    - Best Case: $O(n)$ (Array is already sorted).
- **Space Complexity:** $O(1)$ (It sorts **in-place**; no extra memory is needed).

### Python Implementation
```python
def insertion_sort(arr):
    # Traverse through 1 to len(arr)
    for i in range(1, len(arr)):
        key = arr[i]
        j = i - 1
        # Move elements of arr[0..i-1], that are
        # greater than key, to one position ahead
        # of their current position
        while j >= 0 and key < arr[j]:
            arr[j + 1] = arr[j]
            j -= 1
        arr[j + 1] = key
```
## 👍 Pros & 👎 Cons

- **👍 Pros:**
    
    - Simple to implement.
        
    - **Stable:** Does not change the relative order of elements with equal keys.
        
    - **In-Place:** Requires only a constant amount $O(1)$ of additional memory space.
        
- **👎 Cons:**
    
    - Inefficient for large lists compared to Quick Sort or Merge Sort ($O(n \log n)$).
        
    - Many writes/shifts to memory.
        

## See Also

- [[Bubble Sort]] (Another simple, $O(n^2)$ algorithm)
    
- [[Arrays]] (The underlying data structure)
