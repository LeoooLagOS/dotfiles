---
tags:
  - problem
  - python
  - string
  - two-pointer
  - algorithm-pattern
difficulty:
  - easy 
source: '"https://leetcode.com/problems/reverse-string/"'
status:
  - solved
related:
date: 2025-09-10
---
[[]]
# Reverse String (Python)

## 🧠 Problem Summary
*Reverse a list of characters in-place, using constant O(1) extra memory.*

## 📋 Constraints & Edge Cases
- The core challenge is that Python `str` objects are **immutable**. The problem works around this by providing the input as a `List[str]`, which is **mutable**.

## 💡 Key Data Structure / Concept
-- The optimal solution uses the: [[Two-Pointer Technique]]

## 📜 Algorithm Explained
1. **Initialize Pointers**: Create a `left` pointer at index 0 and a `right` pointer at the last index (`len(s) - 1`). 
2. **Loop & Swap**: Use a `while` loop to continue as long as `left < right`, swapping the characters at the `left` and `right` positions in each iteration. 
3. **Move Pointers**: Increment `left` and decrement `right` to move both pointers closer to the center.

## 📊 Complexity Analysis
-- **Optimal**: 
	- Time: [[Time Complexity|O(n)]] 
	- Space: [[Time Complexity|O(1)]]

## 💻 Code Implementation (`<Python3>`)
```python 
from typing import List 
class Solution: 
def reverseString(self, s: List[str]) -> None: 
	left, right = 0, len(s) - 1 
	while left < right: 
	s[left], s[right] = s[right], s[left] 
	left += 1 
	right -= 1
```

## 🔧 Code Breakdown

- `some_function()`: Explain the purpose of this line and link to a concept, e.g., 
	- see [[Python - Loops and Iteration]].
    
- `data_structure = {}`: Explain the initialization, e.g., 
	- This is our [[Hash Maps|hash map]].
    

## 🔗 See Also

- [[Valid Palindrome]]
- 