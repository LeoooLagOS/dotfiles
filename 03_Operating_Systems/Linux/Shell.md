---
tags:
  - concept
  - linux
  - cli
  - terminal
category: os
status: learning
related: "[[Linux Architecture]]"
date: 2025-11-22
---
# Shell
## 📝 One-Sentence Summary
*The Shell is a command-line interpreter that acts as the interface between the user and the operating system Kernel, translating human-readable commands into system calls.*
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
## 🔗 Connections & Implementations
* To check which shell you are using: `echo $SHELL`
* To see available shells on the system: `cat /etc/shells`
* The Shell is Layer 3 in the [[Linux Architecture]].
## See Also
- [[Bash Startup Files]]
- [[Shell Scripting]]
- [[Linux Kernel]]