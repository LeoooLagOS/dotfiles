---
tags:
  - university
course: undefined
professor: undefined
date: 2026-01-14
status: raw
---
# 📝 Class: [[class-4]]

## 🎯 Main Goal of Today
*Deep dive into advanced `vi` text manipulation and buffer management.*

## 📓 Live Lecture Notes
- **Memory Management:** `vi` loads the entire file content into RAM for editing.
    
- **Architecture:** Classic UNIX editor, case-sensitive, and designed for minimal keystroke overhead.
    
- **Modes Recap:** Command (Default), Text (Insert), and Line (Ex mode for commands).
    
- **Buffer Logic:** Deleted text is stored in a temporary buffer; use `p` (put) to recover/paste.
    
- **⚠️ Exam Warning:** Master the global search and replace syntax (`:g/s//gc`) and line-specific deletions.

## 🛠️ **Code/Logic:**

- **Movement:** `h` (left), `j` (down), `k` (up), `l` (right).
    
- **Extended Jumps:** `1G` (Start of file), `G` (End of file).
    
- **Text Insertion:** `A` (End of line), `I` (Start of line), `o` (New line below), `O` (New line above).

#### Navigation (Command Mode)

| Command | Action                          |
| ------- | ------------------------------- |
| `h`     | Move cursor **Left**            |
| `l`     | Move cursor **Right**           |
| `k`     | Move cursor **Up**              |
| `j`     | Move cursor **Down**            |
| `1G`    | Go to the **Start** of the file |
| `G`     | Go to the **End** of the file   |

#### Text Commands (Insert Mode Transitions)

|Command|Action|
|---|---|
|`i`|Insert text to the **left** of the cursor|
|`a`|Insert text to the **right** of the cursor (append)|
|`A`|Insert text at the **end** of the current line|
|`I`|Insert text at the **beginning** of the current line|
|`o`|Open a new line **below** the current one|
|`O`|Open a new line **above** the current one|
#### Deletion & Buffer Operations

|Command|Action|
|---|---|
|`x`|Delete character under the cursor|
|`dd`|Delete (cut) the current line|
|`ndd`|Delete the next `n` lines (e.g., `3dd`)|
|`D`|Delete from cursor to the end of the line|
|`dw`|Delete from cursor to the end of the word|
|`u`|**Undo** last change|
|`p`|**Paste** (put) buffer contents after cursor|
#### Search & Exit (Line/Ex Mode)

| Command          | Action                           |
| ---------------- | -------------------------------- |
| `/text`          | Search forward for "text"        |
| `?text`          | Search backward for "text"       |
| `:q`             | Quit (only if no changes)        |
| `:q!`            | Quit without saving changes      |
| `:w`             | Save changes                     |
| `:w file1`       | Save as `file1`                  |
| `:wq`            | Save and quit                    |
| `:g/t1/s/t2/g`   | Global replace `t1` with `t2`    |
| `:g/t1/s//t2/gc` | Global replace with confirmation |
## 📂 **Follow-up Tasks:**

- [x] Create Atomic Note: `[[Advanced Vi Operations]]`
    
- [x] Solve Lab Exercises: `[[Ejercicio 1, 2, 3]]`
    
- [ ] Review during Commute: [[Editor_Vocab]]

