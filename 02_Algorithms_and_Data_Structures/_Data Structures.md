---
tags:
  - overview
  - concept
  - dsa
  - cs-fundamental
category: <data-structure>
status: learning
related: "[[_Algorithms]]"
date: 2025-10-03
---
# _Data Structures_

## 📝 One-Sentence Summary
A data structure is a specialized format for organizing, processing, retrieving, and storing data in a computer's memory to be used efficiently.
## 💡 Analogy
Data structures are like different types of **storage containers and organization systems**. 
- An **[[Arrays|Array]]** is like a **pill organizer or an egg carton**: 
	- a fixed sequence of slots, perfect for quick access if you know the position. 
- A **[[Linked Lists|Linked List]]** is like a **scavenger hunt**: 
	- each item tells you where to find the next one, making it easy to add or remove items in the middle. 
- A **[[Hash Maps|Hash Map]]** is like a **coat check**: 
	- you give them your coat (a value) and get a unique ticket (a key). To get your coat back, you just present the ticket for instant retrieval.
## 📜 History & Creator
The foundational concepts of data structures evolved alongside the earliest computers. 
While many pioneers contributed, **Niklaus Wirth's** 1976 book, **"Algorithms + Data Structures = Programs,"** famously crystallized the idea that the way data is structured is inseparable from the algorithms that operate on it. This book established the modern understanding of data structures as a central pillar of computer science.
## 🔑 Core Philosophy & Design 
The core philosophy of data structures is that there is a fundamental **trade-off between different ways of storing data**. No single data structure is best for all tasks. The choice always depends on a series of questions: 
- **Access:** How quickly do I need to retrieve an element? 
- **Insertion/Deletion:** How often do I need to add or remove elements? 
- **Memory Usage:** How much memory does this structure consume? 
- **Ordering:** Does the data need to be kept in a specific order?
## ⚙️ Key Details 
- **What it is:** 
	- A specific way of organizing data in memory. 
- **Why it exists:** 
	- To enable efficient algorithms. The right data structure can make the difference between an algorithm that runs in seconds and one that takes years. 
- **Core Categories:** 
	- **Linear:** Data is arranged in a sequential manner (e.g., [[Arrays]], [[Linked Lists]], [[Stacks]], [[Queues]]).
	- **Non-Linear:** Data is arranged in a hierarchical or networked manner (e.g., [[Trees]], [[Graphs]]).

## 🔗 Connections & Implementations
- Data structures are the "nouns" of programming, while [[_Algorithms |Algorithms]] are the "verbs." 
- The choice of data structure directly impacts the [[Big O Notation|time and space complexity]] of an algorithm.

## See Also
- [[Abstract Data Type (ADT)]]