# 🚀 lagOS-station: Enterprise-Grade Desktop Infrastructure

[![System](https://img.shields.io/badge/System-Fedora_43-blue?style=for-the-badge&logo=fedora)](https://getfedora.org/)
[![Shell](https://img.shields.io/badge/Shell-Zsh-orange?style=for-the-badge&logo=zsh)](https://www.zsh.org/)
[![Manager](https://img.shields.io/badge/Orchestration-GNU_Stow-green?style=for-the-badge)](https://www.gnu.org/software/stow/)
[![Specialization](https://img.shields.io/badge/Focus-Cybersecurity_%26_DevOps-red?style=for-the-badge)](https://github.com/lag-os)
[![Security](https://img.shields.io/badge/Provenance-GPG_Signed-success?style=for-the-badge&logo=gnupg)](https://github.com/lag-os)

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
│   ├── kitty/          # GPU-accelerated terminal configuration
│   └── starship.toml   # Cross-shell prompt customization
├── git/                # Global Git provenance: Delta & GPG Signing
├── gpg/                # GPG Environment: Agent logic and TTL cache
│   └── gpg-agent.conf  # Passphrase caching and pinentry rules
├── install.sh          # Idempotent System Bootstrapper
├── nvim/               # Neovim IDE: LazyVim-based development layer
├── scripts/            # The Logic Layer: IDE wrappers and custom utilities
│   ├── build-paper/    # Automated Academic Reporting (MD -> IEEE PDF)
│   └── lagos-shot/     # Technical capture and Obsidian injection utility
├── System/             # Infrastructure as Code (IaC) Provisioning
│   ├── flatpaks.txt    # Application-layer dependency list
│   └── pkglist.txt     # DNF system-package registry
└── zsh/                # Modular shell: Senior Aliases and Sentinel logic
```

## 🛠️ Key Engineering Modules

### 1. Global Git Provenance (`/git`)
The version control layer is optimized for high-velocity code review and cryptographic security.
- **Delta Pager**: Implements a high-performance, syntax-highlighting pager for all `git`, `diff`, and `grep` outputs, providing an IDE-like experience in the terminal.
- **zdiff3 Conflict Resolution**: Uses the "Common Ancestor" merge style to provide the baseline context during logic conflicts, essential for complex PR resolution.
- **Cryptographic Identity**: Enforces GPG-signed commits for all infrastructure changes to ensure non-repudiation and verified status on remote repositories.

### 2. The Sentinel Shell (`/zsh`)
A modular shell environment focused on command-line speed and repository awareness.
- **Global Macros**: Implements Zsh global aliases (`G`, `L`, `NE`, `CJ`) for rapid text filtering and JSON processing across any command.
- **Senior Aliases**: Optimized Git and navigation shortcuts designed for atomic commits and rapid context switching between project roots.
- **Environment Integration**: Deep integration with **SDKMAN!** and **GPG_TTY** to maintain consistent toolchain availability.

### 3. The Logic Layer (`/scripts`)
All application wrappers and custom research tools are managed as discrete, tracked modules in `~/dotfiles/scripts` and symlinked to `~/.local/bin`.
- **lagos-shot**: A specialized capture utility optimized for rapid technical documentation.
- **build-paper**: A research-grade orchestration script for automated LaTeX/Markdown compilation.

### 4. GPG Infrastructure (`/gpg`)
Standardizes the cryptographic environment for secure, frictionless engineering sessions.
- **Agent Orchestration**: Externalized `gpg-agent.conf` managing a 12-hour TTL cache, balancing workstation security with operational efficiency.
- **TTL Lifecycle**: Implements automatic cache expiration to protect identities during inactive periods.

### 5. System Provisioning (`/System`)
Adopts an **Infrastructure-as-Code (IaC)** approach to workstation state management.
- **Declarative Lists**: Tracks system-level dependencies via `pkglist.txt` (DNF) and application-layer tools via `flatpaks.txt`.
- **Bootstrapper**: Utilizes `install.sh` for idempotent environment deployment, ensuring the **lagOS-station** can be reconstructed from a clean install in minutes.

### 📋 Prerequisites

Before deploying, ensure the core system engine, window manager, and terminal emulator are installed along with the necessary scripting and security dependencies.

On **Fedora**, these can be provisioned via DNF:

```Bash
# 1. Install Core Infrastructure & UI
# stow: Symlink farm manager
# hyprland/kitty: Desktop environment and terminal
# zsh: The interactive shell
sudo dnf install stow hyprland kitty zsh -y

# 2. Install Development & Security Tooling
# git-delta: Syntax-highlighting pager
# gnupg2/pinentry-gnome3: Cryptographic signing and secure entry
# python3-pathlib: Required for script-based path manipulations
sudo dnf install git-delta gnupg2 pinentry-gnome3 python3-pathlib -y

# 3. Install SDKMAN! (Software Development Kit Manager)
curl -s "[https://get.sdkman.io](https://get.sdkman.io)" | bash
```

## 🚀 Deployment Workflow

This repository utilizes **GNU Stow** to manage symbolic links across the `$HOME` directory. The deployment is divided into high-priority infrastructure and application-layer configurations.

### 📥 Installation & Synchronization

From the root of the `~/dotfiles` directory, invoke the orchestration to establish the environment:

```Bash
# 1. Establish Identity & Security Infrastructure
# Links global git settings to ~/ and GPG logic to ~/.gnupg
stow -v -t ~/ git
stow -v -t ~/.gnupg gpg

# 2. Inject Modular Shell Settings
# Links .zshrc and shell-specific logic
stow -v -t ~/ zsh

# 3. Synchronize Application Configurations
# Links Hyprland, Kitty, and Starship settings
stow -v -t ~/.config config

# 4. Deploy Logic Layer (Scripts)
# Maps custom wrappers (idea, studio, lagos-shot) to the system PATH
stow -v -t ~/.local/bin scripts

# 5. Load Development Environments
# Links Neovim IDE configuration
stow -v -t ~/.config nvim
```

## ⚙️ Post-Deployment Verification
After symlinking, refresh the environment and verify the cryptographic chain:
- **Shell**: source ~/.zshrc
- **GPG**: gpgconf --kill gpg-agent (Resets the agent with the 12-hour TTL logic)
- **PATH Check**: which idea (Should point to ~/.local/bin/idea)
- **Identity Check**: git config --get user.signingkey (Should return `0D06886B74ED962C`)

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