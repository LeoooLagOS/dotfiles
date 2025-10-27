---
tags:
  - concept
  - programming-paradigm
category: <cs-fundamental>
status:
  - learning
related: "[[Programming Paradigms]]"
date: 2025-10-03
---

# Functional Programming

## 📝 One-Sentence Summary
A programming paradigm that treats computation as the evaluation of mathematical functions and avoids changing-state and mutable data.
## 💡 Analogy
Functional programming is like a mathematical **equation** or an **assembly line in a factory**. Data flows in one end, passes through a series of specialized stations (pure functions) that each perform a single, predictable transformation, and a final product comes out the other end. No station has any "memory" of past items or any "side effects" on other stations.
## 🔑 Key Details
- **Core Ideas:** 
	- **Pure Functions:** A function's output depends *only* on its inputs, and it has no side effects (like modifying a global variable or printing to the console). 
- **Immutability:** 
	- Data is never changed. If you need to modify a data structure, you create a new one with the change. 
- **First-Class Functions:** 
	- Functions can be treated like any other variable—passed as arguments, returned from other functions, etc.
## 🔗 Connections & Implementations
- Many modern languages, including [[_Python]] and [[_Java]], have incorporated functional features (`map`, `filter`, lambda functions). 
- Heavily used in data processing, big data (e.g., Spark), and concurrent programming.