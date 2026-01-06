---
tags:
  - concept
  - algorithm-pattern
  - sorting
category: data-structure
status: learning
related: "[[Big O Notation]]"
date: 2025-12-01
---
# Bubble Sort
## 📝 One-Sentence Summary
A basic sorting algorithm that repeatedly steps through the list, compares adjacent elements, and swaps them if they are in the wrong order, causing larger values to "bubble" to the top.

## 💡 Analogy
**Air bubbles in water:** Just as lighter air bubbles rise to the surface of a liquid, the largest (or smallest, depending on direction) elements in the array swap positions until they reach their correct spot at the end of the line.

## 🔑 Key Details
- **What it is:** 
	- A comparison-based sorting algorithm. It makes multiple passes through a list. In each pass, it compares adjacent items and swaps them if they are out of order.
- **Why it exists:** 
	- It is primarily an educational tool to introduce the concept of sorting algorithms and algorithmic thinking. It is rarely used in real-world production code due to inefficiency.

## 🔗 Connections & Implementations
This algorithm highlights the cost of frequent **swapping** operations in memory.

### Complexity Analysis
- **Time Complexity:**
    - Worst Case: $O(n^2)$ (Array is reverse sorted).
    - Best Case: $O(n)$ (Array is already sorted, requires an "optimized" version with a flag).
- **Space Complexity:** $O(1)$ (In-place sorting).

### Python Implementation
```python
def bubble_sort(arr):
    n = len(arr)
    # Traverse through all array elements
    for i in range(n):
        swapped = False
        # Last i elements are already in place
        for j in range(0, n-i-1):
            # Traverse the array from 0 to n-i-1
            # Swap if the element found is greater
            # than the next element
            if arr[j] > arr[j+1]:
                arr[j], arr[j+1] = arr[j+1], arr[j]
                swapped = True
        # If no two elements were swapped by inner loop, then break
        if not swapped:
            break
```
## 👍 Pros & 👎 Cons

- **👍 Pros:**
    
    - Extremely simple to understand and implement.
        
    - **In-Place:** Requires no extra memory.
        
- **👎 Cons:**
    
    - **Highly Inefficient:** $O(n^2)$ makes it impractical for large datasets.
        
    - Generally slower than Insertion Sort even though both are $O(n^2)$, because Bubble Sort performs more swaps.
        

## See Also

- [[Insertion Sort]] (Often preferred over Bubble Sort for small tasks)
    
- [[Arrays]]