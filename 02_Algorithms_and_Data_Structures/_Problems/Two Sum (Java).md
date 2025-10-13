---
tags:
  - algorithm-pattern
  - problem
  - java
  - hash-map
  - array
difficulty:
  - easy 
source: https://leetcode.com/problems/two-sum/
status:
  - solved
related: "[[Hash Maps]]"
date: 2025-09-16
---

# Two Sum (Java)

## 🧠 Problem Summary
Given an array of integers `nums` and an integer `target`, return the indices of the two numbers that add up to `target`.

## 📋 Constraints & Edge Cases
-   You may assume that each input would have **exactly one solution**.
-   You may not use the same element twice.
-   The problem guarantees a solution exists, but robust code should handle the "no solution" case.

## 💡 Key Data Structure / Concept
-   The optimal solution uses: [[Hash Maps]]

## 📜 Algorithm Explained
1.  **Brute-Force Idea**: Use two nested loops to check every pair of numbers. This is simple but slow (O(n²)).
2.  **Optimal Approach**: Iterate through the array once. For each number, calculate its `complement` (target - number). Use a `HashMap` to instantly check if the complement has been seen before. If yes, return the indices. If not, add the current number and its index to the map.

## 📊 Complexity Analysis
-   **Optimal**:
    -   Time: [[Time Complexity|O(n)]]
    -   Space: [[Time Complexity|O(n)]]

## 💻 Code Implementation (`Java`)
```java
import java.util.HashMap;
import java.util.Map;

class Solution {
    public int[] twoSum(int[] nums, int target) {
        // Use the Map interface for good practice, with HashMap as the implementation.
        Map<Integer, Integer> seen = new HashMap<>();

        for (int i = 0; i < nums.length; i++) {
            int complement = target - nums[i];

            // The core of the algorithm: a fast O(1) lookup.
            if (seen.containsKey(complement)) {
                // If found, return the stored index and the current index.
                return new int[] { seen.get(complement), i };
            }

            // If not found, add the current number and its index to the map.
            seen.put(nums[i], i);
        }

        // This path is taken only if no solution exists.
        throw new IllegalArgumentException("No two sum solution");
    }
}
````

## 🔧 Code Breakdown

- `import java.util.HashMap;`: Makes the `HashMap` class from Java's utility library available.
    
- `public int[] twoSum(...)`: The method signature. It takes an `int[]` and an `int`, and returns an `int[]`.
    
- `Map<Integer, Integer> seen = new HashMap<>();`: Creates our hash map. We declare with the `Map` interface and specify that both keys and values are `Integer` types.
    
- `seen.containsKey(complement)`: The core O(1) lookup operation to check if a key exists.
    
- `seen.get(complement)`: Retrieves the value (the index) for a given key.
    
- `seen.put(nums[i], i)`: Adds a new key-value pair to the map.
    

## 🔗 See Also

- [[Two Sum (Python)]]
    
- [[Hash Maps]]