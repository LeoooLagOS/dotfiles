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

## Applying changes

```bash
hyprctl reload
```

The session runs in Lua mode, so `hyprctl dispatch` expects Lua, e.g.:

```bash
hyprctl dispatch "hl.dsp.window.move({ window = 'class:kitty', workspace = '2', follow = false })"
```
