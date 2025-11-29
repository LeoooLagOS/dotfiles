---
tags:
  - concept
  - linux
  - bash
  - syntax
  - variables
category: os
status: learning
related: "[[Bash Script Structure]]"
date: 2025-11-28
---
# Bash Variables and Quoting
## 📝 One-Sentence Summary
*Variables store data for reuse in scripts, while specific quoting mechanisms (`'` vs `"`) determine whether the shell interprets special characters and variables inside strings.*
## 🔑 Variables
* **Assignment:** `VAR=value`
    * ⚠️ **Rule:** **No Spaces** around the `=`. `VAR = value` is an error (it tries to run a command named VAR).
* **Access:** `$VAR` or `${VAR}`.
    * *Best Practice:* Use `${VAR}` when concatenating text (e.g., `${VAR}_backup.tar`).

## 🛡️ Quoting Rules (Crucial)
| Quote Type | Symbol | Behavior | Example | Result |
| :--- | :--- | :--- | :--- | :--- |
| **Weak Quotes** | `"` | **Interpolates.** Variables (`$`) and subshells are expanded. | `echo "Hi $USER"` | `Hi leona` |
| **Strong Quotes** | `'` | **Literal.** Nothing is touched. What you see is what you get. | `echo 'Hi $USER'` | `Hi $USER` |
| **Subshell** | `$()` | **Execute.** Runs the command inside and returns output. | `$(date)` | `Fri Nov 29...` |
| **Arithmetic** | `$(( ))` | **Calculate.** Performs math. | `$((1 + 2))` | `3` |

## 🚀 Best Practice: "Quote Your Variables"
Always wrap variables in double quotes inside test conditions to prevent "Word Splitting" errors if the variable is empty or contains spaces.
* ❌ `if [ -z $VAR ];` (Fails if VAR is empty/spaces)
* ✅ `if [ -z "$VAR" ];` (Safe)

## See Also
- [[Shell Scripting]]
- [[Bash Logic]]