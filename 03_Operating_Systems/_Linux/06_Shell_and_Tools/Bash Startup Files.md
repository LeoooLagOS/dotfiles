---
tags:
  - bash
  - configuration
  - linux
  - concept
  - shell
category: os
status: learning
related: "[[Shell]]"
date: 2025-11-22
---
# Bash Startup Files
## 📝 One-Sentence Summary
*Bash startup files are specific scriptsread by the shell that run automatically when a shell session starts, used to set up the environment (variables, aliases, prompts) with the specific files loaded depending on whether the shell is a "Login" or "Non-Login" instance.*
## 💡 Analogy
* **Login Shell** (`.bash_profile`):
	* Like **arriving at the office**. You swipe your badge, turn on the lights, and adjust your desk chair. You do this once a day.
* **Non-Login Shell (`.bashrc`):** 
	* **Opening a New Browser Tab.** You are already at your desk. You don't show ID again. You just need your browser bookmarks and extensions ready (`~/.bashrc`).

## Definitions: Types of Shells 
* **Interactive:** 
	* You can type commands. The shell is waiting for user input (stdin is a terminal). 
* **Login:** 
	* You successfully authenticated (entered username/password) or used the `--login` flag. 
* **Non-Login:** 
	* You started a new terminal window from an existing desktop session (no new authentication required).
## 🔑 The Execution Hierarchy
The file loaded depends on how you enter the system:
1.  **Login Shell** (SSH login or GUI login):
    - Looks for `~/.bash_profile`, `~/.bash_login`, or `~/.profile` (in that order).
    - *Purpose:* Set environment variables (like PATH) that should be available to *all* child processes.
2.  **Non-Login Interactive Shell** (Opening a new terminal tab):
    - Reads `~/.bashrc`.
    - *Purpose:* Set aliases, prompt customization (`PS1`), and history settings.

## ⚙️ The Execution Order 
Bash looks for files in a specific order. 
### 1. Interactive Login Shell
*(e.g., SSH connection, TTY login, or `bash --login`)* 
1. **`/etc/profile`**: (System-wide configuration). 
2. **`~/.bash_profile`** OR **`~/.bash_login`** OR **`~/.profile`**: * Bash looks for these **in this specific order**. * It executes the **first one** it finds and ignores the others. 
3. **`~/.bash_logout`**: Executed only when you type `exit` or log out. 
### 2. Interactive Non-Login Shell 
*(e.g., Opening Gnome-Terminal, VS Code Terminal)* 
1. **`~/.bashrc`**: The user's per-shell configuration. 
	* *Note:* This is where you put Aliases (`alias ll='ls -l'`) and Prompt settings (`PS1`).
## 🔗 Connections & Implementations
* **The "Sourcing" Trick:** 
	* Since Login shells (like SSH) don't automatically read `~/.bashrc`, most `~/.bash_profile` files contain a script to explicitly **source** it: 
``` bash 
	# Inside ~/.bash_profile 
	if [ -f ~/.bashrc ]; then 
		. ~/.bashrc fi 		
``` 
*This ensures your aliases work everywhere.*
* **Common Practice:** Most `.bash_profile` files contain a command to explicitly load `.bashrc` so that your settings apply everywhere.
* **Global Config:** The system-wide equivalents are in `/etc/profile` and `/etc/bashrc`.
## See Also
- [[Shell]]
- [[Shell Scripting]]
- [[Environment Variables]]