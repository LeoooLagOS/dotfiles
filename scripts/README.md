# ⚙️ scripts/ — The Logic Layer

Every script the desktop and shell rely on, tracked as discrete modules. `zsh/conf.d/00-env.zsh` puts `wm/`, `ops/` and `lib/` at the front of `PATH`, so they take priority over system binaries.

| Directory | Contents |
|---|---|
| `wm/` | Window manager control engine (below) |
| `lib/` | Python libraries that feed other scripts (below) |
| `ops/` | Maintenance tooling (below) |
| [`build-paper/`](build-paper/README.md) | Markdown → PDF academic build system (`build-paper`) |
| [`lagos-shot/`](lagos-shot/README.md) | Annotated screenshots for Obsidian (`lagos-shot`) |

`build-paper` and `lagos-shot` are linked into `~/.local/bin` by `install.sh`.

## wm/ — Window manager control engine

The scripts behind Hyprland keybinds, Waybar modules and Rofi menus, mostly from [KoolDots](https://github.com/LinuxBeginnings). Hyprland reaches them through `~/.config/hypr/scripts`, a symlink to this directory, so keybinds reference `$HOME/.config/hypr/scripts/<name>`.

| Area | Scripts |
|---|---|
| Launchers & menus | `RofiLauncher.sh`, `RofiCalc.sh`, `RofiEmoji.sh`, `RofiSearch.sh`, `RofiBeats.sh`, `ClipManager.sh`, `KeyHints.sh`, `KeyBinds.sh`, `rofi-ssh-menu.sh` |
| Windows & workspaces | `Dropterminal.sh`, `OverviewToggle.sh`, `toggle-qs-hyprview.sh`, `select-hyprview-layout.sh`, `Lua*.sh` (focus, move, swap, cycle), `ChangeLayout.sh`, `ResizeActive.sh`, `Float-all-Windows.sh`, `Zoom.sh` |
| Hardware & media | `Volume.sh`, `Brightness.sh`, `BrightnessKbd.sh`, `ExternalBrightness.sh`, `MediaCtrl.sh`, `TouchPad.sh`, `AirplaneMode.sh`, `Battery.sh`, `LidSwitch.sh` |
| Theming | `WallpaperSelect.sh`, `WallpaperRandom.sh`, `WallpaperEffects.sh`, `WallustSwww.sh`, `DarkLight.sh`, `ThemeChanger.sh`, `Kitty_themes.sh`, `ChangeStarshipPrompt.sh`, `Animations.sh`, `ChangeBlur.sh` |
| Waybar | `WaybarStyles.sh`, `WaybarLayout.sh`, `WaybarScripts.sh`, `WaybarCava.sh`, `Weather.sh`, `WeatherWrap.sh`, `ToggleWeatherLoc.sh` |
| Session | `LockScreen.sh`, `Wlogout.sh`, `Hypridle.sh`, `Hyprsunset.sh`, `GameMode.sh`, `Refresh.sh`, `ScreenShot.sh`, `Polkit.sh`, `PortalHyprland.sh` |

Upstream ships helpers for other distros (`*NixOS*`, `*Ubuntu*`, `debian-*`); they are kept for parity but unused on Fedora.

## lib/ — Python libraries

| File | Purpose |
|---|---|
| `Weather.py` | Weather from the Open-Meteo API (no API key) as Waybar JSON plus a text cache; run through `wm/WeatherWrap.sh`, which falls back to `wm/Weather.sh` (wttr.in). Location comes from IP, or from `~/.config/lagos/weather-home` when toggled with `ToggleWeatherLoc.sh` |
| `keybinds_parser.py` | Parses Hyprland keybind files given as arguments and prints formatted bindings |

## ops/ — Maintenance tooling

| Command | Alias | What it does |
|---|---|---|
| `sync-dots` | `dots` | Removes editor swap files, stages **tracked files only** (`git add -u`), commits and pushes to `main`. New untracked files are listed for manual review, so nothing private is published by accident |
| `sync-vault` | `vt`, `gerlog`, `dsalog`, `cards` | Commits and pushes one area of the notes vault at `$VAULT_DIR` (`--vtree` also regenerates the vault tree map) |
| `repair-spotify` | `spotify` | Re-applies Spicetify; if that fails, kills the Spotify Flatpak, clears its cache and relaunches it |

## Adding a script

Put it in the directory that matches its role, make it executable, and reference it by its `~/.config/hypr/scripts/` path from keybinds. New shell scripts should pass `shellcheck`.
