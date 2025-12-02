---
tags:
  - concept
  - theory-of-computation
  - complexity
category: cs-fundamental
status:
  - learning
related: "[[Complexity Theory]]"
date: 2025-11-14
---
# P (Complexity Class)

## 📝 One-Sentence Summary
**P** is the complexity class containing all decision problems that can be **solved** efficiently (in polynomial time) by a deterministic [[Turing Machine]].

## 💡 Analogy
`P` represents problems that are **"easy to solve"**. Think of **sorting a deck of cards**. The more cards (`n`) you have, the longer it takes, but the time required is manageable and grows at a predictable, polynomial rate (e.g., $O(n \log n)$ or $O(n^2)$).

## 🔑 Key Details
-   **What it is:** 
	- The set of problems that are "practically solvable." The "P" stands for **Polynomial time**, meaning the time to solve the problem is $O(n^k)$ for some constant `k`.
-   **Why it exists:** 
	- To formally define what we mean by an "efficient" or "fast" algorithm. Problems in `P` are considered computationally feasible.

## 🔗 Connections & Implementations
-   This is the "P" in the [[P vs NP]] problem.
-   Most everyday algorithms you study, such as sorting, searching a sorted list ([[Binary Search]]), or finding a path in a graph ([[Dijkstra's Algorithm]]), fall into this class.

## See Also
-   [[NP]]
-   [[P vs NP]]
-   [[Complexity Theory]]