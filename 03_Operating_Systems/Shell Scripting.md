---
tags:
  - scripting
  - programming
  - concept
  - devops
  - linux
  - OS
  - sysadmin
category: os
status: learning
related: "[[Shell]]"
date: 2025-11-22
---
# Shell Scripting
## 📝 One-Sentence Summary
*Shell scripting is the practice of writing a series of commands in a file to be executed by the shell, primarily used for automating system administration tasks rather than complex application development.*

## 💡 Analogy 
* **Shell Scripting** is like **Duct Tape**. It is perfect for connecting two unrelated things quickly (glue code) or fixing a small leak (automation). 
* It is **NOT** like **Concrete**. You wouldn't build the foundation of a skyscraper (complex application) out of duct tape; you need a structured language (Python, Go, C++) for that.
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

## ⚙️ The "100-Line" Rule (Best Practices) 
Shell is a command processor, not a development language. 
* **✅ When to USE Shell:** 
	* You are mostly calling other utilities (`grep`, `git`, `docker`). 
	* You are doing relatively little data manipulation. 
	* The script is short and linear. 
* **❌ When to SWITCH (to Python/Go):** 
	* **Length:** If the script exceeds **100 lines**. 
	* **Logic:** If control flow is non-straightforward (complex nested loops). 
	* **Maintainability:** If someone else would struggle to read it.
## 👍 Pros & 👎 Cons (When NOT to use)
* **👍 Best For:** 
	* Automating file manipulation, system boot scripts, simple text processing, and "glue" code to connect other programs.
* **👎 When to AVOID (Use Python/Go/C instead):**
    1.  **Resource-Intensive:** Tasks requiring complex algorithms (sorting, recursion, hashing) or high speed.
    2.  **Data Structures:** When you need linked lists, trees, or multi-dimensional arrays.
    3.  **Complex Logic:** If you need strict type-checking or function prototypes.
    4.  **Security:** Mission-critical systems where system integrity is paramount (Shell is vulnerable to injection and environment manipulation).
    5.  **Proprietary Code:** Shell scripts are plain text; you cannot hide the source code.
    6.  **GUIs:** Generating graphical interfaces is not native to shell.
    7. **Type Safety:** If you need strict type-checking or function prototypes.

## 🔗 Connections & Implementations
* **Wrappers:** The most common use case is writing a simple script to launch a complex Java or Python application with specific flags. 
* **CI/CD:** [[CI/CD Pipelines]] often use Shell for the "glue" steps, but call Python scripts for the "logic" steps.
* A script starts with a **Shebang** (`#!/bin/bash`) to tell the OS which interpreter to use.
* You must give the file execute permissions: `chmod +x script.sh`.
## See Also
* [[Process]]
- [[Linux Permissions]]
- [[Variables]]
- [[Bash Startup Files]]
- [[Shell]]