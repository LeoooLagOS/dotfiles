---
tags:
  - guide
  - best-practice
  - bash
  - naming
  - structure
category: os
status: reference
related: "[[Bash Best Practices and Standards]]"
date: 2026-01-03
---
# Bash Naming and Structure Standards
## 📝 One-Sentence Summary
*Standardized naming conventions (snake_case for functions, CAPS for constants) and structural rules (using a `main` function and strictly defining local variables) to prevent scope pollution and logic errors.*

## 💡 Analogy
* **Naming:** Think of this as "Uniforms." If constants wear Red (CAPS) and variables wear Blue (lowercase), you instantly know who is who on the battlefield.
* **Local Variables:** Think of `local` as a "quarantine." Without it, a variable defined inside a function leaks out and infects the rest of the script.
* **The `main` Function:** Think of this as the "Front Door." Instead of walking into a house through a random window (code scattered everywhere), you force execution through a single, defined entry point.

## 🔑 1. Naming Conventions
| Type | Case Style | Example | Notes |
| :--- | :--- | :--- | :--- |
| **Functions** | `snake_case` | `my_func()` | Use `::` for libraries (e.g., `pkg::func`). |
| **Variables** | `snake_case` | `file_path` | Loop variables should match targets (`for zone in "${zones[@]}"`). |
| **Constants** | `UPPER_CASE` | `MAX_RETRIES` | Make `readonly` immediately. |
| **Env Vars** | `UPPER_CASE` | `ORACLE_SID` | Exported variables. |
| **Files** | `snake_case` | `backup_script.sh` | Lowercase with underscores. |

## 🔑 2. Function Definitions
**Syntax:** Open brace on the same line.
```bash
# Single Function
my_func() {
  ...
}

# Package/Library Function
mypackage::my_func() {
  ...
}
```

#### 🔑 3. Variable Scope & Safety

### Read-only Variables

If a variable shouldn't change, lock it down.
```bash
zip_version="$(dpkg --status zip | grep Version:)"
readonly zip_version
```
### Local Variables (The "Separate Declaration" Rule)

**Critical Rule:** When assigning a local variable from a command substitution, **declare and assign on separate lines.**

- **Why:** If you do `local var="$(cmd)"`, the exit code `$?` comes from the `local` command (which is almost always 0), _hiding_ the fact that `cmd` might have failed.

```bash
# ✅ CORRECT
my_func() {
  local my_var
  my_var="$(command_that_might_fail)"
  if (( $? != 0 )); then return 1; fi
}

# ❌ WRONG (Error is swallowed)
my_func() {
  local my_var="$(command_that_might_fail)"
  # $? is 0 here because 'local' succeeded, even if command failed!
}
```
## ## 🔑 4. Script Architecture

### The `main` Function

For any non-trivial script, wrap your logic in a `main` function and call it at the very bottom.

- **Benefits:** Allows all variables to be `local`, prevents global scope pollution.

**Standard Layout:**
1. **Header** (Shebang & Comments)
    
2. **Constants** (`readonly PATH=...`)
    
3. **Functions** (All definitions)
    
4. **Main Call** (`main "$@"`)
```bash
#!/bin/bash
# Description of script...

readonly LOG_FILE="/var/log/app.log"

log_msg() {
  echo "$1"
}

main() {
  local input="$1"
  log_msg "Starting with input: ${input}"
}

main "$@"
```
#### 🔗 Connections

- **Scope Pollution:** This connects to **[[Environment Variables]]**. A script without `local` vars can accidentally overwrite system variables if names collide.
    
- **Debugging:** The "Separate Declaration" rule is a top 5 debugging fix for "silent failures" in Bash.
    

## See Also

- [[Bash Formatting and Syntax Standards]]
    
- [[Bash Functions]]
