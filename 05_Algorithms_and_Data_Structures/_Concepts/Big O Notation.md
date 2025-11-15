---
tags:
  - concept
  - dsa
  - complexity
  - algorithm-pattern
category: cs-fundamental
status:
  - learning
related: "[[Complexity Theory]]"
date: 2025-11-14
---
# Big O Notation

## 📝 One-Sentence Summary
Big O notation is a mathematical language used to describe the **upper bound** (worst-case scenario) of an algorithm's time or space complexity, relative to the size of the input.

## 💡 Analogy
Big O is like a **shipping company's delivery promise**.
-   **$O(1)$ (Constant):** "We'll deliver this one special box in 1 day, guaranteed." The size of the box doesn't matter. (e.g., accessing an array element by index).
-   **$O(\log n)$ (Logarithmic):** "We'll deliver this package by looking up the zip code in our giant directory." Each time we check, we cut the search area in half. (e.g., [[Binary Search]]).
-   **$O(n)$ (Linear):** "We have to deliver a package to every house on this street." The time is directly proportional to the number of houses. (e.g., searching an unsorted list).
-   **$O(n^2)$ (Quadratic):** "We have to deliver a package from every house on the street to every *other* house on the same street." (e.g., a simple [[Bubble Sort]]).

## 🔑 Key Details
-   **What it is:** 
	- An "asymptotic" notation that describes how the runtime or memory usage of an algorithm *grows* as the input size (`n`) approaches infinity.
-   **Why it exists:** 
	- To provide a standardized, hardware-independent way to compare the **scalability** of different algorithms.
-   **Focus on the Worst-Case:** 
	- Big O typically describes the worst-case scenario, as this provides a guaranteed upper limit on performance.

## 🔗 Connections & Implementations
-   This is the practical language used to apply [[Complexity Theory]] to real-world [[_Algorithms]].
-   It's used to analyze the efficiency of operations on [[_Data Structures]]. For example, [[Hash Maps]] have an average $O(1)$ lookup time.

## 👍 Pros & 👎 Cons
-   **✅ Pros:** 
	- Universal standard, great for comparing scalability, hardware-independent.
-   **❌ Cons:** 
	- It ignores constants (an algorithm that takes $2n$ time and one that takes $1000n$ time are both $O(n)$). It's not a direct measure of "speed," but of "growth rate."

## See Also
-   [[Complexity Theory]]
-   [[_Algorithms]]