---
tags:
  - editor
  - cli
  - tool
  - linux
category: os
status: learning
related: "[[Vim]]"
date: 2025-11-22
---
# Nano
## 📝 One-Sentence Summary
*Nano is a simple, modeless, easy-to-use command-line text editor that displays key bindings at the bottom of the screen.*
## 💡 Analogy
* **Nano** is like **Windows Notepad**. You open it and just start typing. There are no hidden modes or complex chords to learn. It's a "what you see is what you get" experience, perfect for quick edits.
## 🔑 Key Details
- **Modeless:** Unlike [[Vim]], you don't need to switch between "Insert" and "Command" modes. You are always in input mode.
- **Control Keys:** Commands are executed using the `Ctrl` key (represented as `^` in the interface).
- **The "Cheatsheet" (Always Visible):** The bottom two lines of the screen show the most common commands.
## ⚙️ Core Commands
| Key | Action | Description |
| :--- | :--- | :--- |
| **`Ctrl + O`** | **O**utput | Save the file ("Write Out"). |
| **`Ctrl + X`** | E**x**it | Close the editor. |
| **`Ctrl + W`** | **W**here is | Search for text. |
| **`Ctrl + K`** | Cut | Cut the current line. |
| **`Ctrl + U`** | **U**ncut | Paste the cut line. |
## 🔗 Connections & Implementations
* **Default Editor:** On many beginner-friendly distros (like Ubuntu), Nano is often set as the default editor for `visudo` or git commits.
* **Usage:** `nano filename.txt`
## See Also
- [[Vim]]
- [[Visudo]]