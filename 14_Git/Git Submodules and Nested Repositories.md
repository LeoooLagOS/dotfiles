---
tags:
  - git
  - version-control
  - workflow
category: cs-fundamental
status:
  - reference
related: "[[_Git]]"
date: 2025-11-27
---
# Git Submodules and Nested Repositories

## 📝 One-Sentence Summary

A technique for managing a Git repository inside another Git repository, allowing the "child" project to remain independent while the "parent" project tracks a specific reference to it.

## 💡 Analogy

Think of a **Library (Parent Repo)** and a **Book (Child Repo)**.

- The book exists independently; the author can change the text and publish a new edition (Child Repo updates).
    
- The library doesn't "own" the text of the book; it just owns a catalog card (Pointer) that says "We have Edition 2 of this book on shelf X".
    
- If the author releases Edition 3, the library must manually update its catalog card to point to the new version.
    

## 🔑 Common Commands

### Adding a Submodule
```bASH
git submodule add <url> <path>
```

### Removing a Submodule (Cleanly)

If you just delete the folder, Git gets confused. You must remove it from the index.
```BASH
git rm -r --cached <folder_name>
rm -rf <folder_name>
```

### Updating the Parent Reference

When the child repo changes, the parent sees it as "modified content".
```BASH
# In Parent Repo
git add <child_folder>
git commit -m "chore: update submodule reference"
```

## ⚠️ Gotchas

- **Nested `.git`:** If you simply run `git init` inside a subfolder without configuring submodules, the parent repo will track it as a "grayed out" folder and won't track its files.
    
- **Force Push:** If you accidentally commit the wrong history to the child, use `git push -u -f origin main` to overwrite the remote cleanly.
    

## See Also

- [[_Git]]
    
- [[_Software Engineering]]