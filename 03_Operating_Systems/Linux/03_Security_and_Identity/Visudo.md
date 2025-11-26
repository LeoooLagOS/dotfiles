---
tags:
  - tool
  - sysadmin
  - security
  - sudo
category: os
status: learning
related: "[[Vim]]"
date: 2025-11-22
---
# Visudo
## 📝 One-Sentence Summary
*Visudo is a command-line utility that allows system administrators to edit the `/etc/sudoers` file safely by locking the file against simultaneous edits and validating the syntax before saving.*
## 💡 Analogy
*Think of **Visudo** as a **Spell-checker for Security**. If you try to save a document with a typo that would lock everyone out of the building (break sudo), Visudo stops you and says, "This syntax is wrong, fix it before I save."*
## 🔑 Key Details
- **What it does:** It opens the `/etc/sudoers` file (usually in [[Vim]] or [[nano]]).
- **Why use it:** Never edit `/etc/sudoers` directly with `vim`. If you make a syntax error, you can permanently break `sudo` access, locking yourself out of root privileges. `visudo` prevents this by checking the code upon exit.
## 🔗 Connections & Implementations
- **Command:** simply type `sudo visudo`.
- **Editor:** It uses the default editor set in the `$EDITOR` variable.
## See Also
- [[Vim]]
- [[Linux Permissions]]