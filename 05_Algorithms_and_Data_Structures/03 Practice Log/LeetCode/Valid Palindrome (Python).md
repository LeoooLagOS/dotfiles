---
tags:
  - algorithm-pattern
  - problem
  - python
  - string
  - two-pointer
difficulty:
  - easy 
source: https://leetcode.com/problems/valid-palindrome/
status:
  - solved
  - re-solved
related: "[[Two-Pointer Technique]]"
date: 2025-09-16
---

# Valid Palindrome (Python)

## 🧠 Problem Summary
Given a string, determine if it is a palindrome, considering only alphanumeric characters and ignoring cases.

## 📋 Constraints & Edge Cases
-   The core challenge is **pre-processing the string**. You must first convert it to lowercase and remove all non-alphanumeric characters (punctuation, spaces, etc.).
- **Empty String:** An empty string is considered a valid palindrome. 
- **Garbage Characters:** Must skip spaces, commas, colons, etc. 
- **Case Sensitivity:** 'A' equals 'a'. 

## 💡 Key Data Structure / Concept
- The optimal solution uses: **[[Two Pointer Technique]]**. 
- **Why:** Creating a reversed string copy takes $O(N)$ extra memory. Pointers solve it in place with $O(1)$ memory.

## 📜 Algorithm Explained 
1. Initialize **Left (L)** at 0 and **Right (R)** at the last index. 
2. Loop while `L < R`. 
3. Inside the loop: 
	- If `s[L]` is not alphanumeric, `L += 1`. 
	- If `s[R]` is not alphanumeric, `R -= 1`. 
	- If both are alphanumeric, check `s[L].lower() == s[R].lower()`. 
	- If they don't match, return `False`. 
	- If they match, move both pointers inward (`L+=1`, `R-=1`). 
4. Return `True`. 
## 📊 Complexity Analysis 
- **Optimal**: 
	- Time: [[Time Complexity|O(N)]] (We visit every character at most once). 
	- Space: [[Time complexity|O(1)]] (No extra strings or arrays created).
---

##  Approach #1: 
## 💻 Code Implementation (Python)
```python
class Solution:
    def isPalindrome(self, s: str) -> bool:
        L, R = 0, len(s) - 1
        
        while L < R:
            # Skip garbage on left
            if not s[L].isalnum():
                L += 1
                continue
            # Skip garbage on right
            if not s[R].isalnum():
                R -= 1
                continue
            
            # Compare
            if s[L].lower() != s[R].lower():
                return False
            
            # Close the window
            L += 1
            R -= 1
            
        return True
````

### 🔧 Code Breakdown

- `isalnum()`: Python method that checks if a char is A-Z, a-z, or 0-9. Essential for cleaning data without using regex.
    
- `lower()`: Normalizes the case for comparison.
    
- `continue`: Skips the rest of the loop logic to restart the cycle (useful for skipping multiple spaces in a row).
    

### 🔗 See Also

- [[Two Sum II]] (Another classic Two Pointer problem)
    
- [[Reverse String]] (Basic pointer manipulation)