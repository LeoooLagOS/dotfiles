---
tags:
  - cli
  - productivity
  - editor
  - tool
  - linux
category: os
status: learning
related: "[[Shell]]"
date: 2025-11-22
---
# Vim (Vi Improved)
## 📝 One-Sentence Summary
*Vim is a highly configurable, keyboard-centric, modal text editor built to create and change any kind of text very efficiently.*
## 💡 Analogy
* **Notepad/Nano** is like a **Typewriter**. You press a key, and the letter appears on the paper. It's intuitive but limited.
* **Vim** is like a **Piano**. You don't just press keys to make sounds; you play "chords" (combinations of keys) to perform complex actions. You must learn the scales (modes), but once mastered, you can play fast and without looking at your hands.
## 🔑 The 3 Modes
Vim is "modal," meaning the same key does different things depending on the active mode.
1.  **Command Mode (Normal):** The default mode. Keys are used for navigation and manipulation (e.g., `dd` deletes a line). Press `[Esc]` to return here.
2.  **Input Mode (Insert):** Used for typing text. Press `i` to enter.
3.  **Last-line Mode (Command-line):** Used for saving, exiting, and search/replace. Press `:` to enter.

## ⌨️ The "Cheatsheet"
### Navigation (Command Mode)
* **`h` `j` `k` `l`**: Left, Down, Up, Right (Keeps fingers on home row).
* **`w`**: Jump forward one **w**ord.
* **`b`**: Jump **b**ack one word.
### Editing
* **Visual Modes:**
    * `v`: Visual character (select text).
    * `V`: Visual line (select whole lines).
    * `Ctrl+v`: Visual block (select vertical columns).
* **Copy & Paste:**
    * `y`: **Y**ank (Copy selected). `yy` (Copy current line).
    * `p`: **P**ut (Paste after cursor). `P` (Paste before cursor).
* **Delete (Cut):**
    * `d`: Delete selected. `dd` (Delete current line). `dw` (Delete word).
* **Undo/Redo:**
    * `u`: **U**ndo.
    * `Ctrl+r`: **R**edo.
### Searching
* `/text`: Search forward for "text".
* `?text`: Search backward for "text".
* `n`: Next occurrence.
* `N`: Previous occurrence.
## 🔗 Connections & Implementations
* **Learning:** Run `vimtutor` in the terminal for an interactive tutorial.
* **System Admin:** Used by [[Visudo]] for safe configuration editing.
## See Also
- [[Shell]]
- [[Visudo]]