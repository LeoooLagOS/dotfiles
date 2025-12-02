---
tags:
  - concept
  - theory-of-computation
  - automata
category: cs-fundamental
status:
  - learning
related: "[[_Theory of Computation]]"
date: 2025-11-14
---

# Finite Automata (FA)

## 📝 One-Sentence Summary
A Finite Automaton (or Finite State Machine) is the simplest abstract model of computation, characterized by a finite number of states and no memory, used to recognize "regular languages."

## 💡 Analogy
A Finite Automaton is like a **turnstile**. 
-   It has a **finite number of states** (e.g., `Locked` and `Unlocked`).
-   It has a set of **inputs** (e.g., `Push` and `Insert Coin`).
-   If you are in the `Locked` state and you `Push`, you stay in the `Locked` state.
-   If you are in the `Locked` state and you `Insert Coin`, you transition to the `Unlocked` state.
It has no memory; it only knows its current state.

## 🔑 Key Details
-   **What it is:** 
	- A mathematical model of a machine that can be in one of a finite number of states at any given time. It changes states in response to a sequence of inputs.
-   **Why it exists:** 
	- To model simple computational problems and recognize **regular languages** (the simplest class of formal languages).
-   **Key Limitation:** 
	- Its "finiteness." It has no memory or stack, so it cannot solve problems that require remembering an arbitrary amount of information (e.g., it cannot check if parentheses in an expression are balanced).

## 🔗 Connections & Implementations
-   This is the first and simplest model studied in [[_Theory of Computation]].
-   **Practical Use:** 
	- The logic of Finite Automata is used in **Regular Expressions (Regex)**, network protocol parsers, and simple hardware controllers (like traffic lights or vending machines).
-   It is less powerful than a [[Turing Machine]], which has infinite memory.

## 👍 Pros & 👎 Cons
-   **✅ Pros:** 
	- Very simple, fast, and efficient to implement.
-   **❌ Cons:** 
	- Strictly limited in power; cannot solve any problem that requires counting or memory.

## See Also
-   [[Regular Language]]
-   [[Turing Machine]]