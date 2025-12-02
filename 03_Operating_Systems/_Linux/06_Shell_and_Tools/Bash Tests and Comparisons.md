---
tags:
  - concept
  - linux
  - bash
  - syntax
  - logic
category: os
status: learning
related: "[[Bash Script Structure]]"
date: 2025-12-02
---
# Bash Tests and Comparisons
## 📝 One-Sentence Summary
*Bash provides multiple mechanisms (`test`, `[ ]`, `[[ ]]`, `(( ))`) to evaluate expressions and return an exit code (0 for True, 1 for False) used by control flow statements.*
## 🔑 The Comparison Operators
### 1. `test` and `[ ]` (Single Bracket)
* **Status:** POSIX Standard (Compatible with `sh`).
* **Function:** `[` is actually a built-in command (synonym for `test`). It requires a closing `]`.
* **Behavior:** Strict. Variables containing spaces *must* be quoted, or syntax errors occur.
* **Example:** `[ -f file.txt ]` (Checks if file exists).

### 2. `[[ ]]` (Double Bracket)
* **Status:** Bash Extension (Not POSIX, but standard in DevOps).
* **Function:** A keyword (not a command).
* **Why it's better:**
    * **Safer:** Handles variables with spaces without crashing.
    * **Features:** Supports regex matching (`=~`) and logical operators (`&&`, `||`) *inside* the brackets.
* **Example:** `[[ -z $VAR && $VAR == "foo" ]]`

### 3. `(( ))` (Double Parentheses)
* **Status:** Arithmetic evaluation.
* **Function:** Evaluates math.
* **Truth Logic:** If the math result is **Non-Zero**, returns Status 0 (**True**). If result is **Zero**, returns Status 1 (**False**).
* **Example:** `(( 10 > 5 ))` returns True.

## ⚙️ Comparison Table
| Feature | `[ ]` | `[[ ]]` |
| :--- | :--- | :--- |
| **Logic (`&&`, `||`)** | No (Use `-a`, `-o`) | **Yes** |
| **Word Splitting** | **Vulnerable** | Safe |
| **Regex (`=~`)** | No | **Yes** |
| **Compatibility** | High (All shells) | Bash/Zsh only |

## 🚀 Examples in Context
**The "Spaces" Trap:**
```bash
file="my file.txt"

# Fails with "too many arguments" because it sees: [ -f my file.txt ]
if [ -f $file ]; then ...

# Works safely
if [[ -f $file ]]; then ...
```
## See Also

- [[Bash Control Flow]]
    
- [[Exit Codes]]