---
tags:
  - overview
  - setup
  - linux
  - fedora
  - hyprland
category: setup
status: active
related: "[[_Linux]]"
date: 2025-12-08
---
# _Fedora Workstation_

## 📝 One-Sentence Summary

A professional-grade development environment running on Fedora Linux, architected with a **Tiling Window Manager (Hyprland)** and managed through a **Self-Healing Infrastructure as Code (IaC)** philosophy.

## 💡 Analogy

This workstation is my **Digital Workshop**. Just as a carpenter uses jigs and templates to ensure every cut is identical, this system uses **Symlinks** and **Git** to ensure that my tools, my workbench (the UI), and my blueprints (dotfiles) are perfectly aligned, versioned, and reproducible.

## 📜 History & Creator

- **Curator:** [[Leonardo Lagos]]
    
- **Hardware Target:** HP Victus-874
    
- **Current Iteration:** Fedora 43 (Custom Hyprland environment with a "DankMaterial" Pill aesthetic).
    

## 🔑 Core Philosophy & Design

- **Atomic State Management:** Every system change is captured as a Git commit (using Conventional Commits).
    
- **Self-Healing Integrity:** The system verifies its own symbolic links before allowing backups (`check-links` pre-flight).
    
- **Layered Security:** Sensitive credentials (identity, tokens) are kept in `.local` files, decoupled from the public dotfiles repository.
    
- **Cognitive Flow:** A "Pill" based Waybar HUD that provides real-time feedback on Obsidian Sync and Study Streaks.
    

## 🌳 System Structure

```Plaintext
/home/lag-os/ 
│ 
├── ⚙️ dotfiles/       (Git Repo: The 'Brain') 
│   ├── .git/          (Version Control) 
│   ├── .zshrc         (Logic & Logic Hub) 
│   ├── config-waybar/ (Pill-style UI)
│   ├── hypr/          (WM & Lockscreen)
│   ├── scripts/       (Vault-check, Health-checks)
│   ├── pkglist.txt    (DNF Manifest)
│   └── flatpaks.txt   (Flatpak Manifest)
│ 
├── 🚀 Development/    (Active Construction) 
│   ├── projects-ai/   
│   └── uni-cs/        (Distributed Systems, PCAM, MPI)
│ 
├── 🏛️ Documents/      (Static Knowledge) 
│   └── My-CS-Notes/   (Obsidian Vault / Second Brain) 
│ 
└── 📥 Downloads/      (Transient Buffer)
```


## ⚙️ Key Details

### 1. Automation Logic 🤖

The system is managed by two primary "Engine" functions in the `.zshrc`:

- `save-dots()`: A robust backup function that snapshots packages, verifies symlink health, and pushes state to GitHub.
    
- `check-links()`: A transparency tool that reports the health of the connection between `$HOME` and `~/dotfiles`.
    

### 2. The User Interface (DankMaterial) 🎨

- **Window Manager:** [[Hyprland]].
    
- **Status Bar:** [[Waybar]] (Configured with floating "Pills" and rounded corners for a GNOME-like feel).
    
- **Environment HUD:** Live Git indicators for the Obsidian Vault to ensure no data is left un-pushed.
    

### 3. Disaster Recovery Plan 🛡️

- **Recovery Command:** `restore-dots` automatically parses the `pkglist.txt` to reinstall the entire environment on any DNF, APT, or Pacman-based system.
    
- **Safety Net:** Symlink integrity is enforced at the hardware level; broken links are detected before backup.
    

## 🔗 Connections & Implementations

- **Base OS:** [[Fedora Linux]]
    
- **Shell Logic:** [[Zsh]] + [[Starship]] + [[FZF]]
    
- **Configuration Sync:** [[_Git]] (Public Repository)
    
- **Secret Management:** `.local` inclusion layer for private credentials.
    

## See Also

- [[_Disaster Recovery Plan]]
    
- [[Conventional Commits]]
    
- [[Hyprland]]
    
- [[Cybersecurity Best Practices]]