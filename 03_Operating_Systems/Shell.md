---
tags:
  - concept
  - linux
  - cli
  - terminal
category: os
status: learning
related: "[[_Bash_Scripting]]"
date: 2025-11-22
---
# Shell
## 📝 One-Sentence Summary
*The Shell is a command-line [[Interpreter]] that acts as the interface between the user and the operating system Kernel, translating human-readable commands into system calls.*
## 💡 Analogy
*If the **Kernel** is the **Engine** of a car, the **Shell** is the **Dashboard** (Steering wheel, pedals, buttons). You don't touch the pistons directly; you press a pedal (enter a command), and the pedal mechanism (Shell) tells the engine what to do.*
## 🔑 Key Details
- **What it is:** A program that takes commands from the keyboard and gives them to the OS to perform.
- **Types of Shells:**
    - **sh (Bourne Shell):** The original, basic Unix shell.
    - **bash (Bourne Again Shell):** The default on most Linux systems. An improved version of `sh`.
    - **zsh (Z Shell):** Highly customizable, currently the default on macOS.
    - **csh / tcsh:** C-like syntax shells (less common now).
- **Two Modes:**
    1.  **Interactive:** You type, it responds (The terminal window).
    2.  **Non-Interactive:** It reads commands from a file (Shell Scripts).

## ⚙️ Shell Management 
* **List Valid Shells:** 
```bash 
cat /etc/shells 
``` 
* **Check Current Shell:** 
```bash 
echo $SHELL # Shows default shell 
ps --pid $$ # Shows the actual process name of the current shell 
``` 
* **Switching:** Simply type the name of the shell (e.g., `/bin/sh`) to enter a new shell session. Type `exit` to return to the previous one. 
## 🛡️ Common Shell Types 
| Shell      | Full Name                 | Description                                                                                                                                                |
| :--------- | :------------------------ | :--------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **`sh`**   | **Bourne Shell**          | The original UNIX shell. Small, fast, few features. Available on almost every system for compatibility.                                                    |
| **`bash`** | **Bourne Again Shell**    | The standard GNU shell. A **superset** of `sh` (compatible with sh commands, plus plugins/addons). Intuitive and powerful.                                 |
| **`csh`**  | **C Shell**               | Syntax resembles the C programming language. Popular with old-school C programmers.                                                                        |
| **`tcsh`** | **TENEX C Shell**         | A "Turbo" version of C Shell with better user-friendliness and speed.                                                                                      |
| **`ksh`**  | **Korn Shell**            | A superset of Bourne shell. Powerful but configuration can be complex for beginners.                                                                       |
| **`dash`** | **Debian Almquist Shell** | A lighter, faster version of `sh` often used by the system (Debian/Ubuntu) for booting scripts (represented as `/bin/sh` symlink).                         |
| **`zsh`**  | **Z Shell**               | **The Developer Standard.** The default on macOS. Famous for its plugin ecosystem (Oh My Zsh), themes, and advanced auto-completion. Compatible with Bash. |
## 🔗 Connections & Implementations
* **Scripting Compatibility:** 
	* Scripts written for `sh` will run in `bash`, `zsh`, and `ksh`. 
	* Scripts written for `bash` (using bash-isms) might fail in `sh` or `dash`.
	* Scripts written for `fish` require `fish` to run.
* The Shell is Layer 3 in the [[Linux Architecture]].
* **Login Shell vs Non-Login:** Defined in [[Bash Startup Files]]. 
* **Scripting:** Because `bash` is a superset of `sh`, a script written for `sh` will run in `bash`, but a `bash` script might crash in `sh`. 
## See Also
- [[Bash Startup Files]]
- [[Shell Scripting]]
- [[Kernel]]