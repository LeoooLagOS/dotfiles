---
tags:
  - algorithm-pattern
  - reference
  - linux
category: 15_DevOps
status: learning
related: "[[Vi Editor]]"
date: 2026-01-12
---
# Vi Cheat Sheet

## 🧠 Problem Summary
Standard terminal editors require a mouse or complex modifier keys. Vi solves this by using **Modes**, allowing the user to perform complex text manipulations using only the standard alphanumeric keys. This cheat sheet maps the logical transitions between these states.

## 📋 Constraints & Edge Cases
- **Case Sensitivity:** Most commands are case-sensitive (`x` vs `X`).
- **State Awareness:** Always hit `Esc` if unsure of the current mode.
- **Remote Latency:** Commands may lag on high-latency SSH connections; wait for the buffer.

## 💡 Key Data Structure / Concept
The **Modal State Machine**:
- **Command Mode:** Logic/Navigation.
- **Insert Mode:** Data Input.
- **Ex Mode:** System/IO operations.

## 📜 Algorithm Explained (Logic Flow)

### 1. Navigation (Home Row Logic)
Instead of reaching for the arrow keys, use:
- `h`: Left 
- `j`: Down
- `k`: Up
- `l`: Right

### 2. Entering Insert Mode
- `i`: Insert before cursor.
- `a`: Append after cursor.
- `o`: Open a new line below.

### 3. Deletion & Undo
- `x`: Delete a single character.
- `dd`: Delete (cut) the entire current line.
- `u`: **Undo** the last operation (Reverse change).

### 4. Copy (Yank) & Paste (Put)
- `yy`: Yank (copy) the current line.
- `p`: Put (paste) the yanked text after the cursor.

### 5. Search
- `/pattern`: Search forward for "pattern".
- `n`: Move to the next match.

### 6. Saving and Exiting (Ex Mode)
- `:w`: Write (save) changes.
- `:q`: Quit (fails if there are unsaved changes).
- `:wq`: Write and Quit (Save and exit).
- `:q!`: Force quit (Discard changes).

## 🔧 Code Breakdown
To change from **Text Mode** (Insert) to **Line Mode** (Ex):
1. Hit `Esc` (Ensures you are in Command Mode).
2. Type `:` (Enters Last Line / Ex Mode).
3. Type the command (e.g., `wq`) and hit `Enter`.