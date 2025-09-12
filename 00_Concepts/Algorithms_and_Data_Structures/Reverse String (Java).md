---
tags:
  - algorithm-pattern
  - problem
  - java
  - string
  - two-pointer
difficulty:
  - easy 
source: '"https://leetcode.com/problems/reverse-string/"'
status:
  - solved
related: '"[[Two-Pointer Technique]]"'
date: 2025-09-11
---

# Reverse String (Java)

## ````
## 🧠 Problem Summary
Reverse an array of characters in-place, using constant O(1) extra memory.

## 📋 Constraints & Edge Cases
-   The core challenge is that Java `String` objects are **immutable**. To allow for in-place modification, the problem provides the input as a character array, `char[]`, which is **mutable**.

## 💡 Key Data Structure / Concept
-   The optimal solution uses the: [[Two-Pointer Technique]]

## 📜 Algorithm Explained
1.  **Initialize Pointers**: Create a `left` pointer at index 0 and a `right` pointer at the last index (`s.length - 1`).
2.  **Loop & Swap**: Use a `while` loop that continues as long as `left < right`.
3.  **Swap Logic**: Inside the loop, use a temporary `char` variable to swap the characters at the `left` and `right` positions.
4.  **Move Pointers**: Increment `left` and decrement `right` to move both pointers one step closer to the center.

## 📊 Complexity Analysis
-   **Optimal**:
    -   Time: [[Time Complexity|O(n)]]
    -   Space: [[Time Complexity|O(1)]]

## 💻 Code Implementation (`Java`)
```java
class Solution {
    public void reverseString(char[] s) {
        int left = 0;
        int right = s.length - 1;

        while (left < right) {
            // Classic three-step variable swap
            char temp = s[left];
            s[left] = s[right];
            s[right] = temp;

            // Move pointers towards the center
            left++;
            right--;
        }
    }
}
````

## 🔧 Code Breakdown

- `public void reverseString(char[] s)`: This is the method signature.
    
    - `void`: The `void` return type is crucial. It signifies that the method does not return any value. Instead, it modifies the input array `s` directly (in-place).
        
- `char temp = s[left];`: This begins the classic three-step swap. A temporary variable `temp` is created to hold the character from the left side, preventing it from being overwritten in the next step.
    

## 🔗 See Also

- [[Reverse String (Python)]]
    
- [[Valid Palindrome]]