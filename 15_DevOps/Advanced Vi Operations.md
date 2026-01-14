---
tags:
  - devops
  - concept
  - linux
  - unix
category: devops
status: learning
related: "[[Vi Editor]]"
date: 2026-01-14
---
# Advanced Vi Operations

## 📝 One-Sentence Summary
Utilizing the internal buffer and global command syntax in `vi` to perform mass text edits and complex navigation.

## 💡 Analogy
**Surgical Precision:** If `nano` is a blunt kitchen knife, `vi` is a scalpel. You don't just "cut"; you specify exactly which "vessel" (line/word) to manipulate using coordinates like `ndd` or `nG`.

## 🔑 Key Details
- **What it is:** The use of the `Ex` mode (last line) for systemic changes across a file.
- **Why it exists:** To automate repetitive editing tasks within the terminal environment without manual scrolling.

## ⚙️ Core Functions/Components
- **Buffer Management:** Deleted characters/lines are held in a volatile buffer.
- **Search & Replace:**
	- `:g/text1/s/text2/g`: Global replacement.
	- `:g/text1/s//text2/gc`: Global replacement with confirmation.
- **Navigation Jumps:** `nG` moves the cursor to the specific line number `n`.

## 🔗 Connections & Implementations
- **SysAdmin:** Essential for modifying large config files like `dnf.conf` or `httpd.conf`.
- **Automation:** Foundational for shell scripting and `sed` logic.

## See Also
[[Vi Cheat Sheet]]
[[Managing SELinux]]