---
tags:
  - tool
  - linux
  - text-processing
  - regex
category: os
status: learning
related: "[[Linux File Search]]"
date: 2025-11-22
---
# Grep (Global Regular Expression Print)
## 📝 One-Sentence Summary
*Grep is a command-line utility for searching plain-text data sets for lines that match a regular expression or string.*
## 💡 Analogy
*Think of **Grep** like the **"Ctrl+F"** function, but for thousands of files at once.*
## 🔑 Key Details
- **Syntax:** `grep [options] "pattern" [file/directory]`
- **Core Flag `-r` (Recursive):** Searches through all files in the specified directory and its subdirectories.
    - *Example:* `grep -r "fun" ~` (Finds every file in your home folder containing the word "fun").
- **Power:** It supports **Regular Expressions** (Regex), allowing you to search for patterns (e.g., "any line starting with 'Error' and ending with a number").
## 🔗 Connections & Implementations
* **Piping:** Often used to filter output from other commands.
    - `ps aux | grep firefox` (Check if Firefox is running).
    - `history | grep ssh` (Find past SSH commands).
## See Also
- [[Linux File Search]]
- [[Xargs]]