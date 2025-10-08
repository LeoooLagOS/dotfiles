---
tags:
  - concept
  - git
  - conventional-commits
category: git
status:
  - mastered
related: "[[Conventional Commits]]"
date: 2025-09-13
---

# chore: (Chore)

## 📝 One-Sentence Summary
The `chore` prefix is for routine maintenance and other tasks that don't modify source code or tests, such as updating build scripts or dependencies.
## 💡 Analogy
A `chore` is like cleaning and organizing the workshop. It doesn't change the product you're building, but it's a necessary task to keep the development process smooth, efficient, and tidy.

## 🔑 Key Details
- **What it is:** A change that doesn't affect the external user of your project. It's an internal maintenance task. 
- **Why it exists:** It separates essential but non-functional project maintenance from the history of features and fixes, keeping the log clean and focused.

## 🔗 Connections & Implementations
- This is a core type within the [[Conventional Commits]] specification. 
- Used in the `subject` line of a [[Git Commit]] message. 
- **Example:** `chore: Update .gitignore to exclude .tmp files`
## See Also
- [[build]] 
- [[docs]]
-