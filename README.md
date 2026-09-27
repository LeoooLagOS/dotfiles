# 🚀 lagOS-station: Enterprise-Grade Desktop Infrastructure

[![System](https://img.shields.io/badge/System-Fedora_43-blue?style=for-the-badge&logo=fedora)](https://getfedora.org/)
[![Shell](https://img.shields.io/badge/Shell-Zsh-orange?style=for-the-badge&logo=zsh)](https://www.zsh.org/)
[![Manager](https://img.shields.io/badge/Orchestration-GNU_Stow-green?style=for-the-badge)](https://www.gnu.org/software/stow/)
[![Specialization](https://img.shields.io/badge/Focus-Cybersecurity_%26_DevOps-red?style=for-the-badge)](https://github.com/LeoooLagOS)
[![Security](https://img.shields.io/badge/Provenance-GPG_Signed-success?style=for-the-badge&logo=gnupg)](https://github.com/LeoooLagOS)

## 🏗️ Architectural Overview

The **lagOS-station** is built on a **Modular Application-Centric** architecture. Unlike standard dotfile repositories that clutter the root directory, this system uses **logical separation** to ensure that each component (Hyprland, Kitty, Shell) remains **environment-agnostic** and easily deployable via **GNU Stow**. 

Recent infrastructure upgrades have introduced a **Dynamic Lua Abstraction Layer** for window manager configuration, enforcing strict DRY principles and single-source-of-truth pathing across all shell and UI integrations.

### Core Philosophy: "Cattle, Not Pets"
Every component of this workstation is designed to be **idempotent**. By utilizing package lists, dynamic path resolution, and declarative symlinking, the entire engineering environment can be reproduced on a clean **Fedora** host in minutes.

---

## 🌳 Directory Structure

```text
dotfiles/
├── config/             # Application Registry (~/.config)
│   ├── hypr/           # Hyprland WM Core
│   │   ├── configs/    # Base configurations
│   │   ├── lua/        # Dynamic keybind engine and rule parser
│   │   └── rofi/       # Modular Rofi themes and plugin configurations
│   ├── kitty/          # GPU-accelerated terminal configuration
│   └── starship.toml   # Cross-shell prompt customization
├── git/                # Global Git provenance: Delta & GPG Signing
├── gpg/                # GPG Environment: Agent logic and TTL cache
│   └── gpg-agent.conf  # Passphrase caching and pinentry rules
├── install.sh          # Idempotent System Bootstrapper
├── nvim/               # Neovim IDE: LazyVim-based development layer
├── scripts/            # The Logic Layer: Modular orchestration
│   ├── build-paper/    # Academic/Research reporting automation
│   ├── lagos-shot/     # Technical capture and Obsidian injection
│   ├── lib/            # Python core libraries (Weather, Keybinds Parser)
│   ├── ops/            # Operational maintenance (sync-dots, repair)
│   └── wm/             # Unified Window Manager control engine
│       ├── RofiCalc.sh       # Native computational interface (qalc backend)
│       ├── RofiLauncher.sh   # Multi-module application/file launcher
│       └── ...               # All UI/OSD control logic
├── System/             # Infrastructure as Code (IaC) Provisioning
│   ├── flatpaks.txt    # Application-layer dependency list
│   └── pkglist.txt     # DNF system-package registry
└── zsh/                # Modular shell: Senior Aliases and Sentinel logic
```

## 🛠️ Key Engineering Modules
### 1. Hyprland UI & Dynamic Lua Engine (config/hypr/lua)

The Window Manager configuration relies on a custom Lua interpreter to generate keybinds dynamically, eliminating hardcoded paths.

- **Variable Interpolation:** Maps repository-specific paths (e.g., `$scriptsDir`) directly to execution commands, ensuring dotfiles remain portable across environments.

- **Rofi Modularity:** Integrates an advanced application launcher with extensible modules (drun, filebrowser, window, calc).

- **Computational Interface:** Features a native integration with `rofi-calc` and `qalculate`, allowing instant mathematical operations and automatic clipboard piping via `wl-copy` directly from the OS overlay.

### 2. Global Git Provenance (/git)

The version control layer is optimized for high-velocity code review and cryptographic security.

- **Delta Pager:** Implements a high-performance, syntax-highlighting pager for all git, diff, and grep outputs, providing an IDE-like experience in the terminal.

- **zdiff3 Conflict Resolution:** Uses the *"Common Ancestor" merge style* to provide the baseline context during logic conflicts.

- **Cryptographic Identity:** Enforces GPG-signed commits for all infrastructure changes to ensure non-repudiation and verified status on remote repositories.

### 3. The Modular Sentinel Shell (/zsh)

A modular, plugin-based shell environment designed for deterministic initialization.

Componentized Logic (`conf.d/`):
- `00-env.zsh`: Infrastructure variables and SDKMAN initialization.

- `20-security.zsh`: GPG agent orchestration and environment hardening.

- `30-sentinel.zsh`: Custom shell-based telemetry and status monitors.

### 4. The Logic Layer (`/scripts`)

All application wrappers and custom research tools are managed as discrete, tracked modules in `~/dotfiles/scripts`.

- `wm/`: The consolidated control engine. Unifies notification management, brightness, clipboard interfaces, and UI menus.

- `lib/`: A library of deterministic Python modules that provide data for shell utilities, ensuring robust exception handling.

- `ops/`: Operational tooling for infrastructure maintenance, including vault synchronization and dotfile state management.

### 5. System Provisioning (/System)

Adopts an Infrastructure-as-Code (IaC) approach to workstation state management.

- **Declarative Lists:** Tracks system-level dependencies via `pkglist.txt` (DNF) and application-layer tools via `flatpaks.txt`.

## 📋 Prerequisites

Before deploying, ensure the core system engine, window manager, terminal emulator, and Rofi plugins are installed. On Fedora, provision via DNF:
Code snippet

```bash
# 1. Install Core Infrastructure & UI
# stow: Symlink farm manager | hyprland/kitty: Desktop environment and terminal
sudo dnf install stow hyprland kitty zsh -y

# 2. Install Development & Security Tooling
# git-delta: Syntax-highlighting pager | gnupg2: Cryptographic signing
sudo dnf install git-delta gnupg2 pinentry-gnome3 python3-pathlib -y

# 3. Install Rofi-Wayland & Computational Dependencies
# Required for native launcher modules and RofiCalc.sh
sudo dnf install rofi-wayland wl-clipboard qalc libqalculate-devel meson ninja-build -y
```

## 🚀 Deployment Workflow

This repository utilizes **GNU Stow** to manage symbolic links across the `$HOME` directory.

### 📥 Installation & Synchronization

From the root of the `~/dotfiles` directory, invoke the orchestration to establish the environment:

```bash
# 1. Establish Identity & Security Infrastructure
stow -v -t ~/ git
stow -v -t ~/.gnupg gpg

# 2. Inject Modular Shell Settings
stow -v -t ~/ zsh

# 3. Synchronize Application Configurations
stow -v -t ~/.config config

# 4. Deploy Logic Layer (Scripts)
stow -v -t ~/.local/bin scripts

# 5. Load Development Environments
stow -v -t ~/.config nvim
```

## ⚙️ Post-Deployment Verification

After symlinking, initialize the dynamic keybinds and verify the cryptographic chain:

- **Hyprland Engine:** `hyprctl reload` (Compiles Lua paths into memory)

- **Shell:** source `~/.zshrc`

- **Identity Check:** `git config --get user.signingkey` (Should return 0D06886B74ED962C)

- **Plugin Compilation:** Ensure `rofi-calc` is built using `Meson/Ninja` from the root directory if not bundled via DNF.

## 🕵️ DevSecOps & Best Practices

- **Secret Management:** No raw API keys or private tokens are stored within this repository. Environment variables are injected at runtime via local (Git ignored) files.

- **Atomic Refactoring:** This repository follows the Conventional Commits standard to maintain a clear audit trail of infrastructure changes.

- **Single Source of Truth:** All bash execution paths are defined internally via Lua abstraction to prevent hardcoded symlink drift.

*Maintained as part of the lagOS-station project, 2026.*