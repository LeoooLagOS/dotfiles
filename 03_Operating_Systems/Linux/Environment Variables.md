---
tags:
  - shell
  - configuration
  - concept
  - linux
category: os
status: learning
related: "[[Shell]]"
date: 2025-11-22
---
# Environment Variables
## 📝 One-Sentence Summary
*Environment variables are dynamic, named values stored within the system that determine the behavior of running processes and are inherited by child processes.*
## 💡 Analogy
*Think of a Process like a **Traveler**. The **Environment Variables** are the contents of their **Backpack**.*
* When the Traveler (Parent Process) spawns a child (Child Process), the child gets a *copy* of that backpack.
* If the backpack contains `LANGUAGE=Spanish`, the child knows to speak Spanish. If it contains `PATH=/bin`, the child knows where to look for tools.
## 🔑 Key Details
- **Shell vs. Environment Variables:**
    - **Shell Variable:** Local to the current shell instance. *Not* passed to child processes.
        - Syntax: `MY_VAR="Hello"`
    - **Environment Variable:** Global. Passed to any program started by the shell.
        - Syntax: `export MY_VAR="Hello"`
- **Crucial Variables:**
    - **`PATH`:** A colon-separated list of directories where the shell looks for executable commands.
    - **`HOME`:** The current user's home directory.
    - **`USER`:** The current username.
    - **`SHELL`:** The path to the current shell interpreter.
- **Commands:**
    - `printenv` or `env`: Lists all current environment variables.
    - `echo $VAR_NAME`: Prints the value of a specific variable.
    - `export`: Promotes a shell variable to an environment variable.
## 🔗 Connections & Implementations
* **The `PATH` Problem:** If you type a command and get `command not found`, it usually means the directory containing that program is not in your `$PATH`.
* **Configuration:** These are almost always set in `[[Bash Startup Files]]` like `.bashrc` or `.bash_profile` to ensure they persist across reboots.
## See Also
- [[Shell]]
- [[Shell Scripting]]
- [[Process]]