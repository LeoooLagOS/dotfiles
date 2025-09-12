---
tags:
  - concept
category: <data-structure|cs-fundamental|devops|git>
status: <learning|reviewing|mastered>
related: "[[git add]]"
date: 2025-09-11
---

# Git Commit

## ````
## 📝 One-Sentence Summary
The `git commit` command captures a snapshot of the project's currently staged changes and saves it as a permanent entry in the local repository's history.

## 💡 Analogy
A `git commit` is like making an official entry in a ship's logbook. Each entry is a permanent, time-stamped record of a specific set of actions, complete with a message explaining what happened and why. The collection of these entries forms the complete history of the voyage. 

## 🔑 Key Details
-   **What it is:** The fundamental "save" command in Git. It creates a commit object containing a pointer to the snapshot of content, metadata (author, date), and a message.
-   **Why it exists:** It creates a clear, chronological history of the project. Each commit is a safe point you can return to, review, or compare changes against.

---

## ## The Art of the Commit Message ✍️
A clear and professional commit message is a critical skill. The standard practice is to follow the **Conventional Commits** specification.

### Structure: `type(scope): subject`
-   **`type`**: What kind of change is this?
    -   `feat`: A new feature.
    -   `fix`: A bug fix.
    -   `docs`: Changes to documentation only.
    -   `style`: Formatting changes (spaces, semicolons, etc).
    -   `refactor`: A code change that neither fixes a bug nor adds a feature.
    -   `test`: Adding or correcting tests.
    -   `build`: Changes that affect the build system or external dependencies.
    -   `chore`: Other changes that don't modify source or test files (e.g., updating the `.gitignore`).
-   **`(scope)`**: (Optional) What part of the codebase does this change affect? (e.g., `(api)`, `(ui)`)
-   **`subject`**: A short, descriptive summary of the change, written in the present tense (imperative mood).

**Example:** `feat(auth): Add password reset functionality`

---

## ## Common Usage & Flags
### Basic Commit
This is the most common usage. The `-m` flag allows you to write a short, one-line message directly.
```bash
git commit -m "feat: Add user login page"
````

### The Professional Commit (for longer messages)

Running `git commit` without `-m` opens your configured text editor (like Vim or VS Code) to write a more detailed message with a subject and a body.

Bash

```
git commit
```

This is where you can explain the "why" behind your change in more detail, following standard formatting rules (subject line max 50 chars, body wrapped at 72 chars).

### Useful Flags

- `-a` or `--all`: Automatically stages every tracked, modified file before committing. A convenient shortcut, but use with caution. It's often better to stage files explicitly with `[[git add]]`.
    
- `--amend`: A power-user feature. This modifies your **most recent commit**. It's perfect for fixing a typo in the last commit message or adding a file you forgot.
    

## 🔗 See Also

- [[Git]]
    
- [[Staging Area]]
    
- [[git log]]