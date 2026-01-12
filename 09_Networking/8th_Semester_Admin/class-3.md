---
tags:
  - university
course: undefined
professor: undefined
date: 2026-01-12
status: raw
---
# 📝 Class: [[class-3]]

## 🎯 Main Goal of Today
*Master the `vi` editor for remote system administration and configuration.*

## 📓 **Live Notes:**
- **The Editor Spectrum:** Identifying modern vs. legacy editors (Nano → Vi → Vim → Nvim).
    
- **Vi Modes:** Understanding the state machine of the editor (Command, Insert, and Last Line/Ex mode).
    
- **Navigation:** Using `h`, `j`, `k`, `l` instead of arrow keys to maintain home-row efficiency.
    
- **Manipulations:** * _Undo:_ `u` (Reverse changes).
    
    - _Delete:_ `x` (character), `dd` (line).
        
    - _Copy/Paste:_ `yy` (yank), `p` (put).
        
    - _Search:_ `/` followed by the term.
        
- **Exiting:** `:q` (quit), `:q!` (force quit), `:wq` (write and quit).
    
- **State Change:** Pressing `i`, `a`, or `o` to move from Command to Insert mode; `Esc` to return.
## 🛠️ **Code/Logic:**
- Movement logic: `k` (up), `j` (down), `h` (left), `l` (right).
    
- Command syntax: `:<command>` for line-mode operations.

## 📂 **Follow-up Tasks:**

- [x] Create Atomic Note: [[Vi Editor]]
    
- [x] Refactor/Create Code: [[Vi Cheat Sheet]] (Algorithm/Logic format).
    
- [x] Review during Commute: [[Editor_Vocab]]