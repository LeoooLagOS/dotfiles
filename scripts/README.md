# ⚙️ scripts/ — The Logic Layer

Every script the desktop and shell rely on, tracked as discrete modules. `zsh/conf.d/00-env.zsh` puts `wm/`, `ops/` and `lib/` at the front of `PATH`, so they take priority over system binaries.

| Directory | Contents |
|---|---|
| `wm/` | Window manager control engine (below) |
| `lib/` | Python libraries that feed other scripts (below) |
| `ops/` | Maintenance tooling (below) |
| [`build-paper/`](build-paper/README.md) | Markdown → PDF academic build system (`build-paper`) |
| [`lagos-shot/`](lagos-shot/README.md) | Annotated screenshots for Obsidian (`lagos-shot`) |
| `providers/` | Task providers for the Quickshell panel (below) |

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
| Session | `LockScreen.sh`, `Wlogout.sh`, `PowerMenu.py`, `Hypridle.sh`, `Hyprsunset.sh`, `GameMode.sh`, `Refresh.sh`, `ScreenShot.sh`, `Polkit.sh`, `PortalHyprland.sh`, `DownloadWatch.py` (a notification with Open / Show in folder when a file lands in `~/Downloads`; browsers keep that inside their window; run by `lagos-downloads.service`), `NotifDemo.sh` (every kind of notification in a row, paced for a video; `-p` pause, `-w` countdown, `-k` kinds), `CommsStartup.sh` (at login: asks the panel to open its Comms dock apps hidden, each in `special:comms-<app>`; SUPER Y shows them above the dock) |

Upstream ships helpers for other distros (`*NixOS*`, `*Ubuntu*`, `debian-*`); they are kept for parity but unused on Fedora.

## lib/ — Python libraries

| File | Purpose |
|---|---|
| `Weather.py` | Weather from the Open-Meteo API (no API key) as Waybar JSON plus a text cache; run through `wm/WeatherWrap.sh`, which falls back to `wm/Weather.sh` (wttr.in). Location comes from IP, or from `~/.config/lagos/weather-home` when toggled with `ToggleWeatherLoc.sh`. The API cache is written atomically (the Quickshell panel watches it) |
| `keybinds_parser.py` | Parses Hyprland keybind files given as arguments and prints formatted bindings |

## ops/ — Maintenance tooling

| Command | Alias | What it does |
|---|---|---|
| `sync-dots` | `dots` | Removes editor swap files, stages **tracked files only** (`git add -u`), commits and pushes to `main`. New untracked files are listed for manual review, so nothing private is published by accident |
| `sync-vault` | `vt`, `gerlog`, `dsalog`, `cards` | Commits and pushes one area of the notes vault at `$VAULT_DIR` (`--vtree` also regenerates the vault tree map) |
| `kooldots-sync` | | Brings [KoolDots](https://github.com/LinuxBeginnings/Hyprland-Dots) updates into this repo as a 3-way merge from the commit in `.kooldots-base`, remapping upstream paths (`config/hypr/scripts` → `wm/`, and so on). `status`, `log`, `diff [path]`, `apply`; see [`config/hypr`](../config/hypr/README.md#upstream-updates) |
| `repair-spotify` | `spotify` | Re-applies Spicetify; if that fails, kills the Spotify Flatpak, clears its cache and relaunches it |

## providers/ — The panel's task providers

Personal data sources for the panel's deadlines, kept here so the panel itself stays generic (the contract: [panel README, Calendar events](../config/quickshell/panel/README.md#calendar-events)). `install.sh` links each into `~/.config/lagos/providers/`.

| Provider | What it gives the panel |
|---|---|
| `vault.py` | The notes vault (`~/Documents/my-cs-notes`): every open `- [ ] … [due:: YYYY-MM-DD]` task outside `82_Templates` (course as its place, a click opens the note in Obsidian, done checks the box in the note), and on a training day the quiet "Gym · <day>" task, which logs the session to `90_Logs/Health/Gym/Gym_Log_<year>.md`. Overrides in `~/.config/lagos/vault.json` (vault path, weekly routine, log folder) |

## Adding a script

Put it in the directory that matches its role, make it executable, and reference it by its `~/.config/hypr/scripts/` path from keybinds. New shell scripts should pass `shellcheck`.
