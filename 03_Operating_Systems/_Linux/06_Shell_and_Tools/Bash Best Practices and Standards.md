---
tags:
  - guide
  - best-practice
  - bash
  - documentation
  - style
category: os
status: learning
related: "[[Bash IO Redirection]]"
date: 2026-01-02
---
# Bash Best Practices and Standards
## 📝 One-Sentence Summary
*Professional Bash scripts require strict separation of output streams (STDOUT for data, STDERR for errors) and standardized documentation (headers, function contracts, and TODOs) to ensure maintainability.*
## 💡 Analogy
* **The Streams:** Think of a script like a juicer.
    * **STDOUT:** The juice (The product you want).
    * **STDERR:** The pulp/skins (The waste/status info).
    * If you mix them, the juice is ruined (you can't pipe the data cleanly to another tool).
* **Comments:** Think of comments as the "Instruction Manual" included in the box. Without it, the next person (or you in 6 months) won't know how to operate the machine safely.

## 🔑 1. Output Streams (STDOUT vs STDERR)
**Rule:** All error messages and status logs must go to **STDERR**.
* **Why:** This allows the user to pipe the actual output (STDOUT) to another program without pollution.
* **Implementation:** Use `>&2` to redirect echo output.

```bash
err() {
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]: $*" >&2
}

if ! do_something; then
  err "Unable to do_something"
  exit 1
fi
```
## ## 🔑 2. Documentation Standards

### File Header
Every file must start with a description.
```bash
#!/bin/bash
#
# Perform hot backups of Oracle databases.
# Usage: backup.sh [options] <database>
#
```

###### Function Comments
Any non-trivial function must have a comment block describing its **Contract**.

- **Description:** What it does.
    
- **Globals:** Global variables it reads/modifies.
    
- **Arguments:** What inputs it expects.
    
- **Outputs:** What it prints to STDOUT/STDERR.
    
- **Returns:** Exit codes.
```bash
#######################################
# Cleanup files from the backup directory.
# Globals:
#   BACKUP_DIR
#   ORACLE_SID
# Arguments:
#   None
# Outputs:
#   Writes progress to STDOUT.
# Returns:
#   0 if successful, non-zero on error.
#######################################
cleanup() {
  ...
}
```

## 🔑 3. Code Comments & TODOs

- **Implementation Comments:** Comment _tricky_ or _non-obvious_ logic. Do not comment obvious things (e.g., don't write `# Loop through list` above a `for` loop).
    
- **TODOs:** Use a consistent format to track temporary code.
    
    - **Format:** `TODO(username): description`
        
    - **Example:** `# TODO(lag-os): Handle the edge case where the directory is read-only.`
        

## 🔗 Connections & Implementations

- **Pipelines:** Proper STDERR usage is critical for chains like `myscript.sh | grep "result"`. If errors go to STDOUT, `grep` might match error text as data.
    
- **Collaboration:** Standardized headers allow other engineers to use your library without reading every line of code.
## See Also

- [[Bash IO Redirection]] (The syntax for `>&2`)
    
- [[Bash Functions]]