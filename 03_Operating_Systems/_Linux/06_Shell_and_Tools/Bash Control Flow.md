---
tags:
  - guide
  - linux
  - bash
  - logic
  - scripting
category: os
status: learning
related: "[[Bash Tests and Comparisons]]"
date: 2025-12-02
---
# Bash Control Flow (If, Case, Lists)
## 📝 One-Sentence Summary
*Control flow structures direct the execution path of a script based on the success (exit code 0) or failure of commands and tests.*
## 🔀 The `if` Construct
Tests **any** command, not just brackets.
```bash
if [ condition ]; then
    # Runs if true
elif [[ condition2 ]]; then
    # Runs if 2 is true
else
    # Default
fi
````

## 📋 List Constructs (One-Liners)

Chains commands together based on the previous command's success.

- **AND List (`&&`):** "Do A, and if it worked, do B."
    
    - `mkdir /tmp/test && cd /tmp/test`
        
    - Stops at the first **Failure**.
        
- **OR List (`||`):** "Do A, and if it FAILED, do B."
    
    - `[ -f config.conf ] || touch config.conf` (Ensure file exists).
        
    - Stops at the first **Success**.
        

## 📦 The `case` Statement

Cleanest way to handle multiple patterns (like CLI flags).

- **Terminator:** Each block ends with `;;`.
    
- **Closer:** Ends with `esac` (case backwards).
    
- **Wildcard:** `*)` catches anything not matched (Default).
    

**Example: Argument Parsing**
```bash
while [[ -n "$1" ]]; do 
	case "$1" in 
		-m|--message) 
			MESSAGE="$2" shift 2 ;; # Move past flag and value 
		-h) 
			help_function; exit 0 ;; 
		*) 
			echo "Unknown option: $1"; exit 1 ;; 
	esac 
done
```
## See Also

- [[Bash Tests and Comparisons]]
    
- [[Bash Variables and Quoting]] (For `shift` and `$@`)