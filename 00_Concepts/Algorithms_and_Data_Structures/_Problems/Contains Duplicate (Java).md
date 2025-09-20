---
tags:
  - algorithm-pattern
  - problem
  - java
  - array
  - hash-set
difficulty:
  - easy 
source: '"https://leetcode.com/problems/contains-duplicate/'
status:
  - solved
related: "[[Hash Sets]]"
date: 2025-09-20
---

# Contains Duplicate (Java)

## 🧠 Problem Summary
Given an array of integers, determine if any value appears at least twice in the array.
## 📋 Constraints & Edge Cases
- The input array can be empty or have a single element, in which case no duplicates exist. 
- The values can be positive or negative.

## 💡 Key Data Structure / Concept
- The optimal solution uses a [[Hash Sets|HashSet]] for its efficient O(1) time complexity for checking membership. This is a practical application of the ideas behind [[Hash Maps]].
## 📜 Algorithm Explained

1. **Initialize a Set**: Create an empty `HashSet` to store the numbers we have encountered so far. 
2. **Iterate and Check**: Loop through each number in the input array. 
3. **Attempt to Add**: For each number, attempt to add it to the `HashSet`. The `add()` method in Java's `HashSet` has a special property: it returns `false` if the element already exists in the set. 
4. **Find Duplicate**: If the `add()` method returns `false`, we have found a duplicate and can immediately return `true`. 
5. **No Duplicates**: If the loop completes without the `add()` method ever returning `false`, it means all elements were unique, and we can return `false`.
## 📊 Complexity Analysis

-   **Optimal**:
    -   Time: [[Time Complexity|O(n)]], because we iterate through the `n` numbers once, and each `HashSet` operation is O(1).
    -   Space: [[Time Complexity|O(n)]], as in the worst case (all unique elements), the `HashSet` must store all `n` numbers.

## 💻 Code Implementation (`Java`)
```java
import java.util.HashSet;
import java.util.Set;

class Solution {
    public boolean containsDuplicate(int[] nums) {
        // A HashSet only allows unique elements and provides O(1) add/contains checks.
        Set<Integer> seen = new HashSet<>();
        
        for (int num : nums) {
            // The .add() method returns 'false' if the element is already present.
            if (!seen.add(num)) {
                return true; // Duplicate found.
            }
        }
        
        // If the loop completes, no duplicates were found.
        return false;
    }
}
````

## 🔧 Code Breakdown

- `import java.util.HashSet;`
	- Makes the `HashSet` class available. It's a best practice to also import `java.util.Set;` and declare the variable with the `Set` interface.
    
- `Set<Integer> seen = new HashSet<>();`
	- Creates our new, empty `HashSet` that will store objects of the `Integer` type.
    
- `if (!seen.add(num))`
	- This is the core of the solution's elegance. `seen.add(num)` attempts to add the number and returns a boolean. By checking for the `false` return value (`!`), we are directly asking, "Did the add operation fail due to a duplicate?"
    

## 🔗 See Also

- [[Hash Sets]]
    
- [[Hash Maps]]