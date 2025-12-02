---
tags:
  - concept
  - linux
  - bash
  - syntax
  - error-handling
category: os
status: learning
related: "[[Bash Variables and Quoting]]"
date: 2025-12-02
---
# Bash Parameter Expansion
## 📝 One-Sentence Summary
*Parameter expansion allows you to define default values, assign values if missing, or throw errors if a variable is unset, making scripts more robust against missing input.*
## 🔑 The Syntax Logic
* **`:` (Colon):** Means "Check if variable is set AND not null (empty)". If you omit the colon, it only checks if it is unset.
* **`-` (Minus):** Use Default.
* **`=` (Equals):** Set Default.
* **`?` (Question):** Error if missing.
* **`+` (Plus):** Alternate value.

## ⚙️ Cheat Sheet
| Syntax | Meaning | Description |
| :--- | :--- | :--- |
| `${VAR:-default}` | **Use Default** | If `VAR` is empty, return "default". (VAR remains empty). |
| `${VAR:=default}` | **Set Default** | If `VAR` is empty, set `VAR="default"`. |
| `${VAR:?error}` | **Require** | If `VAR` is empty, **Stop Script** and print "error". |
| `${VAR:+alt}` | **Alternate** | If `VAR` is **SET**, return "alt". If empty, return nothing. |

## 🚀 Examples in Context
**1. Providing a Default Value (CLI Arguments)**
```bash
FILENAME=${1:-"data.txt"}
# If user provides an argument, use it. If not, use "data.txt".
````

**2. Protecting Critical Variables**
```Bash
: ${HOME:?} ${USER:?} # If $HOME or $USER are unset, crash the script immediately to prevent damage.
```
## See Also

- [[Bash Variables and Quoting]]
    
- [[Exit Codes]]
