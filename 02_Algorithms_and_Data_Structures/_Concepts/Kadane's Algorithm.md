---
tags:
  - concept
  - algorithm-pattern
  - dynamic-programming
  - dsa
category: <cs-fundamental>
status:
  - learning
related: "[[Dynamic Programming]]"
date: 2025-09-17
---

# Kadane's Algorithm

## 📝 One-Sentence Summary 
Kadane's [[_Algorithms|Algorithm]] is an efficient O(n) [[Dynamic Programming|dynamic programming]] approach to find the maximum sum of a contiguous subarray, elegantly solving the problem by discarding negative-sum prefixes. 
## 💡 Analogy 
Imagine walking a path where each step gives or takes points. You have two scoreboards: **`current_max`** (your score for the current continuous walk) and **`max_so_far`** (your all-time high score). 
1. At each step, you add the new points to `current_max`. 
2. You check if `current_max` has beaten `max_so_far`. If so, you have a new record. 
3. **The Key Insight:** If your `current_max` ever drops below 0, that path is a "losing path." You wisely reset `current_max` to 0 and start a fresh walk from the next step. 
## 🔑 Key Details 
- **What it is:** 
	- An iterative algorithm that maintains two key variables: the maximum sum ending at the current position (`current_max`), and the overall maximum sum found so far (`max_so_far`). 
- **Why it exists:** 
	- It provides a linear-time solution to the maximum subarray problem, which is a massive improvement over a naive O(n²) brute-force approach. The core logic is that a negative-sum prefix will never help maximize a future subarray. 

- ## 🔗 Connections & Implementations 
- Used to solve: [[Maximum Subarray (Python)]] 

## 👍 Pros & 👎 Cons 
- **Advantages:** 
	- Highly efficient: O(n) time complexity. 
	- Memory-perfect: O(1) space complexity. 
- **Disadvantages:** 
	- The basic version does not work if all numbers in the array are negative (it would return 0 instead of the largest negative number). This requires a small modification in implementation.