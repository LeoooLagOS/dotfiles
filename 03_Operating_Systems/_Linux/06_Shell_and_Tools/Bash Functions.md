---
tags:
  - concept
  - linux
  - bash
  - modularity
  - function
category: os
status: learning
related: "[[Bash Control Flow]]"
date: 2025-12-02
---
# Bash Functions
## 📝 One-Sentence Summary
*Functions are reusable code blocks that act like mini-scripts within a script, capable of accepting arguments and returning exit codes.*
## 🔑 Syntax
```bash
function_name() {
    local var=$1
    echo "Processing $var"
    return 0
}
```
- **Definition:** Parentheses `()` define it. No `function` keyword needed (though supported).
    
- **Call:** Just type the name: `function_name arg1 arg2`.
## ⚙️ Arguments & Scope

- **Arguments:** Functions do **not** use the script's global arguments (`$1` of the script). They have their **own** local arguments.
    
    - Inside the function, `$1` is the first argument passed _to the function_.
        
- **Scope:** Variables are **Global** by default. Use `local` to restrict them to the function.
    
    - `local my_var="temp"`
        

## 🚪 Return Values

Bash functions **cannot return data** (like a string or int) directly to a variable like Python.

1. **Return Code (0-255):** Used for Success/Failure.
    
    - `return 1` (Failure). Check with `$?`.
        
2. **Echo (Data):** To "return" data, `echo` it and capture it with a subshell.
```bash
    get_name() { echo "Leona"; }
    NAME=$(get_name)
    ```
## See Also

- [[Bash Variables and Quoting]] (For $1, $2)
    
- [[Exit Codes]]