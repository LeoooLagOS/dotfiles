---
tags:
  - algorithm-pattern
  - problem
  - python
  - hash-map
  - array
difficulty:
  - easy 
source: '"https://leetcode.com/problems/two-sum/"'
status:
  - solved
related: "[[Hash Maps]]"
date: 2025-09-11
---

# Two Sum (Python)

## ````
# Two Sum (Python)

## 🧠 Problem Summary
Given an array of integers `nums` and an integer `target`, return the indices of the two numbers that add up to `target`.

## 📋 Constraints & Edge Cases
-   You may assume that each input would have **exactly one solution**.
-   You may not use the same element twice.
-   The array is not sorted.

## 💡 Key Data Structure / Concept
-   The optimal solution uses: [[Hash Maps]]

## 📜 Algorithm Explained
1.  **Brute-Force Idea**: Use two nested loops to check every pair of numbers. This is simple but slow, with a time complexity of O(n²).
2.  **Optimal Approach**: Iterate through the list once. For each number, calculate its `complement` (target - number). Use a hash map to instantly check if the complement has been seen before. If so, a solution is found. If not, add the current number and its index to the map.

## 📊 Complexity Analysis
-   **Optimal**:
    -   Time: [[Time Complexity|O(n)]]
    -   Space: [[Time Complexity|O(n)]]

## 💻 Code Implementation (`Python`)
```python
from typing import List

class Solution:
    def twoSum(self, nums: List[int], target: int) -> List[int]:
        seen = {}  # Dictionary (hash map) to store number -> index
        
        for i, num in enumerate(nums):
            complement = target - num
            if complement in seen:
                return [seen[complement], i]
            seen[num] = i
````

## 🔧 Code Breakdown

- `seen = {}`: Initializes an empty [[Python - Dictionaries|dictionary]], which is Python's implementation of a [[Hash Maps|hash map]].
    
- `if complement in seen:`: This is the core O(1) dictionary key lookup that makes the algorithm fast.
    

## 🔗 See Also

- [[Three Sum]]