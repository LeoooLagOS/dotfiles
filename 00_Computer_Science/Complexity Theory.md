---
tags:
  - concept
  - theory-of-computation
  - complexity
category: cs-fundamental
status:
  - learning
related: "[[Computability Theory]]"
date: 2025-11-14
---
# Complexity Theory

## 📝 One-Sentence Summary
Complexity Theory is the branch of computation theory that classifies **solvable** problems based on how much time (time complexity) and/or space (space complexity) they require to solve, relative to the size of their input.

## 💡 Analogy
If [[Computability Theory]] is the judge who rules if a case is "solvable" or "unsolvable," Complexity Theory is the **accountant** who, for all the solvable cases, provides a cost estimate. It tells you, "This problem is easy (like [[P]]) and will only cost $10," or "This problem is hard (like [[NP-Complete]]) and will cost $10 billion."

## 🔑 Key Details
-   **What it is:** 
	- The study of the *resources* needed to solve a problem. It's not about how long a specific program takes on a specific computer, but about the *inherent difficulty* of the problem itself.
-   **Why it exists:** 
	- To provide a formal way to compare the efficiency of different [[_Algorithms]] and to classify problems by their practical feasibility.
-   **Key Concepts:**
    -   [[Big O Notation]]: The language used to describe complexity (e.g., $O(n)$, $O(n^2)$, $O(\log n)$).
    -   **Complexity Classes:** Groups of problems of similar difficulty, such as [[P]] (solvable in polynomial time) and [[NP]] (verifiable in polynomial time).

## 🔗 Connections & Implementations
-   This is the direct theoretical foundation for [[Big O Notation]], which is used in `05_Algorithms_and_Data_Structures/` to analyze specific algorithms.
-   The most famous question in all of computer science, [[P vs NP]], is a problem in Complexity Theory.

## See Also
-   [[P vs NP]]
-   [[Big O Notation]]
-   [[Computability Theory]]
-   [[_Theory of Computation]]