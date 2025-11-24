---
tags:
  - cli
  - text-processing
  - linux
  - concept
category: os
status: learning
related: "[[Linux File System]]"
date: 2025-11-22
---
# File Viewing
## 📝 One-Sentence Summary
*A set of command-line utilities (`less`, `more`, `head`, `tail`) designed to inspect the contents of text files efficiently without opening a full text editor.*
## 💡 Analogy
* **`more`:** Like a **printed scroll**. You can unroll it to read further (scroll down), but you can't easily roll it back up to read what you missed.
* **`less`:** Like a **Kindle/E-book**. You can flip pages forward and backward, search for specific words, and jump to chapters instantly. ("Less is more").
* **`head`:** Reading just the **Headlines** of a newspaper (the top).
* **`tail`:** Reading just the **P.S.** at the end of a letter (the bottom).
## 🔑 Key Details
- **`more`:** The legacy pager.
    - *Limitation:* Can scroll down (Spacebar) but **cannot scroll up**.
- **`less`:** The standard modern pager.
    - *Feature:* Bidirectional scrolling.
    - *Search:*
        - `/pattern`: Search **forward**.
        - `?pattern`: Search **backward**.
        - `n`: Next occurrence.
        - `N`: Previous occurrence (reverse direction).
- **`head`:** Outputs the **first** 10 lines of a file.
    - `head -n 5 file.txt` (Show first 5 lines).
    - `head -n -5 file.txt` (Show all *except* the last 5 lines).
- **`tail`:** Outputs the **last** 10 lines of a file.
    - `tail -n 5 file.txt` (Show last 5 lines).
    - `tail -n +5 file.txt` (Show starting from line 5 to the end).
## 🔗 Connections & Implementations
* **Log Monitoring (`tail -f`):** The `-f` (follow) flag is crucial for sysadmins. It keeps the file open and prints new lines as they are added (e.g., `tail -f /var/log/syslog`).
* **Piping:** These are often used with pipes. Example: `ls -la | less` allows you to scroll through a long directory listing.
## See Also
- [[Linux File System]]
- [[Shell]]