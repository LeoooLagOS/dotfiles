# 🚀 lagOS-station: Enterprise-Grade Desktop Infrastructure

[![System](https://img.shields.io/badge/System-Fedora_44-blue?style=for-the-badge&logo=fedora)](https://getfedora.org/)
[![Shell](https://img.shields.io/badge/Shell-Zsh-orange?style=for-the-badge&logo=zsh)](https://www.zsh.org/)
[![Manager](https://img.shields.io/badge/Orchestration-Bash_Bootstrapper-green?style=for-the-badge&logo=gnubash)](install.sh)
[![Specialization](https://img.shields.io/badge/Focus-Cybersecurity_%26_DevOps-red?style=for-the-badge)](https://github.com/LeoooLagOS)
[![Security](https://img.shields.io/badge/Provenance-GPG_Signed-success?style=for-the-badge&logo=gnupg)](https://github.com/LeoooLagOS)

## 🏗️ Architectural Overview

The **lagOS-station** is built on a **Modular Application-Centric** architecture. Unlike standard dotfile repositories that clutter the root directory, this system uses **logical separation** to ensure that each component (Hyprland, Kitty, Shell) remains **environment-agnostic** and easily deployable via a single idempotent bootstrapper (`install.sh`). 

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
│   │   ├── rofi/       # Modular Rofi themes and plugin configurations
│   │   ├── UserConfigs/        # Personal overrides (startup, env, window rules)
│   │   └── monitors.*.example  # Display layout templates (real files are git-ignored)
│   ├── kitty/          # GPU-accelerated terminal configuration
│   ├── fastfetch/      # System info dashboard shown on shell start
│   ├── starship/       # Selectable Starship prompt profiles
│   └── wlogout/        # Glassmorphism logout menu
├── git/                # Global Git provenance: Delta & GPG Signing
├── gpg/                # GPG Environment: Agent logic and TTL cache
│   └── gpg-agent.conf  # Passphrase caching and pinentry rules
├── install.sh          # Idempotent System Bootstrapper (repos, packages, links, shell)
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
│   ├── coprs.txt       # COPR repositories required by the package list
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

- **Screen Sharing & Theming:** Autostarts `xwaylandvideobridge` (hidden via window rule) so X11 apps like Discord and OBS can capture Wayland screens, and themes Qt apps through the `gtk3` platform theme only inside Hyprland, leaving KDE untouched.

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

- `ops/`: Operational tooling for infrastructure maintenance, including vault synchronization and dotfile state management. `sync-dots` commits and pushes changes to **tracked files only** (`git add -u`) and lists any new files for manual review, so nothing private is published by accident.

### 5. System Provisioning (/System)

Adopts an Infrastructure-as-Code (IaC) approach to workstation state management.

- **Declarative Lists:** Tracks system-level dependencies via `pkglist.txt` (DNF), the COPR repositories they come from via `coprs.txt`, and application-layer tools via `flatpaks.txt`.

## 📋 Prerequisites

A fresh **Fedora Workstation** install with `git`, and this repository cloned to `~/dotfiles` (several configs reference that path):

```bash
git clone git@github.com:LeoooLagOS/dotfiles.git ~/dotfiles
```

## 🚀 Deployment Workflow

`install.sh` provisions the whole workstation. Every step is idempotent, so it is safe to re-run after pulling changes.

| Step | What it does |
|---|---|
| `repos` | Enables RPM Fusion, Flathub and the COPRs in `System/coprs.txt` |
| `packages` | Installs `System/pkglist.txt` via DNF (skips live-ISO packages, and NVIDIA drivers when no NVIDIA GPU is present) |
| `flatpaks` | Installs `System/flatpaks.txt` from Flathub |
| `links` | Symlinks configs into `$HOME`; anything already there is moved to `~/.local/state/lagos/backups/<timestamp>/` |
| `local` | Creates machine-specific files from the `*.example` templates and asks for the weather home location |
| `shell` | Installs Oh My Zsh and `pokemon-colorscripts`, and sets zsh as the login shell |

```bash
cd ~/dotfiles

# Preview every change without touching the system
./install.sh --dry-run

# Full provisioning
./install.sh

# Only refresh symlinks and local files (e.g. after pulling)
./install.sh --only links,local

# Unattended, without Flatpaks
./install.sh --yes --skip flatpaks
```

Each run is logged to `~/.local/state/lagos/install-<timestamp>.log`. See `./install.sh --help` for all options.

## 🖥️ Machine-Specific Configuration (Not Tracked)

Some state is personal or hardware-specific, so it lives outside version control. The `local` step of `install.sh` creates it; to do it by hand:

```bash
# 1. Display layout: copy the templates, then edit (or regenerate with nwg-displays)
cd ~/dotfiles/config/hypr
cp monitors.conf.example monitors.conf
cp monitors.lua.example monitors.lua
cp UserConfigs/monitors.lua.example UserConfigs/monitors.lua

# 2. Weather home location (format: City, State, Country)
mkdir -p ~/.config/lagos
echo "City, State, Country" > ~/.config/lagos/weather-home
```

The weather toggle keybind (`ToggleWeatherLoc.sh`) switches between IP-based location and the home location, storing the active choice in `~/.local/state/lagos/weather-place`.

## ⚙️ Post-Deployment Verification

After provisioning, initialize the dynamic keybinds and verify the cryptographic chain:

- **Hyprland Engine:** `hyprctl reload` (Compiles Lua paths into memory)

- **Shell:** source `~/.zshrc`

- **Identity Check:** `git config --get user.signingkey` (Should return 0D06886B74ED962C)

- **Plugin Compilation:** Ensure `rofi-calc` is built using `Meson/Ninja` from the root directory if not bundled via DNF.

## 🕵️ DevSecOps & Best Practices

- **Secret Management:** No raw API keys or private tokens are stored within this repository. Environment variables are injected at runtime via local (Git ignored) files.

- **Privacy by Default:** Location data and hardware identifiers (monitor models and serials) are kept in local, untracked files. `.gitignore` also guards against `*.local` overrides, `.env.*` files, keys, SSH directories and shell histories.

- **Atomic Refactoring:** This repository follows the Conventional Commits standard to maintain a clear audit trail of infrastructure changes.

- **Single Source of Truth:** All bash execution paths are defined internally via Lua abstraction to prevent hardcoded symlink drift.

*Maintained as part of the lagOS-station project, 2026.*