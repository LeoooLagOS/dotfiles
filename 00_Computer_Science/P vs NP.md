---
tags:
  - concept
  - theory-of-computation
  - complexity
  - unsolved-problem
category: cs-fundamental
status:
  - learning
related: "[[Complexity Theory]]"
date: 2025-11-14
---
# P vs. NP Problem

## 📝 One-Sentence Summary
The `P vs. NP` problem is the single biggest unsolved question in computer science: Is every problem whose solution can be **verified** quickly (`NP`) also **solvable** quickly (`P`)?

## 💡 Analogy
This problem asks: "Is **solving a Sudoku puzzle** (which seems hard, `NP`) fundamentally as easy as **verifying a completed one** (which is easy, `P`)?" Everyone *thinks* solving is harder, but nobody has ever been able to mathematically prove it.

## 🔑 Key Details
-   **What it is:** 
	- A $1 million Millennium Prize Problem. The question is, does **`P = NP`**?
-   **Why it exists:** 
	- The answer would have profound consequences.
    -   **If `P = NP`:** Modern cryptography would be broken. We could efficiently find optimal solutions to thousands of "hard" problems in logistics, biology, and finance.
    -   **If `P ≠ NP`:** (This is what almost all scientists believe) It confirms that there is a class of problems that are fundamentally "hard" to solve, and we must rely on approximation algorithms.

## 🔗 Connections & Implementations
-   This is the central, organizing problem of [[Complexity Theory]].
-   The solution hinges on the nature of [[NP-Complete]] problems. If a fast (polynomial time) solution is *ever* found for even *one* `NP-Complete` problem, it would prove that `P = NP`.

## See Also
-   [[P]]
-   [[NP]]
-   [[NP-Complete]]
-   [[Complexity Theory]]