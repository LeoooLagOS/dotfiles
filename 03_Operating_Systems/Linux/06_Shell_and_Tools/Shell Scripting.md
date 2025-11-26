---
tags: concept, linux, programming, scripting
category: os
status: learning
related: "[[Shell]]"
date: 2025-11-22
---
# Shell Scripting
## 📝 One-Sentence Summary
*Shell scripting is the practice of writing a series of commands in a file to be executed by the shell, primarily used for automating system administration tasks rather than complex application development.*
## 🔑 Syntax & Variables
- **Assignment:** **No spaces** around the equals sign.
    - ✅ Correct: `NAME="lagOS"`
    - ❌ Wrong: `NAME = "lagOS"`
- **Conventions:** Environment variables use `UPPER_CASE`; local script variables usually use `snake_case`.
- **Multiple Values:** Separated by a colon `:`.
    - Example: `PATH=/bin:/usr/bin:/local/bin`
- **Categories:**
    1.  **Shell Variables:** Local to the current instance.
    2.  **Environment Variables:** Inherited by child processes (exported).
## 👍 Pros & 👎 Cons (When NOT to use)
* **👍 Best For:** 
	* Automating file manipulation, system boot scripts, simple text processing, and "glue" code to connect other programs.
* **👎 When to AVOID (Use Python/Go/C instead):**
    1.  **Resource-Intensive:** Tasks requiring complex algorithms (sorting, recursion, hashing) or high speed.
    2.  **Data Structures:** When you need linked lists, trees, or multi-dimensional arrays.
    3.  **Complex Logic:** If you need strict type-checking or function prototypes.
    4.  **Security:** Mission-critical systems where system integrity is paramount (Shell scripts are easily manipulated).
    5.  **Proprietary Code:** Shell scripts are plain text; you cannot hide the source code.
    6.  **GUIs:** Generating graphical interfaces is not native to shell.
## 🔗 Connections & Implementations
* A script starts with a **Shebang** (`#!/bin/bash`) to tell the OS which interpreter to use.
* You must give the file execute permissions: `chmod +x script.sh`.
## See Also
- [[Linux Permissions]]
- [[Variables]]
- [[Bash Startup Files]]