---
tags:
  - concept
  - data-structure
  - dsa
category: <data-structure>
status:
  - learning
related: "[[Hash Maps]]"
date: 2025-09-19
---

# Hash Sets

## 📝 One-Sentence Summary
A Hash Set is a data structure that stores a collection of unique items, providing extremely fast (average O(1)) checks for membership, insertion, and deletion.
## 💡 Analogy
A Hash Set is like a **guest list for an exclusive party**. When a new guest arrives, the bouncer (the HashSet) can instantly check their name against the list. If they're already on it, they're not added again. The key is the speed of the lookup—the bouncer doesn't need to read the whole list every time.

## 🔑 Key Details
- **What it is:** 
	- An unordered collection of items where every item must be unique. It's essentially a [[Hash Maps|Hash Map]] where we only care about the keys, not the values. 
- **Why it exists:** 
	- It is the most efficient data structure for solving problems related to uniqueness, such as removing duplicates from a list or checking if an item has been seen before.
## 🔗 Connections & Implementations
- Implemented in [[_Java|Java]] as the `HashSet` class. 
- Implemented in [[_Python|Python]] as the `set` object. 
- Used to solve: [[Contains Duplicate (Java)]]
## 👍 Pros & 👎 Cons
- **Advantages:** 
	- Blazing fast O(1) average time complexity for `add`, `remove`, and `contains` operations. 
- **Disadvantages:** 
	- Uses O(n) space to store the elements. - Does not maintain the insertion order of elements.
## See Also
- [[Hash Maps]] 
- [[Arrays]] 