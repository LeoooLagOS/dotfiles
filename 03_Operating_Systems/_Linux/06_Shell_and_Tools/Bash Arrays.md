---
tags:
  - concept
  - data-structure
  - linux
  - bash
  - syntax
category: os
status: learning
related: "[[Bash Variables and Quoting]]"
date: 2025-12-02
---
# Bash Arrays
## 📝 One-Sentence Summary
*Bash arrays are variables that store multiple values (lists) indexed by integers (0-based), allowing for iteration and batch processing.*
## 🔑 Syntax
* **Declaration:** `MY_ARRAY=(one two three)`
* **Explicit:** `declare -a MY_ARRAY`

## ⚙️ Accessing Data
| Action | Syntax | Example Result |
| :--- | :--- | :--- |
| **Get Element** | `${arr[i]}` | `${arr[0]}` -> `one` |
| **Get All** | `${arr[@]}` | `one two three` |
| **Get Count** | `${#arr[@]}` | `3` (Number of elements) |
| **Get Length** | `${#arr[0]}` | `3` (Length of string "one") |

## 🚀 Iterating (The Standard Loop)
```bash
SERVERS=("web01" "db01" "cache01")

for server in "${SERVERS[@]}"; do
    echo "Pinging $server..."
done
````

## See Also

- [[Bash Logic]] (For Loops)
    
- [[Bash Variables and Quoting]]