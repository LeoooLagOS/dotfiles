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
# NP (Complexity Class)

## 📝 One-Sentence Summary
**NP** (Nondeterministic Polynomial-time) is the complexity class containing all decision problems for which a "yes" answer can be **verified** efficiently (in polynomial time).

## 💡 Analogy
`NP` represents problems that are **"easy to check"**. Think of a complex **Sudoku puzzle**. Solving it from scratch can be incredibly hard. But if someone hands you a *completed* puzzle, you can verify if it's a correct solution very quickly (in polynomial time).

## 🔑 Key Details
-   **What it is:** 
	- The set of problems where a proposed solution can be checked for correctness efficiently.
-   **Why it exists:** 
	- It captures a vast set of important, hard problems (like the Traveling Salesman Problem) that we don't *think* we can solve efficiently, but for which we can at least recognize a correct answer when we see one.
-   **Misconception:** 
	- `NP` does **not** stand for "Non-Polynomial." It stands for "Nondeterministic Polynomial," which is a formal way of saying "verifiable in polynomial time."

## 🔗 Connections & Implementations
-   All problems in [[P]] are also in `NP` (if a problem is easy to solve, it's also easy to check).
-   This is the "NP" in the [[P vs NP]] problem.
-   This class contains the hardest problems known as [[NP-Complete]].

## See Also
-   [[P]]
-   [[P vs NP]]
-   [[NP-Complete]]
-   [[Complexity Theory]]