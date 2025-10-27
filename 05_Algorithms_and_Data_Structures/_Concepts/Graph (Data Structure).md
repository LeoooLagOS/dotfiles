---
tags:
  - concept
  - dsa
  - data-structure
  - graph-theory
category: <cs-fundamental>
status:
  - learning
related: "[[Trees]]"
date: 2025-09-23
---

# Graph (Data Structure)

## 📝 One-Sentence Summary
A graph is a non-linear [[_Data Structures|data structure ]]consisting of a set of vertices (or nodes) and a set of edges that connect pairs of these vertices, used to represent networks and relationships.
## 💡 Analogy
A graph is like a **map of cities and roads**. 
	- The **Vertices** (or nodes) are the cities. 
	- The **Edges** are the roads connecting the cities. 
	- A **Weighted Graph** would have the distance written on each road. 
	- A **Directed Graph** would have one-way streets.
## 🔑 Key Details
- **What it is:** A collection of `Vertices (V)` and `Edges (E)`. It's the most flexible data structure for modeling complex relationships. 
- **Why it exists:** 
	- To represent and solve problems involving networks, such as social networks (users and friendships), GPS navigation (locations and routes), and the internet itself (web pages and hyperlinks). 
- **Types of Graphs:** 
	- **Undirected vs. Directed:** Are connections two-way (Facebook friendship) or one-way (Twitter follow)? 
	- **Unweighted vs. Weighted:** Are connections simple (yes/no) or do they have a value (cost, distance, time)? 
	- **Cyclic vs. Acyclic:** Does the graph contain paths that start and end at the same vertex (a loop)?
## 🔗 Connections & Implementations
- **Representation in Code:** 
	- **Adjacency Matrix:** A 2D array where `matrix[i][j] = 1` if there's an edge between vertex `i` and `j`. Good for dense graphs. 
	- **Adjacency List:** An array where each index `i` stores a list of the vertices connected to vertex `i`. Good for sparse graphs.  
- *Related Data Structures:* 
	 - A [[Trees|Tree]] is a special kind of graph that is connected and acyclic (has no loops). 
	 - A [[Linked Lists|Linked List]] is a very simple type of tree. 
- **Common Algorithms:** This data structure is the basis for many famous algorithms, including: 
	- [[Breadth-First Search (BFS)]] 
	- [[Depth-First Search (DFS)]] 
	- [[Dijkstra's Algorithm]] 
	- A [[Spanning Tree (Graph Theory)|Spanning Tree]] is a subgraph of a graph.

## See Also
-   [[Trees]]
