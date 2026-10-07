# 🚀 lagOS-station: Enterprise-Grade Desktop Infrastructure

[![System](https://img.shields.io/badge/System-Fedora_44-blue?style=for-the-badge&logo=fedora)](https://getfedora.org/)
[![Shell](https://img.shields.io/badge/Shell-Zsh-orange?style=for-the-badge&logo=zsh)](https://www.zsh.org/)
[![Manager](https://img.shields.io/badge/Orchestration-Bash_Bootstrapper-green?style=for-the-badge&logo=gnubash)](install.sh)
[![Specialization](https://img.shields.io/badge/Focus-Cybersecurity_%26_DevOps-red?style=for-the-badge)](https://github.com/LeoooLagOS)
[![Security](https://img.shields.io/badge/Provenance-GPG_Signed-success?style=for-the-badge&logo=gnupg)](https://github.com/LeoooLagOS)

The **lagOS-station** is a **Modular Application-Centric** workstation: each component (Hyprland, Kitty, Shell, Neovim) lives in its own directory and is deployed by a single idempotent bootstrapper, `install.sh`.

### Core Philosophy: "Cattle, Not Pets"
Every component is **idempotent**. Package lists, dynamic path resolution and declarative symlinking let the whole environment be reproduced on a clean **Fedora** host in minutes.

---

## 🌳 Repository Map

Each directory documents itself; start from the one you need.

| Directory | Purpose |
|---|---|
| [`config/`](config/README.md) | Application configs linked into `~/.config` (Hyprland, Waybar, SwayNC, Kitty, Quickshell, Starship, Fastfetch, power menu icons) |
| [`git/`](git/README.md) | Global Git identity, Delta pager and GPG signing (also covers `gpg/`) |
| [`nvim/`](nvim/README.md) | LazyVim-based Neovim IDE |
| [`scripts/`](scripts/README.md) | The logic layer: WM control, Python libraries, ops tooling and CLI tools |
| [`System/`](System/README.md) | Declarative package, COPR and Flatpak lists, plus `/etc` files (USB wake, lid behavior) |
| [`zsh/`](zsh/README.md) | Modular zsh shell, aliases and the Sentinel auditor |
| `install.sh` | Idempotent system bootstrapper (see below) |
| `.kooldots-base` | The KoolDots commit the desktop configs are synced to (see [Upstream updates](#-upstream-updates-kooldots)) |

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

`install.sh` doesn't touch `/etc`. The udev and logind files in `System/etc/` are copied by hand; see [`System/`](System/README.md#etc--system-config).

The weather toggle keybind (`ToggleWeatherLoc.sh`) switches between IP-based location and the home location, storing the active choice in `~/.local/state/lagos/weather-place`.

## 🔄 Upstream Updates (KoolDots)

The Hyprland, Waybar, SwayNC, Kitty, wlogout, Fastfetch, Starship and Quickshell configs and `scripts/wm` started as [KoolDots](https://github.com/LinuxBeginnings/Hyprland-Dots) v2.3.26.4 and were restructured here, so this repo shares no git history with upstream. **Do not run KoolDots' own `copy.sh` or upgrade scripts**: they replace `~/.config/hypr` and the other linked directories with fresh copies.

Instead, `kooldots-sync` (in [`scripts/ops`](scripts/README.md#ops--maintenance-tooling)) replays what upstream changed since the commit recorded in `.kooldots-base` as a 3-way merge, remapping upstream paths onto this layout:

```bash
kooldots-sync          # versions and what changed, per directory
kooldots-sync log      # upstream commit messages since the base
kooldots-sync apply    # merge, then resolve conflicts, test and commit
```

See [`config/hypr`](config/hypr/README.md#upstream-updates) for the full workflow. Hyprland itself is a package (`sdegler/hyprland` COPR) and updates with `sudo dnf upgrade`.

## ⚙️ Post-Deployment Verification

- **Hyprland:** `hyprctl reload`
- **Shell:** `source ~/.zshrc`
- **Signing identity:** see [`git/`](git/README.md#verification)

## 🕵️ DevSecOps & Best Practices

- **Secret Management:** No raw API keys or private tokens are stored in this repository. Environment variables are injected at runtime via local, Git-ignored files.
- **Privacy by Default:** Location data and hardware identifiers (monitor models and serials) are kept in local, untracked files. `.gitignore` also guards against `*.local` overrides, `.env.*` files, keys, SSH directories and shell histories.
- **Atomic Refactoring:** Commits follow the Conventional Commits standard to keep a clear audit trail.
- **Single Source of Truth:** Script paths are resolved through the Hyprland Lua layer instead of being hardcoded.

*Maintained as part of the lagOS-station project, 2026.*
