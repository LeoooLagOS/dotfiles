---
tags:
  - configuration
  - debugging
  - linux
  - bash
  - tool
category: os
status: learning
related: "[[Bash Script Structure]]"
date: 2025-11-28
---
# Shell Options (set command)
## 📝 One-Sentence Summary
*The `set` command enables or disables options that change the behavior of the shell, such as exiting immediately upon error or printing commands as they execute.*
## 🔑 Enable vs. Disable
Counter-intuitively:
* **`set -` (Minus):** **Enables** an option (Turns it ON).
* **`set +` (Plus):** **Disables** an option (Turns it OFF).

## ⚙️ Common Options
| Short | Long Form | Description |
| :--- | :--- | :--- |
| **`set -e`** | `set -o errexit` | **Exit on Error.** The script stops immediately if any command returns a non-zero exit code. Essential for robust automation. |
| **`set -v`** | `set -o verbose` | **Verbose.** Prints shell input lines as they are read. Good for debugging. |
| **`set -x`** | `set -o xtrace` | **Trace.** Prints commands *and arguments* as they are executed. The gold standard for debugging. |
| **`set -u`** | `set -o nounset` | **Unset Variable Check.** Exits if you try to use a variable that doesn't exist (prevents typos like `rm -rf /$VAR` destroying root). |

## 🚀 Examples in Context
**Without `set -e` (Default):**
```bash
cat non-existing-file.txt  # Fails
echo "moving on"           # Runs anyway
```

**With `set -e` (Safe):**
```bash
set -e
cat non-existing-file.txt  # Fails
echo "moving on"           # Never runs. Script dies here.
```

## See Also

- [[Exit Codes]]
    
- [[Bash Script Structure]]