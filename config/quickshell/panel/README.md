# lagOS Panel

A desktop shell for Hyprland, built with [Quickshell](https://quickshell.org):
a top bar, a tabbed side panel and the notification daemon, in one piece.
Everything is reachable by mouse and set from its own Settings. Nothing needs
a terminal.

> **Status: beta.** It's used every day, but it still lives inside its
> author's dotfiles and expects some of their scripts. A standalone install is
> the goal of **v0.1**. Until then, expect rough edges and settings that
> move.

<!-- Screenshots go here before v0.1: bar, panel (Overview, Media), Settings -->

## What's in it

- **Top bar.** Workspaces with their apps' icons, the focused window's title
  (a browser shows the page, a terminal the git repo), a clock "island" at the
  exact center, readings (CPU, RAM, disk, temperature), network, Bluetooth,
  battery and a tray. The two halves mirror each other.
- **Side panel**, in tabs:
  - **Overview:** clock, weather, calendar, system, notifications, media
  - **Calendar:** month, agenda, new events, to-dos
  - **Notifications:** sort, search, classify, Do Not Disturb
  - **Media:** player with lyrics and a visualizer, internet radio, and a
    local library in full quality through MPD
  - **Weather:** 24-hour chart and a 7-day forecast
  - **Wallpapers:** colors follow the wallpaper
  - **Controls:** Wi-Fi, Bluetooth, sound, brightness, and every setting
- **Notifications.** It *is* the notification daemon. Each kind of notice has
  its own place and card: calls ring, security codes have a Copy button,
  chats are grouped by conversation.
- **Comms dock.** Your messaging and mail apps, one click away.
- **Capture.** Type "dentist friday 5pm" and it becomes an event or a
  reminder.
- **Languages.** English and Spanish. It follows the system's language or the
  one you pick.

Every feature, file and setting is documented in
[docs/REFERENCE.md](docs/REFERENCE.md).

## Requirements

Tested on **Fedora 44** with **Hyprland 0.56** and **Quickshell 0.3.2**.

| Needed | For |
| :-- | :-- |
| Hyprland | the compositor. The panel is Hyprland-first |
| Quickshell ≥ 0.3 | everything (Fedora: COPR `avengemedia/quickshell`) |
| PipeWire, NetworkManager, BlueZ, UPower | sound, network, Bluetooth, battery |
| Python 3 + `icalendar`, `recurring-ical-events` | calendar events |
| a Nerd Font | icons |
| `brightnessctl`, `wl-clipboard` | brightness, copy buttons |

**Optional** (the matching feature hides or degrades without them):
`wallust` (colors from the wallpaper), `cava` (visualizer), `mpd` (local
library), `gpu-screen-recorder` / `grim` / `slurp` (recording, screenshots),
`hyprsunset` (night light).

## Install

Not standalone yet: today the panel is installed by its author's dotfiles
(`install.sh`). The v0.1 guide will cover a clean Fedora install. If you want
to try it now:

```sh
# from this folder, linked as ~/.config/quickshell/panel
qs -c panel                 # run it
qs log -c panel             # its log
```

To start it at login and own the notification name, use the user service
`quickshell-panel.service` (see [Notifications](docs/REFERENCE.md#notifications)).

Open it with `SUPER ALT + N`. Every tab has its own key
([Keyboard](docs/REFERENCE.md#keyboard)).

## Versions

`vMAJOR.MINOR.PATCH`:

- **PATCH** fixes a bug. Nothing else changes.
- **MINOR** adds something or changes what you see by default. Your settings
  are migrated automatically.
- **MAJOR** means you have to change something by hand.

Before 1.0, a MINOR may also break something. When it does, the
[changelog](CHANGELOG.md) says so under **⚠️ Breaking**, along with what to do.

## Contributing

Bug reports, translations and code are welcome. Start with
[CONTRIBUTING.md](CONTRIBUTING.md).

## License

To be chosen before v0.1.
