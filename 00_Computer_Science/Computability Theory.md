---
tags:
  - concept
  - theory-of-computation
  - computability
category: cs-fundamental
status:
  - learning
related: "[[_Theory of Computation]]"
date: 2025-11-14
---
# Computability Theory

## 📝 One-Sentence Summary
Computability Theory is the branch of computation theory that classifies problems as either **solvable** (computable) or **unsolvable** (uncomputable) by any [[Turing Machine]], regardless of time or memory.

## 💡 Analogy
Computability Theory is like a **judge** ruling on a case. It's not concerned with how *long* the trial will take (that's [[Complexity Theory]]). It's only concerned with whether a definitive, correct verdict is **even possible** to reach, given the rules of logic. 

## 🔑 Key Details
-   **What it is:** 
	- The study of the fundamental limits of what can be solved with an algorithm.
-   **Why it exists:** 
	- To formally prove whether a problem is solvable at all. Its most famous discovery is that there are problems that are **uncomputable**.
-   **Core Concept:** 
	- A problem is **computable** (or "decidable") if a [[Turing Machine]] can be designed that will solve it and *halt* (stop) for every possible input. If no such machine can be built, the problem is **uncomputable** (or "undecidable").

## 🔗 Connections & Implementations
-   This field is the direct result of work by Alan Turing and Alonzo Church.
-   The most famous example of an uncomputable problem is [[The Halting Problem]].
-   This field separates all problems into two groups: those that can be solved (which [[Complexity Theory]] then analyzes) and those that cannot.

## See Also
-   [[_Theory of Computation]]
-   [[The Halting Problem]]
-   [[Complexity Theory]]