# 🪟 config/hypr — Hyprland WM Core

Hyprland configuration, based on [KoolDots](https://github.com/LinuxBeginnings) and extended with a Lua configuration layer. Linked to `~/.config/hypr`.

## Lua and conf modes

The session runs from the Lua entrypoint, `hyprland.lua`. The `*.conf` files are the upstream conf-mode equivalents and are kept alongside it; when changing a setting that exists in both (e.g. `configs/SystemSettings.conf` and `lua/settings.lua`), update both so the modes don't drift.

`hyprland.lua` loads, in order:

1. `lua/user_defaults.lua` and `lua/animations.lua`
2. `lua/user_overrides.lua`, which loads the **system layer** (`configs/system_*.lua`) and then the **user layer** (`UserConfigs/user_*.lua`), so user files override system ones
3. `lua/monitors.lua` and `lua/workspaces.lua`

The other `lua/*.lua` modules are templates and helpers; they are not loaded directly, or bindings and settings would be registered twice.

## Layout

| Path | Purpose |
|---|---|
| `hyprland.lua` | Lua entrypoint (above) |
| `hyprland.conf` | Conf-mode entrypoint |
| `hl.meta.lua`, `.luarc.json` | Type stubs for the Hyprland Lua API, for editor completion |
| `configs/` | System layer: `system_*.lua` (env, startup, keybinds, rules, settings, laptops) and their `*.conf` twins |
| `lua/` | Loader, helpers (`*_helper.lua`, `keybind_helpers.lua`) and module templates |
| `UserConfigs/` | User layer: personal overrides (`user_*.lua` / `User*.conf`), kept across upstream updates |
| `animations/` | Animation presets; `scripts/Animations.sh` copies the chosen one into `UserConfigs/user_animations.lua` |
| `rofi/` | Rofi launcher configs (`config-*.rasi`) and `themes/` |
| `wallust/` | Wallust templates that recolor Hyprland, Kitty, Ghostty, Rofi, Waybar, SwayNC, nwg-dock, Cava and Quickshell from the wallpaper |
| `Monitor_Profiles/` | Ready-made monitor layouts, selectable with `scripts/MonitorProfiles.sh` |
| `hyprlock*.conf`, `hypridle.conf` | Lock screen (1080p / 2K variants) and idle behavior |
| `scripts`, `UserScripts` | Symlinks to [`scripts/wm`](../../scripts/README.md#wm--window-manager-control-engine) in this repo; `UserScripts` is the upstream path still used by Waybar modules and some keybinds |
| `initial-boot.sh` | First-login setup; writes `.initial_startup_done` when finished |

## Machine-specific files (git-ignored)

| File | Template |
|---|---|
| `monitors.conf` | `monitors.conf.example` |
| `monitors.lua` | `monitors.lua.example` |
| `UserConfigs/monitors.lua` | `UserConfigs/monitors.lua.example` |
| `workspaces.conf`, `UserConfigs/workspaces.lua` | generated at runtime |

The `local` step of `install.sh` creates the monitor files from their templates. Wallust output (`wallust/wallust-hyprland.conf`, Rofi colors) and `wallpaper_effects/` are also ignored.

## Notable customizations

- **Dropdown terminal** (`SUPER SHIFT + Return`): `scripts/Dropterminal.sh` toggles a kitty window with class `kitty-dropterm` on `special:scratchpad`.
- **Overviews:** `SUPER + A` opens the Quickshell workspace overview, `SUPER CTRL + Tab` the window exposé; see [`config/quickshell`](../quickshell/README.md).
- **Screen sharing:** `xwaylandvideobridge` is autostarted so X11 apps (Discord, OBS) can capture Wayland screens. A window rule makes it invisible and parks it on `special:videobridge` so it never covers other windows.
- **Qt theming:** Qt apps use the `gtk3` platform theme inside Hyprland only, leaving KDE untouched.
- **Rofi calculator:** `rofi-calc` with a `qalculate` backend; results are copied with `wl-copy`.

## Upstream updates

This config is a restructured fork of [KoolDots](https://github.com/LinuxBeginnings/Hyprland-Dots) (`Hyprland-Dots` repo), based on the commit in [`.kooldots-base`](../../.kooldots-base) (v2.3.26.4 at the time of writing). The repo shares no git history with upstream, and upstream's `copy.sh` and upgrade scripts would overwrite this layout, so **never run them here**. Use `kooldots-sync` (`scripts/ops`) instead.

It adds a `kooldots` remote (partial clone: no wallpapers or other file contents until a diff needs them), then replays every upstream change since the base as a per-file `git apply --3way`, remapping paths:

| Upstream | Here |
|---|---|
| `config/hypr/scripts/`, `config/hypr/UserScripts/` | `scripts/wm/` |
| `config/hypr/UserScripts/Weather.py` | `scripts/lib/Weather.py` |
| `config/hypr/`, `config/waybar/`, `config/swaync/`, `config/kitty/`, `config/wlogout/`, `config/fastfetch/`, `config/starship/`, `config/quickshell/{overview,qs-hyprview}` | same path |

Workflow, starting from a clean tree (commit first; the merge goes through the index):

```bash
kooldots-sync             # base vs upstream version, files changed per directory
kooldots-sync log         # upstream commits since the base: read these first
kooldots-sync diff config/hypr/configs   # inspect one upstream path
kooldots-sync apply       # merge; advances and stages .kooldots-base
git diff --name-only --diff-filter=U    # files with conflict markers: fix, then git add
git diff --cached         # review everything
hyprctl reload            # test
git commit -m "chore(kooldots): sync to vX.Y.Z"
```

Things to know:

- **Conflicts** appear where you and upstream changed the same lines (keybinds, `hyprland.lua`, hyprlock). Resolve them before running `dots`, which commits tracked files as they are.
- **Deletions are not applied by default.** Upstream often deletes a path because it moved it (e.g. Kitty themes into `UserConfigs/kitty-themes`, Waybar into `hypr/waybar`), and deleting the old copy would break a linked directory. `apply` lists them; remove them with `git rm` once the new location works, or rerun with `--with-deletions`.
- **Lua/conf twins:** if upstream changes only one of a pair, mirror it in the other.
- **Big jumps** can be split: `kooldots-sync --to <commit> apply` syncs to an intermediate commit.
- **Git-ignored files** (`monitors.*`, `workspaces.*`) are never touched.
- To give up on a sync before committing: `git reset --hard HEAD`.

## Applying changes

```bash
hyprctl reload
```

The session runs in Lua mode, so `hyprctl dispatch` expects Lua, e.g.:

```bash
hyprctl dispatch "hl.dsp.window.move({ window = 'class:kitty', workspace = '2', follow = false })"
```
