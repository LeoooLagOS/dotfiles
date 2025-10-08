---
tags: concept
category: <data-structure>
status:
  - learning
related: "[[STP]]"
date: 2025-09-23
---

# Spanning Tree (Graph Theory)

## 📝 One-Sentence Summary
A spanning tree is a subgraph of a connected, undirected graph that includes all the vertices of the original graph and is a tree (meaning it has no cycles).
## 💡 Analogy
Imagine a set of islands connected by multiple bridges (a graph with cycles). A **spanning tree** is the selection of bridges you would keep open to ensure you can travel from any island to any other island, but with no possible way to drive in a circle. There can be many different valid selections of bridges.
## 🔑 Key Details
- **What it is:** 
	- A subset of the edges of a graph that connects all the vertices together without forming any cycles. 
- **Why it exists:** 
	- It's the "skeletal" version of a graph. It provides a backbone of connectivity with the minimum number of necessary edges. 
- **Minimum Spanning Tree (MST):** 
	- A very common and important variation is the MST, where the edges have weights (like cost or distance), and the goal is to find the spanning tree with the lowest total weight. This is solved by classic algorithms like [[Prim's Algorithm]] and [[Kruskal's Algorithm]].

## 🔗 Connections & Implementations
- **Computer Networking:** The **[[STP]]** is a direct, practical application used to prevent loops in Ethernet networks. 
- **Other uses:** Found in circuit design, cluster analysis, and network flow problems.
