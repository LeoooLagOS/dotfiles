---
tags:
  - guide
  - linux
  - bash
  - scripting
  - syntax
category: os
status: learning
related: "[[Shell Scripting]]"
date: 2025-11-28
---
# Bash Script Structure
## 📝 One-Sentence Summary
*A Bash script is a plain text file containing a list of system commands, headed by a "Shebang" that tells the kernel which interpreter to use.*
## 🔑 Key Components
### 1. The Shebang (`#!`)
The very first two bytes of the file (`#!`) tell the system: "This is a script, use the following program to run it."
* **Examples:**
    * `#!/bin/bash`: Execute with Bash.
    * `#!/bin/sh`: Execute with the legacy Bourne shell (or system default).
    * `#!/usr/bin/env python`: Execute with Python (finding it in your PATH).
    * `#!/bin/sed -f`: Use Sed as the interpreter.

### 2. Invocation Methods
* **Interpreter Argument (No permissions needed):**
    * `bash scriptname.sh`
    * `sh scriptname.sh`
    * *Drawback:* Ignores the Shebang line; forces the specified shell.
* **Direct Execution (The Standard Way):**
    1.  **Grant Permission:** `chmod +x scriptname.sh`
    2.  **Run:** `./scriptname.sh`
    * *Benefit:* Respects the Shebang and runs as a proper executable.

## 🔗 Connections & Implementations
* **File Extension:** `.sh` is conventional but not required by Linux. The Shebang determines the type, not the extension.
* **Path:** You use `./` because the current directory is not in your `$PATH` by default for security reasons.
## See Also
- [[Shell]]
- [[Permissions]]