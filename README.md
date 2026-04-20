# 🚀 lagOS-station: Enterprise-Grade Desktop Infrastructure

[![System](https://img.shields.io/badge/System-Fedora_43-blue?style=for-the-badge&logo=fedora)](https://getfedora.org/)
[![Shell](https://img.shields.io/badge/Shell-Zsh-orange?style=for-the-badge&logo=zsh)](https://www.zsh.org/)
[![Manager](https://img.shields.io/badge/Orchestration-GNU_Stow-green?style=for-the-badge)](https://www.gnu.org/software/stow/)
[![Specialization](https://img.shields.io/badge/Focus-Cybersecurity_%26_DevOps-red?style=for-the-badge)](https://github.com/lag-os)

## 🏗️ Architectural Overview

The **lagOS-station** is built on a **Modular Application-Centric** architecture. Unlike standard dotfile repositories that clutter the root directory, this system uses **logical separation** to ensure that each component (Hyprland, Kitty, Shell) remains **environment-agnostic** and easily deployable via **GNU Stow**.

### Core Philosophy: "Cattle, Not Pets"
Every component of this workstation is designed to be **idempotent**. By utilizing package lists and declarative symlinking, the entire engineering environment can be reproduced on a clean **Fedora** host in minutes.

---

## 🌳 Directory Structure

```text
dotfiles/
├── config/             # Application Registry (~/.config)
│   ├── hypr/           # Hyprland WM: Window rules and UI logic
│   ├── kitty/          # GPU-accelerated terminal infrastructure
│   └── starship.toml   # The Sentinel: Multi-line stacked prompt logic
├── git/                # Global Git provenance (~/.gitconfig)
├── nvim/               # Neovim IDE: LazyVim-based development layer
├── scripts/            # The Logic Layer: Custom engineering utilities
│   ├── build-paper/    # Automated Academic Reporting (MD -> IEEE PDF)
│   └── lagos-shot/     # Python-powered technical capture utility
├── System/             # Infrastructure as Code (IaC) Provisioning
│   ├── pkglist.txt     # DNF binary requirements
│   └── flatpaks.txt    # Containerized application registry
└── zsh/                # Modular shell and Sentinel System Check
```

## 🛠️ Key Engineering Modules

### 1. Desktop Orchestration (`config/hypr`)
Initially bootstrapped from the JaKooLit framework, the current configuration has been decoupled and flattened.
-    **Logical Mapping:** All nested .config redundancies have been eliminated for direct mapping.
-   **Deterministic Keybinds:** Specialized shortcuts for cybersecurity audits and system monitoring.

### 2. Neovim IDE (`/nvim`)
- A **LazyVim** implementation optimized for **Go**, **Python**, and **Markdown** editing, featuring a deterministic plugin lockfile for reproducible development environments.

### 3. The Logic Layer (`/scripts`)
- **lagos-shot.py:** A robust **Python 3.14 utility** that abstracts regional screen capture. It handles **EXDEV cross-device boundaries** between RAM-based `/tmp` storage and physical drives, automatically injecting absolute Markdown paths into the clipboard for Obsidian integration.

- **build-paper.py:** A **Pandoc/LaTeX** orchestration script designed to compile technical laboratory reports into IEEE-standardized PDFs. It features custom compatibility macros for **Pandoc 3.2+** image bounding and scaling.

### 4. System Provisioning (`/System`)
Maintains the blueprint for the host machine. By centralizing `pkglist.txt` and `flatpaks.txt`, the environment remains highly portable, facilitating rapid deployment across workstation and server environments used in SOC or Blue Team simulations.

### 5. The Sentinel Shell (`/zsh` & `config/starship.toml`)
- **Sentinel System Check**: An automated diagnostic function executed upon shell initialization to verify **KVM/libvirt** status, runtime versions (**Java**, **.NET**, **Python**, **Go**), and **Git** identity.

- **Stacked Sentinel Prompt**: A custom **Starship** configuration that provides real-time Git telemetry for the *Maestro Vault* (Obsidian) directly in the command line.


## 🚀 Deployment Workflow

This repository utilizes GNU Stow to manage symbolic links, ensuring that the source code remains under version control while appearing in the standard Linux filesystem hierarchy.

**Prerequisites**
```Bash
sudo dnf install stow hyprland kitty zsh python3-pathlib
```

**Installation**

From the root of the `~/dotfiles` directory, invoke the orchestration:

```Bash
# Synchronize application configurations
stow -v -t ~/.config config

# Inject modular shell settings
stow -v -t ~/ zsh

# Establish global git identity
stow -v -t ~/ git
```

## 🕵️ DevSecOps & Best Practices
-   **Secret Management:** No raw API keys or private tokens are stored within this repository. Environment variables are injected at runtime via local (Git ignored) files.

-   **Atomic Refactoring:** This repository follows the **Conventional Commits** standard to maintain a clear audit trail of infrastructure changes.

-   **Clean Purge Policy:** Legacy backup artifacts and corrupted reparse tags are systematically purged to reduce the system's attack surface and cognitive load.

## 🚧 Roadmap & Technical Debt

While the infrastructure is stable and declarative, the following architectural improvements are prioritized for the next sprint:

* **Logic Consolidation (High Priority)**: Audit the `config/hypr/scripts` directory to decouple essential UI logic from legacy JaKooLit artifacts.
* **Shell-to-Python Migration**: Refactor remaining high-complexity Shell scripts into deterministic Python modules to improve exception handling and system portability.
* **Sentinel Integration**: Establish a bridge between the desktop configuration and the **Sentinel** system monitor for real-time telemetry.
---
Maintained as part of the lagOS-station project, 2026.