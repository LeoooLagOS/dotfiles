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
*Variables store data for reuse in scripts, while specific quoting mechanisms (`'` vs `"`) categorized by scope (Local vs. Environment) and type (String vs. Integer), while quoting protects that data from shell interpretation.*
## 🔑 Variable Types & Declaration 
Bash variables are strings by default. 
* **`declare -i VAR`**: Forces the variable to be treated as an **Integer**.
```bash 
declare -i n 
n=6/3 
echo $n # Output: 2 (Arithmetic is performed automatically) 
```

* **Indirect Reference:** Accessing the *value* of a variable whose *name* is in another variable. 
```bash 
REAL_VAL="Hello" 
REF="REAL_VAL" 
eval echo \$$REF # Output: Hello 
``` 
## 🌍 Scope: Where do they live? 
1. **Local Variables:** Visible **only** inside the function/block where defined. 
	* Syntax: `local VAR=value` 
2. **Global Variables:** Visible to the entire script (Default behavior). 
3. **Environment Variables:** Visible to **child processes** (programs started by the script). 
	* Syntax: `export VAR=value` 
	* View all: `env` or `printenv` 
## 🔢 Positional Parameters (Arguments)
Variables automatically set based on how the script was called (`./script.sh arg1 arg2`). 
* **`$0`**: Script name. 
* **`$1` - `$9`**: The arguments. (Use `${10}` for >9). 
* **`$#`**: Total **Number** of arguments. 
* **`$@`**: All arguments as a list (Best for iteration). 
* **`$*`**: All arguments as a single string.
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
- [[Bash String Manipulation]]
- [[Bash Parameter Expansion]]
- [[Environment Variables]]