---
tags:
  - string-manipulation
  - guide
  - linux
  - bash
  - syntax
category: os
status: learning
related: "[[Bash Variables and Quoting]]"
date: 2025-12-02
---
# Bash String Manipulation
## 📝 One-Sentence Summary
*Bash provides built-in syntax to manipulate string variables (length, substring, find/replace, delete) directly, avoiding the need for external tools like `sed` or `cut` for simple tasks.*
## 🔑 Key Operations
*Assume `VAR="abcABC123ABCabc"`*

| Operation | Syntax | Example | Result |
| :--- | :--- | :--- | :--- |
| **Length** | `${#var}` | `${#VAR}` | `15` |
| **Substring** | `${var:pos:len}` | `${VAR:2:5}` | `cABC1` (Start index 2, take 5) |
| **Replace First** | `${var/pattern/repl}` | `${VAR/abc/xyz}` | `xyzABC123ABCabc` |
| **Replace All** | `${var//pattern/repl}` | `${VAR//abc/xyz}` | `xyzABC123ABCxyz` |

## ✂️ Pattern Deletion (The `#` and `%` Rule)
* **`#`** matches the **Front** (Think: Hashtag goes before a number).
* **`%`** matches the **Back** (Think: Percent goes after a number).

| Syntax | Action | Example | Result |
| :--- | :--- | :--- | :--- |
| `${var#pattern}` | Delete **Shortest** match from **Front** | `${VAR#a*C}` | `123ABCabc` |
| `${var##pattern}` | Delete **Longest** match from **Front** | `${VAR##a*C}` | `abc` |
| `${var%pattern}` | Delete **Shortest** match from **Back** | `${VAR%b*c}` | `abcABC123ABCa` |
| `${var%%pattern}` | Delete **Longest** match from **Back** | `${VAR%%b*c}` | `a` |

## 🚀 Common Use Case: File Extensions
```bash
FILE="image.png"
NAME=${FILE%.*}   # Delete extension -> "image"
EXT=${FILE##*.}   # Delete name -> "png"
```
## See Also

- [[Bash Variables and Quoting]]
    
- [[Sed]]