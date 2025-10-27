---
tags:
  - concept
  - conventional-commits
category: <git>
status:
  - <mastered>
related: "[[Conventional Commits]]"
date: 2025-09-11
---

# ```
# feat: (Feature)

## 📝 One-Sentence Summary
The `feat` prefix is used when a commit introduces a new feature or capability to the codebase or project.

## 🔑 Key Details
-   **What it is:** A commit type that corresponds to a "minor" semantic versioning bump (e.g., from `1.1.0` to `1.2.0`). It signifies the addition of new, user-facing functionality.
-   **Why it exists:** It allows for the automatic generation of changelogs and makes it easy to identify commits that added new features versus those that just fixed bugs or updated documentation.

## 🔗 Connections & Implementations
-   This is a core type within the [[Conventional Commits]] specification.
-   Used in the `subject` line of a [[Git Commit]] message.
-   **Example:** `feat(auth): Add password reset functionality`

## See Also
-   `[[fix]]`
-   `[[refactor]]`
```