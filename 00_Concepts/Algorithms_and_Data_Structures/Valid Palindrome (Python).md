---
tags:
  - algorithm-pattern
  - problem
  - python
  - string
  - two-pointer
difficulty:
  - easy 
source: '"https://leetcode.com/problems/valid-palindrome/"'
status:
  - solved
related: "[[Two-Pointer Technique]]"
date: 2025-09-16
---

# Valid Palindrome (Python)

## 🧠 Problem Summary
Given a string, determine if it is a palindrome, considering only alphanumeric characters and ignoring cases.

## 📋 Constraints & Edge Cases
-   The core challenge is **pre-processing the string**. You must first convert it to lowercase and remove all non-alphanumeric characters (punctuation, spaces, etc.).
-   An empty string is considered a valid palindrome.

## 💡 Key Data Structure / Concept
-   This problem can be solved with a simple string reversal or the more memory-efficient [[Two-Pointer Technique]].

---

##  Approach #1: Reverse and Compare
This is a clean, highly readable, and very "Pythonic" approach.

### 📜 Algorithm Explained
1.  **Clean the String**: Create a new string that contains only the alphanumeric characters from the input, all converted to lowercase.
2.  **Reverse and Compare**: Compare this new, cleaned string with its own reversed version (`cleaned_s[::-1]`). If they are identical, the original string is a palindrome.

### 📊 Complexity Analysis
-   **Time**: O(n), as we iterate through the string to clean it and then again to reverse it.
-   **Space**: O(n), because we create a new `cleaned_s` string whose size is proportional to the original.

### 💻 Code Implementation
```python
class Solution:
    def isPalindrome_reverse(self, s: str) -> bool:
        # 1. Clean the string using a list comprehension and join
        cleaned_s = "".join(char.lower() for char in s if char.isalnum())
        
        # 2. Compare the cleaned string with its reverse
        return cleaned_s == cleaned_s[::-1]
````

---

##  Approach #2: Two-Pointer Method

This approach is more memory-efficient as it avoids creating a second copy of the string.

### 📜 Algorithm Explained

1. **Initialize Pointers**: Set a `left` pointer at the start of the string (index 0) and a `right` pointer at the end.
    
2. **Move and Skip**: In a `while` loop (`left < right`), advance the `left` pointer if it's not on an alphanumeric character. Do the same for the `right` pointer.
    
3. **Compare**: Once both pointers are on alphanumeric characters, compare their lowercase versions. If they don't match, return `False`.
    
4. **Advance**: If they do match, move both pointers one step closer to the center (`left += 1`, `right -= 1`).
    
5. **Termination**: If the loop finishes, it means all characters matched, so return `True`.
    

### 📊 Complexity Analysis

- **Time**: O(n), as in the worst case, the pointers must scan every character.
    
- **Space**: O(1), as we only use a few variables for pointers, regardless of the input size.
    

### 💻 Code Implementation

Python

```
class Solution:
    def isPalindrome_two_pointers(self, s: str) -> bool:
        left, right = 0, len(s) - 1

        while left < right:
            if not s[left].isalnum():
                left += 1
                continue
            
            if not s[right].isalnum():
                right -= 1
                continue

            if s[left].lower() != s[right].lower():
                return False
            
            left += 1
            right -= 1
            
        return True
```

## 🔧 Code Breakdown

- `char.isalnum()`: A built-in string method that returns `True` if a character is a letter or a number.
    
- `cleaned_s[::-1]`: This is Python's **slice notation**. The `[::-1]` part is a common idiom that creates a reversed copy of a sequence.
    

## 🔗 See Also

- [[Reverse String (Python)]]
    
