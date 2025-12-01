---
tags:
  - concept
  - recursion
  - sorting
  - algorithm-pattern
category: data-structure
status: learning
related: "[[Big O Notation]]"
date: 2025-12-01
---
# Merge Sort
## 📝 One-Sentence Summary
An efficient, stable sorting algorithm that uses a "divide and conquer" strategy to recursively split a list into halves, sort them, and then merge them back together.

## 💡 Analogy
**Sorting two decks of cards:** Imagine you have two separate piles of cards that are already sorted. To combine them, you only need to look at the top card of each pile, pick the smaller one, and place it in a new pile. You repeat this until one pile is empty. Merge sort is just doing this process recursively.

## 🔑 Key Details
- **What it is:** 
	- A Divide and Conquer algorithm. It divides the input array into two halves, calls itself for the two halves, and then merges the two sorted halves.
- **Why it exists:** 
	- It guarantees $O(n \log n)$ performance regardless of the input order (unlike Quick Sort), making it highly predictable and suitable for large datasets.

## 🔗 Connections & Implementations
This connects deeply to **[[Recursion]]** and **Divide and Conquer** strategies.

### Complexity Analysis
- **Time Complexity:** $O(n \log n)$ in all cases (Best, Average, and Worst).
- **Space Complexity:** $O(n)$ (It requires auxiliary space to hold the temporary arrays during the merge step).

### Python Implementation
```python
def merge_sort(arr):
    if len(arr) > 1:
        mid = len(arr) // 2  # Finding the mid of the array
        L = arr[:mid]        # Dividing the array elements
        R = arr[mid:]        # into 2 halves

        merge_sort(L)        # Sorting the first half
        merge_sort(R)        # Sorting the second half

        i = j = k = 0

        # Copy data to temp arrays L[] and R[]
        while i < len(L) and j < len(R):
            if L[i] < R[j]:
                arr[k] = L[i]
                i += 1
            else:
                arr[k] = R[j]
                j += 1
            k += 1

        # Checking if any element was left
        while i < len(L):
            arr[k] = L[i]
            i += 1
            k += 1

        while j < len(R):
            arr[k] = R[j]
            j += 1
            k += 1
````

## 👍 Pros & 👎 Cons

- **👍 Pros:**
    
    - **Efficient:** Much faster than Bubble/Insertion sort for large lists.
        
    - **Stable:** Preserves the order of equal elements (crucial for complex data).
        
    - **Parallelizable:** The sub-problems are independent and can be solved in [[Parallelism|parallel]].
        
- **👎 Cons:**
    
    - **Space Inefficient:** Requires $O(n)$ extra space, unlike the $O(1)$ space of Insertion or Bubble sort.
        
    - Overkill for very small lists.
## See Also

- [[Insertion Sort]] (Better for very small lists)
    
- [[Recursion]] (The fundamental mechanism used here)
    
- [[Arrays]]