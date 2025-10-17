---
tags:
  - concept
  - java
  - data-structure
category: language
status:
  - reviewing
related: "[[Arrays]]"
date: 2025-10-16
---

# Strings in Java

## 📝 One-Sentence Summary
Java `String` is an object that represents an immutable sequence of characters, providing a rich set of built-in methods for manipulation and inspection.
## 💡 Analogy
A Java `String` is like a **message carved into a stone tablet**. Once the message is written, it is permanent and cannot be changed (it's **immutable**). If you want to "change" the message (e.g., capitalize a letter), you must get a brand new stone tablet and carve the entire new message onto it.

## 🔑 Key Details
- **What it is:** 
	- An object of the `java.lang.String` class. Unlike primitive types, it's a reference type. 
- **Immutability:** 
	- This is its most important characteristic. Any method that appears to modify a `String` (like `.toUpperCase()` or `.substring()`) actually returns a *new* `String` object with the modification, leaving the original unchanged. 
- **Why it exists:** 
	- To provide a safe, predictable, and robust way to work with text data. Immutability makes strings thread-safe and allows for optimizations like string pooling.
## 🔗 Connections & Implementations
- Under the hood, a `String` is backed by an array of characters (`char[]`). 
- Because they are immutable, strings can be safely used as keys in a [[Hash Maps|HashMap]].
## See Also
-   [[Arrays]]
