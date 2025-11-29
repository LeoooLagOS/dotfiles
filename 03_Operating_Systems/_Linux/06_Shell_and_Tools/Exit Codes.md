---
tags:
  - concept
  - linux
  - bash
  - logic
  - error-handling
category: os
status: learning
related: "[[Shell Options]]"
date: 2025-11-28
---
# Exit Codes
## 📝 One-Sentence Summary
*Every Linux command returns a numeric exit code (0-255) upon completion to indicate its status, where `0` means success and anything else indicates failure.*
## 🔑 Key Details
- **Success:** `0` (Zero errors).
- **Failure:** `1-255` (Specific error codes).
    * `1`: General error.
    * `127`: Command not found.
    * `130`: Terminated by Ctrl+C.
- **Checking the Code:** The special variable **`$?`** holds the exit code of the *last* executed command.

## ⚙️ Usage in Scripting
You rarely check `echo $?` manually in scripts. Instead, you use `if` statements or logical operators which implicitly check if the exit code is `0`.
```bash
# If 'grep' succeeds (finds the text, code 0), run echo
grep "error" log.txt && echo "Found an error!"

# Using in Logic
if [ $? -eq 0 ]; then
    echo "Success"
else
    echo "Failed"
fi
````

## See Also

- [[Shell Options]] (Specifically `set -e`)
    
- [[Bash Logic]]