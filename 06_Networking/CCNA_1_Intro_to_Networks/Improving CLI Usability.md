---
tags:
  - concept
  - networking
  - command
  - configuration
  - Cisco_IOS
  - ccna
category: networking
status:
  - learning
related: "[[Cisco IOS Modes]]"
date: 2025-10-08
---

# Improving CLI Usability

## 📝 One-Sentence Summary
*The `logging synchronous` and `exec-timeout` commands are used on the console and VTY lines to improve the command-line experience and enhance security.*

## 💡 Analogy
*Think of working at your desk. * **`logging synchronous`** is like having a "do not disturb" feature that prevents the office intercom (console messages) from blasting while you're in the middle of typing a sentence. * **`exec-timeout`** is like an automatic screen lock on your computer; if you walk away from your desk for a few minutes, it automatically locks to prevent others from using it.*
## 🔑 Key Details
- **What they are:** 
	- Line-specific commands that improve the quality of life for an administrator and secure open sessions. 
- **Why they exist:** 
	- To prevent disruptive console messages from interrupting commands and to automatically log out inactive sessions, which is an important security measure.
## 🔗 Connections & Implementations
*These commands are applied within the line configuration mode for `line console 0` and `line vty 0 15`.* 
### Key Usability Commands
| Command                    | Purpose                                                                                                                                     |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------- |
| `logging synchronous`      | Prevents console log messages from appearing in the middle of a typed command, reprinting the user's current line after the message.        |
| `exec-timeout <min> [sec]` | Automatically logs a user out of a console or VTY session after a specified period of inactivity. Setting it to `0 0` disables the timeout. |
|                            |                                                                                                                                             |
### Example
```cisco
S1(config)# line console 0
S1(config-line)# logging synchronous
S1(config-line)# exec-timeout 15 0
````

## See Also

- [[Initial Device Security Configuration]]
    
- [[VTY Lines]]