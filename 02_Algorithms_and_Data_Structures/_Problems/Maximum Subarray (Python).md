---
tags:
  - algorithm-pattern
  - problem
  - python
  - array
  - dynamic-programming
difficulty:
  - medium 
source: '"https://leetcode.com/problems/maximum-subarray/"'
status:
  - solved
related: "[[Kadane's Algorithm]]"
date: 2025-09-18
---

# Maximum Subarray (Python)

## 🧠 Problem Summary
*Given an array of integers, find the contiguous subarray with the largest possible sum and return that sum.
## 📋 Constraints & Edge Cases
- The subarray must contain at least one number. 
- A key edge case is an array containing all negative numbers. The answer in this case should be the single largest negative number, not 0.
## 💡 Key Data Structure / Concept
- The optimal solution is a classic application of: [[Kadane's Algorithm]]
## 📜 Algorithm Explained
1. Initialize `max_so_far` with the first element of the array to handle the all-negative-numbers case correctly. 
2. Initialize `current_max` to 0. 
3. Iterate through the numbers, applying the logic from [[Kadane's Algorithm]]: 
	- Add the current number to `current_max`. 
	- Update `max_so_far` if `current_max` is greater. 
	- Reset `current_max` to 0 if it ever becomes negative.
## 📊 Complexity Analysis
- **Optimal**: 
	- Time: [[Time Complexity|O(n)]] 
	- Space: [[Time Complexity|O(1)]]


## 💻 Code Implementation (`Python`)
```python
from typing import List

class Solution:
    def maxSubArray(self, nums: List[int]) -> int:
        # Initialize max_so_far with the first element to handle
        # cases where all numbers are negative.
        max_so_far = nums[0]
        current_max = 0

        for num in nums:
            current_max += num
            
            if current_max > max_so_far:
                max_so_far = current_max
            
            # The core of Kadane's algorithm: discard negative prefixes.
            if current_max < 0:
                current_max = 0
                
        return max_so_far
````

## 🔧 Code Breakdown

- `max_so_far = nums[0]`: This specific initialization is a crucial modification to the pure form of Kadane's Algorithm. It ensures that if all numbers are negative, the function correctly returns the largest of them (e.g., -1 from [-2, -1]).
    
- `if current_max < 0: current_max = 0`: This is the key step where we "forget" a negative prefix and start a new subarray from the next element.
    

## 🔗 See Also

- [[Maximum Product Subarray]]
    
- [[Dynamic Programming]]