---
tags:
  - concept
  - git
  - conventional-commits
category: <git>
status:
  - <mastered>
related: "[[Conventional Commits]]"
date: 2025-09-13
---

# fix: (Bug Fix)

## 📝 One-Sentence Summary 
The `fix` prefix is used when a commit patches a bug in your codebase.

## 💡 Analogy
A `fix` is like a mechanic repairing a specific problem in a car's engine. It doesn't add new features (like a turbocharger), but it makes the existing features work as intended.
## 🔑 Key Details
- **What it is:** A commit type that corresponds to a "PATCH" semantic versioning bump (e.g., from `1.2.0` to `1.2.1`). 
- **Why it exists:** It clearly separates bug fixes from new features, which is critical for tracking issues, generating release notes, and understanding a project's stability.

## 🔗 Connections & Implementations
- This is a core type within the Conventional Commits specification. 
- Used in the `subject` line of a [[Git Commit]] message. 
- **Example:** `fix(api): Correct null pointer exception on user logout`
## See Also
-  [[feat]]
- 