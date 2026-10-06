# 🐚 zsh/ — Modular Sentinel Shell

A layered zsh setup. `zsh/.zshrc` is linked to `~/.zshrc`; it sources every file in `conf.d/` in name order, then initializes Starship and SDKMAN.

## conf.d/

The numeric prefix sets load order; add new layers with a prefix that places them correctly.

| File | Layer |
|---|---|
| `00-env.zsh` | `PATH` (deduplicated and stacked by priority), language toolchains (FVM/Flutter, Android SDK, Bun, .NET, Go, SDKMAN), `VAULT_DIR`, history |
| `20-security.zsh` | Tightens `~/.ssh` and keychain permissions, loads the SSH key via `keychain`, defines `gpg-refresh` |
| `30-sentinel.zsh` | Defines the `sentinel` auditor (below) |
| `40-plugins.zsh` | Oh My Zsh (`git`, `dnf`), autosuggestions, syntax highlighting, fzf bindings, `~/.zshrc.local`, and the shell-start dashboard |
| `50-maintenance.zsh` | `system_update_sync` (aliased as `update`): previews DNF and Flatpak changes, asks before applying them, then runs `sys-clean` (DNF/Flatpak cleanup, 2-week journal vacuum, thumbnail cache) |
| `90-aliases.zsh` | Aliases (below) |

### PATH priority

`00-env.zsh` puts `scripts/wm`, `scripts/ops` and `scripts/lib` from this repo **first** in `PATH`, ahead of SDKMAN, FVM and system binaries, so repo scripts always win.

## Sentinel auditor

Every interactive shell shows a [Fastfetch](../config/fastfetch/README.md) dashboard followed by `sentinel`, which:

1. enforces `~/.ssh` permissions;
2. checks `libvirtd` and starts it if needed (prompts for `sudo`);
3. reports Python, Java, .NET, Bun and Go versions;
4. shows the Git identity.

## Aliases

| Group | Examples |
|---|---|
| Global pipes | `G` (grep), `L` (less), `B` (bat), `NE` (silence stderr) |
| Listing | `ls`/`l`/`ll`/`la`/`lt` via `lsd`; `rm`, `cp`, `mv` ask before overwriting |
| Git | `st`, `ad`, `aa`, `cm`, `psh`, `pll`, `sync`, `gl`, `gd`, `gds`, `undo`, `unstage` |
| Editors & IDEs | `nv`, `sv`, `idea`, `studio` |
| Notes vault | `vt`/`vsync`, `gerlog`, `dsalog`, `cards` → `scripts/ops/sync-vault` |
| Ops | `update` → `system_update_sync`, `dots` → `scripts/ops/sync-dots`, `spotify` → `scripts/ops/repair-spotify` |

## Local overrides

Machine-specific settings and secrets go in `~/.zshrc.local`, which is sourced if present and never tracked.
