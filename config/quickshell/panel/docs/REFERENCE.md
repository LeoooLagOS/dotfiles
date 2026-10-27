# Panel reference

A modular panel built from **zones** and organised in **tabs**:

| Tab | Zones |
|---|---|
| Overview | weather + clock · profile (centered under the Overview tab, click → Controls) · notifications — calendar with events · system stats (click → Controls), media (compact) |
| Calendar | month grid · agenda (selected day + next 7 days, refresh, **new event** form) · to-do list (tasks and ideas) |
| Notifications | toolbar: Classify (critical / messages / system / other / per app) · Search · Sort (newest, oldest, app, urgency) · Do Not Disturb · Clear; list centered at 50% width |
| Media | corner buttons: library · radio · player views; large art, track info, volume (the app's own stream and the system's, two vertical sliders), audio-output picker and lyrics (lines + note icon: the song's lyrics where the title was, the line being sung highlighted, click a line to jump there; the title moves up, small) buttons, controls, cava visualizer as seekable progress, player picker (only the current players: playing, or paused after playing this session, or picked; an old pause, like an MPD queue left paused, only when nothing else is: `Media.players` vs `Media.all`, ADR-0011; the chosen chip, the art or the title clicked again open the player's app, `Media.goTo`); a corner button switches to the **radio** view (same layout: station logo, station chips, what's on air, previous / play-stop / next station, listening time; 🔍 finds stations by name or frequency in radio-browser.info, Mexico only by default, to listen or save, and lists yours to remove; a record button under volume / output saves the stream to `~/Recordings/Radio_<Station>_<date>`); a third view, **library**, plays `~/Music` through MPD in full quality: quality chips (format "FLAC 24/96", Hi-Res, Bit-perfect or "Resampled 96 → 48 kHz"), and 🔍 opens an album browser (covers, filter, an album's tracks: Play, Queue, a track) |
| Weather | 24-hour temperature chart (curve, icons, rain %, sunrise/sunset) + compact hourly strip · current conditions with sunrise/sunset and six detail tiles + 7-day forecast |
| Wallpapers | thumbnail grid of `~/Pictures/wallpapers` with folder filter; click to apply |
| Controls | identity bar (⚙ settings · lock · power) · 9 quick toggles · output / microphone / brightness · detail pane (System + power profile, or a toggle's detail) — ⚙ opens **Settings** (see [Controls and Settings](#controls-and-settings)) |

It opens on the **focused monitor**, sized from that screen's usable area
(screen minus waybar/reserved space): **50% of the width**, centered (25% free
on each side), and **50% of the height**, just below the bar. Colors follow
the wallpaper (wallust), like waybar and swaync.

| | |
|---|---|
| Toggle | `SUPER ALT + N` or `SUPER CTRL SHIFT + N` → `scripts/wm/PanelToggle.sh` |
| One key per tab | `SUPER SHIFT +` **N** Notifications · **M** Media · **T** Weather (*tiempo*) · **V** Overview · **D** Calendar (*días*) · **P** Wallpapers (*papel tapiz*) · **C** Controls → `PanelToggle.sh <Tab>`: opens on that tab, or closes the panel if that tab is already shown. The waybar bell opens Notifications; right-click it for Do Not Disturb |
| IPC | `qs -c panel ipc call panel toggle` (also `open`, `close`, `tab <Name>`, `currentTab`, `toggleDnd`, `clearNotifications`, `zone <Tab> <ZoneName>` (open a tab with that zone highlighted), `settings [section]`, `setting <key> <json>` (e.g. `setting dim 600`), `themeMode light\|dark\|system`, `toggleInverted`, `currentTheme`, `record`, `radio`, `tabToggle <Name>` (open on a tab, or close if it's the one shown)) |
| Keys | full keyboard control — see [Keyboard](#keyboard) |
| Autostart | user service `quickshell-panel.service` (`config/systemd/user/`), see [Notifications](#notifications) |
| Blur | layer rules `quickshell:panel` (card) and `quickshell:panel-dim` (screen) in `config/hypr/UserConfigs/user_layer_rules.lua` |
| Closing | the keybind, `Esc`, or a click outside the card. Only the card takes input: outside it you can keep using other windows. The screen is dimmed while the pointer is over the card. Outside clicks are seen through a non-consuming `mouse:272` bind added with `hyprctl eval` only while the panel is open (`services/PanelState.qml`). Except while picking a screenshot region: clicks don't close it while a `slurp` (layer `selection`) or `hyprpicker` layer is open, so the panel itself can be captured |
| Logs | `qs log -c panel` |

QML edits reload live. Full restart: `systemctl --user restart quickshell-panel`; logs also in `journalctl --user -u quickshell-panel`.

---

## Bar

The top bar (`TopBar.qml`, `bar/`, `services/BarState.qml`) replaces waybar.
Islands style by default: each group floats like the panel's cards (blurred),
and the island at the center is the only solid, near-black piece.

| Zone | Modules |
|---|---|
| Left | distro logo, alone like a start button (click: system menu `scripts/wm/RofiSystemMenu.sh`, Win+X style · right click: Settings → Bar) · tray (a chevron) · workspaces with the icons of their apps (click, wheel) · the focused window's app and title with the mini weather, or on an empty workspace the whole weather |
| Center | notifications (bell · click: the Notifications tab · right click: Do Not Disturb) · **island** · caffeine |
| Right | the reminder, else the music, else the next event (the window title's twin) · CPU, RAM, disk, temperature (click: system monitor) · Wi-Fi, Bluetooth, battery (click: system popup) · power menu |

- **The details** (`TopBar.qml`): the window title fills from the workspaces toward the center and its twin from the readings, up to a gap before the bell / caffeine that is the same on both sides (Settings → Bar → Gap to the center). Text that doesn't fit scrolls (`bar/Marquee.qml`; hovering holds it). Each keeps its width (what it shows is centered while shorter). Both halves of the bar always measure the same: the narrower side's workspaces or readings card widens to the other's width (the workspaces then share the extra, spreading over the whole card), so the twins are the same width too. The twins come and go together: both hide while the panel is open on their monitor, while the island is open (grown with the player or the weather, or a message hovered), or while the left one has nothing yet (an empty workspace before the weather loads). **Then the bar is mirrored**: the two sides measure the same to the pixel, and the workspaces keep the size they had with the island closed (their cap is held). The readings show their numbers only if they fit in that width (`details.compactReadings`, from each reading's `StatItem.fullWidth`, its width with the number whether shown or not), else their icons alone, and the readings card widens to the workspaces' width; with the panel open they always show icons alone. **Left twin**: a call · the player, while a reminder has the right twin · the window title · on an empty workspace, the whole weather (`bar/Glance.qml`: temperature, sky, high / low, rain, place; click: the Weather tab). Except for the whole weather, the weather sits in a small pill at its inner edge (`bar/MiniWeather.qml`). The window title leaves out what wouldn't fit to read: in a git repository only the repo's details, and no title scrolling in a sliver (under 80 px); then it takes only its own width and the mini weather the rest, showing what fits whole (high / low, rain, sky, place). A call or the player in the left twin does the same whenever its text fits: the card is as wide as its content (`Glance.natural`, `details.glanceCompact`) and the mini weather takes the rest; a title too long for that keeps the whole room and scrolls. The player's text is `bar/TrackRoll.qml` (both twins): title · artist · album side by side as far as they fit in the twin's room (`Glance.room`), the rest rolling like the island's date: title 5 s → artist 3 s → album 3 s, or title · artist 5 s → album 3 s; as wide as its widest page, a page that scrolls holds for its whole turn, hover holds it, a new track starts on the title. **Right twin** (`bar/Agenda.qml`): the reminder (`Events.soon`: what's due within a few hours, overdue, an event about to start), tinted by its urgency (the player then goes to the left twin) · else the whole twin for the player while something plays (`Media.active`, still true 20 s after a pause: art, then title · artist · album, `bar/TrackRoll.qml`; click: the Media tab · middle click: play / pause; skipped while the island grown shows the player) · else the next event (the calendar's next 7 days, "Meeting · 16:00 · in 2 h", "now · until 17:00", all-day ones as "today"), else the first open to-do, else that the week is free (click: the Calendar tab).
- **A call** (`services/Call.qml`, `scripts/call.py`, `bar/CallButtons.qml`): while a Meet window (title "Meet - abc-defg-hij") or a Teams meeting / call is open, the left twin shows it ("Meet · kai-rxpp-mqx", more room) with a microphone and a camera button, red while off; a click elsewhere on it goes to the call's window. Left twin order: call · player (with a reminder on the right) · window title · (empty workspace) the whole weather. Both buttons send the app's own shortcut to its window (Meet Ctrl+D / Ctrl+E, Teams Ctrl+Shift+M / Ctrl+Shift+O), so the call shows the same. Their state (`scripts/call.py`, every 1.5 s): the app's own buttons read through accessibility (AT-SPI) when it is on — exact, also for what's switched inside the call; without it the camera is "on" while the program has `/dev/video*` open, and the microphone is as last switched from the bar (a muted call keeps recording, so a mute done inside the call can't be seen). IPC `call` prints the state. The weather keeps its mini pill beside it, as with a window.
- **Window title** (`bar/WindowTitle.qml`): the app's icon and name, then the title (left out under 80 px). For a browser, the page: the site's domain and icon, and the site's name dropped from the title. For a terminal in a git repository (`scripts/gitstatus.sh`: the tab typed in last): only the repo, branch and what's pending (↑ ahead ↓ behind · + staged · ~ modified · ? new · ! conflicts, ✓ clean).
- **Browser pages** (`services/WebPages.qml`, `scripts/weburl.py`): any browser, native or Flatpak. Firefox family (Firefox, LibreWolf, Zen, Floorp, Waterfox): the session's open tabs, else the history; Chromium family (Brave, Chrome, Chromium, Vivaldi, Edge, Opera): the history, any profile. Icons from the browser's favicons, cached in `~/.cache/quickshell-panel/favicons`. The workspaces show the site's icon instead of the browser's; the browser's stays for searches (Google, Bing, DuckDuckGo, Brave Search…), sites without an icon and its own pages. A page just opened can take 5–15 s (the browser saves it).
- **Bell**: as wide as an icon (the gaps stay even): in the accent while there are notifications; a new one shows the count instead for a second, and while there are some so does every few seconds (Settings → Bar → Notifications bell: on/off, every 3 s – 1 min, for 0.5 – 3 s; default every 5 s for 1 s).
- **Icons** are centered by their ink (`Glyph { optical: true }`): Nerd Font glyphs sit off-center in their box.
- **Island** (`bar/Island.qml`): day · time · date, mirrored like the bar around the time's colon, which sits on the screen's center: "Tue 23:20 13" and "13 23:20 Oct", both sides rolling up together every 6 s (a slow fade and slide, `rollOut` / `rollIn`) so each stays about three characters. The hours and minutes boxes share one width, and so do the two side boxes (as wide as the widest of the day, day of the month and month, so the pill doesn't change size as it rolls) (without the date, just the time); while a player plays and no twin shows it (`playerShown`: a twin usually does), its art and an equalizer around them, so normally the pill, and the twins' room, stay the same when music starts or stops; hovering it while something plays (`Media.active`) grows it down: big art on the left; on the right the titles, a cava visualizer that doubles as the seekable progress, and shuffle · previous · play · next · loop (the small art and equalizer leave the top row); otherwise the weather: the sky's icon, temperature and sky, place and feels-like, the chance of rain in the next six hours, high / low, humidity and wind (click: the Weather tab); recording shows a red dot and the time (click stops it); short messages for Do Not Disturb, caffeine, volume; **levels** placed on the island (Settings → Notifications → Where popups appear → "Island (bar)", for any kind but calls and security codes; brightness by default): icon · title · bar · percentage, the bar sliding from the last value, progress updating in place until its app closes it, other kinds shown like a message (`BarState.showLevel` / `showMessage`; top center while the island isn't on the bar). Click: the panel · wheel: output volume. It doesn't grow while the panel is open (it would open behind it), and stays grown while a screenshot region is picked (slurp covers it; `PanelState.capturing`).
- **Messages on the island** (Settings → Bar → Island, on by default): chat messages (not mail) go to the island instead of a popup (`Notifs.arrive` → `BarState.showMessage`): the chat's photo with the app's icon, who and the text, for 6 s; the same chat again counts up. Hovering holds it and shows the whole text with Reply (dock apps, `Comms.startReply`) and Open (the chat; its messages leave the history). Do Not Disturb keeps them quiet as usual.
- **Panel open**: the bar's strip is dimmed and blurred like the rest of the screen, around and behind its groups (the panel's dim layer stays out of the reserved strip, so the bar draws the same backdrop).
- **Readings**: neutral while normal, amber / red past CPU/RAM 80 %, disk 90 %, temperature 80 °C (with a solid pill when the wallpaper's palette has that hue: Settings → Appearance → Warnings). Hovering one shows its details and the last minute (`bar/BarTip.qml`; `SystemStats` polls every 2 s while the bar shows a reading).
- **Startup apps** (`services/Startup.qml`, `scripts/startup.py`; Settings → Startup apps and the tray's Startup view): what starts at login, from two places. XDG autostart (`~/.config/autostart` over `/etc/xdg/autostart`, run by uwsm as `app-<id>@autostart.service`; entries for other desktops or not installed aren't listed): off writes `Hidden=true` in your copy (made from the system's when there is none; on again removes a copy left equal to the system's), then `systemctl --user daemon-reload`. Hyprland's `startup_commands` in `UserConfigs/user_startup.lua`: off comments the line out (Hyprland reloads its config; the panel's own line can't be turned off). Off takes effect from the next login; ■ / × stops it now (its unit, its Flatpak, or its processes by name), ▶ starts it (its unit, else `systemd-run --user`, so it outlives the panel). Memory: anon + shmem + kernel of its cgroup (the page cache doesn't count), a Flatpak's scopes, or the RSS of what was started some other way. Read every 4 s while one of the two is open.
- **System monitor** (`bar/SystemMonitor.qml`, data from `scripts/sysmon.py` while it's open, every 1.5 s): click the readings. Compact, btop-like. Left: CPU (usage, temperature, frequency, cores · threads · busy) and network (rates, last minute). Right, a big block: memory (used · cache, swap) and storage (disks, I/O); clicking CPU or network shows its detail there instead: every thread (usage, frequency, last minute) and per-core temperatures, or each interface (address, rates, traffic since boot); × or Esc goes back. Below, processes with filter and sort (CPU, memory, name), CPU as a share of the whole machine; end one with × twice (Shift: kill -9). A button opens btop in kitty.
- **Tray** (`bar/TrayModule.qml`): a chevron next to the distro logo that drops four views: **Tray** (the apps' tray icons: click, right click for the menu, middle click), **Apps** (every program with a window, grouped, hidden ones marked, plus Flatpak apps running without one: click goes there, × closes / stops it, asking twice), **Startup** (what starts at login, running or not, with the memory it holds — the ones without a tray icon too: click opens it through its tray icon, its window or its launcher, or starts it; ▶ starts, × stops asking twice; the switch: at login or not) and **Services** (your systemd user services: restart, stop asking twice; the system's, read only). Its footer opens the system monitor for processes.
- **System popup** (`bar/SystemPopup.qml`): click the network, Bluetooth or battery.
- The popups (system popup, monitor, tray list) close on a click outside, but not while a screenshot region is picked: slurp takes the focus and they would vanish before the capture (`bar/PopupGrab.qml`, `PanelState.capturing`). Who and uptime, lock / power / settings, the four readings with bars, volume and brightness, tiles (Wi-Fi, Bluetooth, output, microphone, night light, dark mode; › opens the detail in Controls). Closes on a click outside or Esc.
- **Settings → Bar**: use this bar or waybar, style (islands · full bar · floating), height, accent (Auto or a wallust color), gap to the center, modules per zone, empty workspaces, app icons, date, 24-hour clock.
- **Which bar**: `~/.config/lagos/bar` (`quickshell` | `waybar`), written by `scripts/wm/BarSwitch.sh`; `WaybarStartup.sh` and `Refresh.sh` don't start waybar unless it says `waybar`. SUPER CTRL ALT B (IPC `barToggle`) hides / shows the bar for now.
- Layer `quickshell:bar` is taller than the bar (the island and details draw below it); only the groups take input (mask) and only the bar's height is reserved. Blur: layer rules `quickshell:bar` and `quickshell:bar-popup`, following the panel's blur switch.

## Keyboard

The panel works without a mouse. Open it with `SUPER ALT + N` (Overview) or
`SUPER SHIFT + N / M / T / V / D / P / C` (a tab); the keyboard goes to the panel while it is open.

`SUPER Z` quick capture (a to-do or an event in plain words) · `SUPER SHIFT Z` from the selected text. `SUPER O`: the focused window out to the next empty workspace, following it (from a comms app too: a Meet call opened from a WhatsApp link lands there; `UserConfigs/user_keybinds.lua`).

| Keys | Action |
|---|---|
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | next / previous tab |
| `Ctrl+1` … `Ctrl+7` | jump to a tab (Notifications, Media, Weather, Overview, Calendar, Wallpapers, Controls) |
| `Tab` / `Shift+Tab` | move between controls (a ring shows the focused one) |
| `Enter` / `Space` | press the focused button, chip, tile or card |
| `Esc` | close the open menu / popover / form / expanded list, else the panel |
| **Media tab** (no control focused) | `Space` play/pause · `←` `→` previous/next track |
| Sliders | `←` `→` ±5% · `Home` / `End` |
| Dropdowns | `Enter` open · `↑` `↓` choose · `Enter` pick · `Esc` close |
| Volume popover | `↑` `↓` ±5% · `M` mute |
| Output popover | `↑` `↓` move · `Enter` pick |
| Calendar grid | arrows move the day (±1 / ±7) · `PgUp` / `PgDn` month · `Home` today |
| Wallpapers grid | arrows move · `Enter` applies |
| Notification card | `Enter` default action · `Delete` / `Backspace` dismiss |
| To-do row | `Space` complete · `Enter` edit · `Delete` remove |
| Wi-Fi / Bluetooth row | `Enter` connect / disconnect; on the tile `→` opens settings |
| Search / text fields | `Esc` clears, a second `Esc` closes the panel |

For new zones: `Chip` and `IconButton` are keyboard-ready; any other
clickable item needs `activeFocusOnTab: true`, `Keys.onReturnPressed` and a
`FocusRing {}` child.

---

## Layout

```
panel/
├── shell.qml              entry point + IPC handler
├── Panel.qml              per-monitor layers (click-through dim + card), tab bar
├── NotificationPopups.qml notification popups (top center of the focused monitor)
├── TabPage.qml            builds a tab from its rows in Config
├── Cell.qml               one grid cell: stacked zones or a nested row of cells
├── common/
│   ├── Config.qml         ← tabs, their grid of zones, sizes, commands
│   ├── Settings.qml       user settings (JSON) + the schema the Settings view is built from
│   ├── Theme.qml          colors (wallust, four modes), radii, fonts
│   ├── Zone.qml           card container every zone uses
│   ├── WeatherIcons.qml   WMO code → icon / description
│   ├── NotificationCard.qml  one notification (popups and the Notifications tab)
│   ├── Dropdown.qml       pill button with an option list
│   ├── TextField.qml      rounded text input
│   ├── EventForm.qml      new local event form
│   ├── QuickTile, Segmented, Switch, ValueSlider   Controls / Settings building blocks
│   ├── Label, Glyph, IconButton, Bar, SliderRow, StatRow, ToggleTile
│   └── qmldir
├── services/              data sources (singletons), shared by zones
│   ├── PanelState.qml     open/closed, current tab, Controls view / detail / Settings section
│   ├── Profile.qml        full name, user@host, distro + logo, WM
│   ├── Audio.qml          default output/input, device lists, short device names
│   ├── Toggles.qml        night light, caffeine, airplane mode, game mode
│   ├── SystemSettings.qml applies system settings (hypridle, battery alerts, login power profile, wallpaper rotation) + About info
│   ├── SystemStats.qml    runs scripts/sysstats.sh (2 s while open, 60 s closed)
│   ├── Weather.qml        runs waybar's Weather.py + reads its Open-Meteo cache
│   ├── Events.qml         scripts/events.py: month on screen, next 7 days, reminders, add/remove
│   ├── Todos.qml          to-do list in ~/.config/lagos/todo.json
│   ├── Forecast.qml       runs scripts/forecast.py (hourly + 7-day)
│   ├── Media.qml          MPRIS players, the one shown, progress, audio outputs
│   ├── Cava.qml           audio visualizer bars (runs cava only while shown)
│   ├── Wallpapers.qml     runs scripts/wallpapers.py; applies via WallpaperSelect.sh
│   ├── Brightness.qml     brightnessctl
│   ├── Notifs.qml         notification daemon: history, popups, DND, waybar state
│   └── qmldir
├── zones/                 one file per zone
│   ├── NowZone.qml          weather (temp, low/high, wind, AQI, visibility, pressure) + clock with rotating facts
│   ├── NotificationsZone.qml  count badge, latest as a card; ⌄ expands it over the column (Panel.qml)
│   ├── NotificationListZone.qml  full list grouped by app
│   ├── ProfileZone.qml      avatar, full name, user@host, distro, uptime (click → Controls)
│   ├── CalendarZone.qml     month grid + selected day: to hand in, events not over (props: showDayEvents)
│   ├── AgendaZone.qml       selected day + next 7 days, new-event form, refresh
│   ├── TodoZone.qml         Teams / providers' tasks to hand in, tasks and ideas
│   ├── SystemZone.qml       CPU, memory, temp, disk, battery (+ power profile in Controls)
│   ├── MediaMiniZone.qml    compact player: big art, title, 5 buttons, progress
│   ├── MediaZone.qml        full player
│   ├── TemperatureChartZone.qml   24-hour chart (Canvas)
│   ├── WeatherCurrentZone.qml / HourlyForecastZone.qml / DailyForecastZone.qml
│   ├── WallpapersZone.qml
│   ├── WifiZone.qml / BluetoothZone.qml   (Controls detail panes)
│   ├── SlidersZone.qml      output, microphone, brightness, with their devices
│   ├── ControlCenter.qml    the whole Controls tab (see Controls and Settings)
│   └── controls/            its parts: IdentityBar, SettingsView + SettingRow,
│                            DeviceList and the detail panes (*Detail.qml); has a qmldir
└── scripts/
    ├── sysstats.sh        CPU, memory, temp, disk, battery, uptime as JSON
    ├── events.py          calendar events as JSON (needs the venv, see below)
    ├── forecast.py        Open-Meteo hourly/daily forecast (cached 30 min)
    ├── cava.conf          cava in raw mode (PulseAudio input) for services/Cava.qml
    ├── dndmute.py         mutes the comms apps' own sounds during Do Not Disturb (services/Comms.qml)
    └── wallpapers.py      wallpaper list + background thumbnail generation
```

Zones only **display** data; services **fetch** it. A zone that needs new data
gets a new service (or a `Process` inside the zone if nothing else needs it).

---

## Editing the layout

Everything is in `common/Config.qml`. Each tab is a list of **rows**; a row
has **cells**; a cell either stacks **zones** or splits into a nested row of
cells (so any grid can be described):

```qml
{
    name: "Overview", icon: "\uf009",
    rows: [
        { height: 0.25, cells: [
            { width: 0.66, cells: [                       // nested row
                { width: 0.58, zones: ["NowZone"] },
                { width: 0.42, zones: ["ProfileZone"] }
            ] },
            { width: 0.34, zones: ["NotificationsZone"] }
        ] },
        { height: 0.75, cells: [
            { width: 0.66, zones: ["CalendarZone"] },
            { width: 0.34, zones: ["SystemZone", "MediaMiniZone"] }   // stacked
        ] }
    ]
}
```

- `height` / `width` are fractions of the tab / row (they should add up to 1).
- Zones in a cell stack top → bottom; the **last one fills** the leftover height,
  unless entries give their share: `zones: [{ zone: "A", height: 0.6 }, { zone: "B", height: 0.4 }]`.
- `props` sets properties on a zone: `{ zone: "CalendarZone", props: { showDayEvents: false } }`.
- `link` makes a zone a shortcut: `{ zone: "SystemZone", link: "Controls" }` opens
  Controls on click, where the same zone pulses in the accent color and takes
  keyboard focus (`PanelState.goTo`, `Zone.flash()`). Overview's Profile and
  System use it.
- **Add a tab**: add an entry with `name`, `icon` (Nerd Font glyph) and `rows`.
- **Move a zone**: move its name to another cell or tab.
- **Resize the panel**: Settings → Panel → Size (`widthFraction` / `heightFraction`
  in Config read it).
- A zone that uses another zone *as a type* (not through Config) must load it
  by path with a `Loader`, like `Cell.qml` does: Quickshell only resolves types
  from directories that have a `qmldir` (`common/`, `services/`, `zones/controls/`).

### Adding a zone

Create `zones/<Name>Zone.qml` and put `"<Name>Zone"` in a cell. Example:

```qml
import QtQuick
import QtQuick.Layouts
import "../common"
import "../services"

// ZONE: Hello — what this zone shows
Zone {
    title: "Hello"          // optional header (omit for no header)
    icon: ""          // optional Nerd Font glyph
    // centered: true       // center content vertically (zones without header)
    // clickable: true; onClicked: …   // make the whole card clickable

    RowLayout {
        width: parent.width
        Label { text: "Uptime: " + SystemStats.uptime; Layout.fillWidth: true }
        IconButton { icon: ""; onClicked: console.log("clicked") }
    }
}
```

A zone that should use all the height it is given (like the calendar) sets
its content's `height: root.height - 2 * Theme.zonePadding` (with `id: root`
on the Zone).

Building blocks from `common/`:

| Component | Use |
|---|---|
| `Zone` | Card with optional `title`/`icon` (or `badge`) header; `actions: [...]` (header buttons), `centered`, `clickable` |
| `Dropdown` | Pill that opens an option list: `options: [{label, value}]`, `value`, `onSelected` |
| `Label` | Text in the panel font; `dim: true` for secondary text |
| `Glyph` | Nerd Font icon — `text: ""` ([cheat sheet](https://www.nerdfonts.com/cheat-sheet)); codepoints above FFFF use `"\u{f059d}"` |
| `IconButton` | Rounded icon button; `active: true` fills it with the accent |
| `Bar` | Thin progress bar, `value` 0..1 (animates only when the value changes) |
| `StatRow` | Icon + label + value + `Bar` (`ratio`); `warn` turns the value red |
| `SliderRow` | Icon + draggable slider, `value` 0..1, `onMoved: v => …` |
| `ToggleTile` | Quick-settings tile: `icon`, `label`, `status`, `active`; `onToggled`, `onSettingsClicked` |

Tips:

- Write icons as `"\uXXXX"` escapes with an editor; shell heredocs may turn
  them into raw glyphs (they still work, but are hard to read).
- Declare frequently updated rows statically (like `SystemZone`): a
  `Repeater` over an array rebuilt on every update recreates its delegates,
  which resets their animations.
- Prefer plain positioners (`Row`, `Column`, `Grid`) with explicit sizes when
  a size depends on the parent's height — `*Layout` types can create binding
  loops there (see `CalendarZone`).
- Running a command: `Quickshell.execDetached(["bash", "-c", "kitty"])`.
  For command output, use a `Process` with a `StdioCollector`
  (see `services/SystemStats.qml`).

---

## Calendar events

`scripts/events.py` (run in a private venv, see below):

```sh
events.py list FROM TO [--force]   # events between two dates; --force skips the Outlook cache
events.py add                      # new local event, JSON on stdin
events.py delete UID               # delete a local event
```

Sources:

1. **Evolution webcal subscriptions** (`~/.config/evolution/sources/*.source`) —
   the published Outlook (BUAP) calendar. The URL is read from Evolution at
   runtime (never stored in this repo); the `.ics` is cached in
   `~/.cache/quickshell-panel/` (mode 600) for 15 minutes. Read-only: changes
   made in Outlook (phone, web) show up once Microsoft republishes the feed
   (minutes to a couple of hours) plus the cache; the agenda's refresh button
   forces a download. Offline, the last copy is used.
2. **Calendar feeds** in `~/.config/lagos/calendar-feeds` (mode 600, outside
   the repo), one per line: `Name | https://…/basic.ics [| reminder minutes]`
   — e.g. each Google calendar's *Secret address in iCal format* (Settings →
   the calendar → Integrate calendar). Cached and refreshed like the webcal
   ones; reminder: the event's VALARM, else the line's minutes (default 10).
   Thunderbird's CalDAV calendars can't be read instead: it keeps no local
   copy of them.
3. **Local `.ics` files** in `~/.config/lagos/calendars/`. Events created from
   the panel go to `panel.ics` there (stored in UTC, with a VALARM for the
   chosen reminder) and can be deleted from the agenda.
4. **Teams assignments** (`scripts/assignments.py`, run by `services/Events.qml`
   on every refresh): `~/.config/lagos/calendars/Teams.ics`, one event
   "Entrega: <assignment>" at its due time with a reminder a day before.
   Two sources: Microsoft Graph's education API once signed in
   (`assignments.py login`, device code, read-only `EduAssignments.ReadBasic`
   and `EduRoster.ReadBasic` as *Microsoft Graph Command Line Tools*; the
   school's administrator has to allow it — requested, pending), which lists
   every assignment not handed in; and, meanwhile, Teams' notifications and its
   mails as Thunderbird announces them (`Notifs.arrive` → `Events.teamsNote` →
   `assignments.py note`): "New assignment: "…" Due Oct 15 at 11:59 PM",
   "Fecha de entrega mañana: "…"", "… is due Friday"… A note with a date is an
   event (the island says so); without one, a to-do. A grouped one with no title
   ("2 new assignments in …", "Tienes 2 tareas nuevas …") becomes a to-do with
   the whole line instead of being dropped. One the panel missed:
   `assignments.py add TITLE DUE [--class C] [--important] [--notes TEXT]`
   (DUE in local time, `2026-10-16T23:59`); `--important` writes Outlook's
   High importance (`X-MICROSOFT-CDO-IMPORTANCE:2`), so the deadline gets a ★
   in the To-do zone and its reminders are always critical. Matches are logged to
   `~/.local/state/quickshell-panel/teams-notes.jsonl` to tune the patterns;
   state in `assignments.json` there; the token in `graph-token.json` (mode 600).
   Handed in or a week past due: gone.
5. **Task providers** (`scripts/providers.py`, run on every refresh): any
   executable in `~/.config/lagos/providers/` (its file name is its name). The
   panel knows nothing else about it; it answers `tasks` with JSON
   `{"label": "Vault", "tasks": [{"id", "title", "due": "YYYY-MM-DD" |
   "YYYY-MM-DDTHH:MM", "where", "remind": false (no reminders, not on the bar),
   "open": url (clicking the title opens it)}]}`, and `done ID` / `undone ID`
   with `{"ok": true}` (it writes it back where the task lives; the island
   offers Undo). Calendar events don't need one: an `.ics` in
   `~/.config/lagos/calendars/` is read like any local calendar. Example: the
   dotfiles' `scripts/providers/vault.py` (an Obsidian vault's `[due:: ]` tasks
   and the day's gym session).

**To hand in** (`Events.deadlines`, `common/DeadlineRow.qml`): Teams
assignments, the providers' tasks and the open to-do tasks, soonest first,
with the exact time left (red under a day, amber under three); in the
Overview's day column (today: all of them; another day: what's due then)
and on top of the To-do zone, one group per source ("FROM TEAMS", "FROM
VAULT"). Their circle marks one done (`assignments.py done UID` for a Teams
one, `providers.py done NAME ID` for a provider's). Today's events that are over leave the day lists
(`Events.dayEvents`, by the real start, so last night's late event doesn't
linger); the one going on is marked "Now".

**Importance and reminders.** Outlook events are treated as important (★) and
get a **critical** notification 15 minutes before they start (critical =
shown even with Do Not Disturb). Published Outlook calendars don't include
their alarms, so the panel schedules them itself. Events marked *High
importance* in Outlook (`X-MICROSOFT-CDO-IMPORTANCE:2`) show an amber ★ and
"High importance" in the reminder. Local events notify (normal urgency)
according to their own reminder. All-day events don't notify. Sent reminders
are remembered in `~/.local/state/quickshell-panel/reminded.json`, so a
restart doesn't repeat them. Reminders work while the panel is running
(it starts with the session).

Recurring events and timezones are expanded with `icalendar` and
`recurring-ical-events`:

```sh
python3 -m venv ~/.local/share/quickshell-panel/venv
~/.local/share/quickshell-panel/venv/bin/pip install icalendar recurring-ical-events
```

## To-do list

Tasks and ideas in `~/.config/lagos/todo.json` (`services/Todos.qml`): a due
date and optionally a time (`due`, `time`), a repeat (`repeat`: daily ·
weekdays · weekly · monthly — completing one moves it to its next date), a
place. The "New task…" field reads plain words like the quick capture box
(below), with a preview of what it understood; the Today / Tomorrow chips win
over it. Each due date shows the time left (red under a day, amber under
three); click it (or "+ date") for `common/DuePicker.qml`: Today · Tomorrow ·
the next weekdays · Next week · No date, typed ("vie 18:00"), and the repeat.
Click the text to edit, the circle to complete, × to remove; an idea has a
copy button always at hand (`wl-copy`; Ctrl+C on the focused row too); completing and
removing say so on the island with an **Undo** (click the island, 6 s).

## Capture, reminders and the day at a glance

- **Quick capture** (`QuickAdd.qml`, `services/Capture.qml`, `common/When.js`):
  SUPER Z (IPC `quickAdd TEXT`) opens one line under the bar; type in plain
  Spanish or English and chips show, live, what it understood: task or event,
  day, time or range, repeat, place, and the title left. Something to do
  (entregar, tarea, estudiar, pagar…) or no time is a to-do; a class, meeting,
  exam… or a time given is an event (`events.py add`, 10 min reminder; a
  repeat becomes an RRULE). Enter saves (the island says it, with Undo) ·
  Tab or the first chip: task ↔ event · Esc closes. SUPER SHIFT Z
  (`quickAddSelection`) starts from the selected text (else the clipboard).
  Notifications (messages, apps, system) have an **Add** button: the box
  opens with their text, its date already read, and "From <app · who>"
  saved as the event's notes.
- **What's due** (`Events.deadlines`): to-dos with a date and Teams
  assignments. Reminded at each stage (Settings → Weather & calendar →
  Reminders: 3 days, 1 day, 3 h, 1 h by default; one reached while off is
  said once) and when overdue; each stays until answered: Done · In 1 h ·
  Tomorrow (9:00) (`notify-send -A`, snoozes kept in `reminded.json`).
- **While you were away**: the panel writes `~/.local/state/quickshell-panel/alive`
  every minute; starting again, events that began meanwhile come in one notification.
- **Morning brief**: once a day from 7:00 (or the first start after it):
  today's events (first one), what's due today and overdue, the other to-dos.
  Open: the Overview.
- **Coming up on the bar**: the right twin (`bar/Agenda.qml`) shows, before
  the music, the most urgent thing: what's due within 6 h (overdue ones
  always) or the next event 30 min before it starts, tinted by its urgency
  (`Events.soon`; both configurable). With nothing urgent it's the player
  while something plays, else the next event. The island stays date · time,
  so the bar keeps its mirror.
- **Timeline** (Agenda's ⏱ button, `common/DayTimeline.qml`): the selected
  day by the hour, overlapping events side by side, free gaps of 30 min or
  more ("Free 1 h 30", from now on for today), what's due as a flag at its
  time, the current time as a line; all-day events above.
- **Undo**: completing / removing a to-do, handing in a Teams assignment,
  removing an event, and everything added from the capture box.

---

## Look

Colors live in `common/Theme.qml`, in three layers:

1. **Wallpaper (wallust)** — surfaces and accents, reloaded whenever wallust
   regenerates `~/.config/waybar/wallust/colors-waybar.css`.
2. **Neutral text** — near-white with a hint of the wallpaper, so the accent
   stands out instead of everything sharing one hue.
3. **Semantic colors (fixed)** — data reads the same on any wallpaper. Amber
   and red are reserved for warnings and never change hue; when the wallust
   palette has that hue too (`Theme.warnClash` / `badClash`), the readings
   (bar `StatItem`, `StatRow`) carry a solid amber / red mark, so a warning
   can't pass for decoration. Settings → Appearance → Warnings
   (`Theme.markOf`): when (`alertMark`: when the wallpaper has red / amber ·
   always · color only) and which mark (`alertShape`: a pill around icon and
   number, in the color that reads on it · a disc behind the icon alone).

### Modes

Settings → Appearance → **Panel & launchers** (the first group), also on the
Controls "Dark mode" tile (flips dark ↔ light) and its detail:

| Setting | Values | |
|---|---|---|
| Mode | Follow system · Dark · Light | `mode`; System reads DarkLight.sh's state |
| Palette | Normal · Inverted | `inverted` |
| Apply to | Panel only · Panel & launchers · Launchers only | `themeScope`; the other side keeps the default theme (dark, normal) |
| Launchers | All · Apps · Clipboard & emoji · Keybinds · Wallpapers · Calc & search · Other menus | `themeLaunchers`, shown unless "Panel only"; groups in `Settings.launcherGroups` |

Only the panel and the Rofi menus: GTK/Qt apps and browsers keep the system
theme (`scripts/wm/DarkLight.sh`). Code:

- `common/ColorPalette.qml` computes every mode-dependent color from the wallust
  colors and a mode; `common/ColorMath.js` has the pure helpers (contrast, mix…).
- `common/Theme.qml` holds the mode, loads wallust and builds two palettes:
  `Theme.panel` (re-exported as `Theme.accent`, `Theme.bg`…) and
  `Theme.launchers`. `chosenLight` / `chosenInverted` are the user's choice;
  `light` / `inverted` are what the panel shows.
- `services/LauncherTheme.qml` writes `~/.config/lagos/rofi/<group>.rasi` for
  each group: the launcher palette's `lagos-*` tokens, or `@lagos-dark-*` (the
  wallust defaults). `config.rasi` imports `apps.rasi`; each `config-*.rasi`
  imports its group's file after it.

| | Normal | Inverted |
|---|---|---|
| **Dark** | the original theme: neutral dark surfaces, wallpaper accent | surfaces in the accent's hue, deep (L 19–33%); accent near-white |
| **Light** | neutral light surfaces tinted with the accent hue; accent darkened to 3:1 | surfaces in the accent's hue, pastel (L 73–86%); accent deep ink |

- **Light/dark** can also follow the system: `System` reads `~/.local/state/hypr/theme_mode`,
  written by `scripts/wm/DarkLight.sh`, and switches live.
- **Inverted** uses the accent's hue at a fixed lightness and capped saturation,
  never the raw wallust color, so a loud wallpaper doesn't produce a loud panel.
  A grey accent borrows the hue of `accent2`.
- Outside the original theme, text is pushed to 4.5:1 and accents, semantic and
  data colors to 3:1 against `bgAlt` (`Theme.ensure`). Card opacity rises to
  82–88% so the blur doesn't turn grey over a dark desktop.
- Critical notifications keep their own fixed dark palette in every mode.
- Mockup used to choose them: https://claude.ai/artifact/UAFXLfseG4gy5sZMWwZeDJ

| Token | Use |
|---|---|
| `bg` / `bgAlt` | panel (72% opaque in the original theme, blurred) / zone surfaces |
| `base` / `scrim` | opaque panel color / translucent layer over images and inset fields |
| `accentText` / `accent2Text` / `onColor(c)` | text and icons drawn on top of `accent`, `accent2` or any filled color |
| `tabBg` / `tabFg` / `tabIcon` / `tabLine` | selected tab: tinted in normal modes, solid pill in inverted ones |
| `border`, `track` | near-neutral outlines / empty part of bars and sliders |
| `fg` / `fgDim` | text / secondary text (neutral) |
| `accent` | state (active button, selected tab, today, played part) and the hero data of a zone (current temperature, track title, System header/icons) |
| `accentSoft` | accent blended with the text color, for large elements (clock, weather description) |
| `vivid` | saturated accent for the showy bits (cava, 24-hour chart) |
| `accent2` | secondary highlights (event dots/bars, avatar): the palette color whose hue is farthest from the accent, skipping hues that look like warn/bad/good (falls back to lavender) |
| `good` / `warn` / `bad` | levels: `Theme.level(ratio, warnAt, badAt)` (normal = good), `Theme.lowLevel(...)` for battery-like values. Green/amber/red by default; if the wallust palette already has that hue, the level takes the complementary hue of the clashing palette color (`avoidPalette`). Critical notifications always use red (`critical`) |
| `rain` | rain chance (≥ 50% highlighted) |
| `tempColor(t)` | temperature scale cold → hot (7-day range bars) |
| `aqiColor(aqi)` | official US EPA AQI colors, fixed: green · yellow · orange · red · purple · maroon |

Guideline: ~60% neutral surfaces, ~30% text, ~10% accent. When adding a zone,
use `accent` for state and at most one hero element, semantic colors for data,
and neutral text for everything else. `Zone { accentHeader: true }` colors a
zone's header; `StatRow { iconColor: … }` its icons.

Fonts: Inter for text, Inter Display SemiBold for the clock (`clockFont`),
JetBrainsMono Nerd Font for icons.

---

## Notifications

The panel **is the notification daemon** (`services/Notifs.qml`, Quickshell's
`NotificationServer`); swaync is no longer started. It:

- shows popups on the focused monitor (`NotificationPopups.qml`) in the place
  chosen for their type (Settings → Notifications → Where popups appear;
  `Notifs.placeKind` / `placeOf`), newest nearest the screen edge, at most
  `maxPopups` per place (the rest wait their turn):

  | Type | Detected by | Default place | Card |
  |---|---|---|---|
  | Calls | category `call.*`, "incoming call" / "llamada entrante" | top left (no "off") | rings until answered / closed; Answer in green, Decline in red |
  | Critical | urgency critical | top center (fixed) | dark card, red header |
  | Security codes | password managers / polkit, a 4–8 digit code next to "code" / "verification" / "2FA"…, sign-in alerts | top center | **Copy code** button (`wl-copy`), 30 s |
  | Reminders | category `calendar.*` (`services/Events.qml`), calendar / to-do apps | top right | stays until dismissed |
  | Volume & brightness | sync tag + `value` hint | top center | compact level card, 1.8 s |
  | Progress | `value` hint without a sync tag (downloads, copies, updates) | top right | normal card + bar that fills in place |
  | System | categories `device.*` / `network.*`, notify-send, battery, screenshots, recordings… | top center | |
  | Messages | categories `im.*` / `email.*`, WhatsApp, Telegram, Teams, Discord, Thunderbird… | bottom right | grouped per conversation: same app + sender → one card, "3 messages" |
  | Now playing | category `x-gnome.music`, Spotify, mpv, VLC, … (`Notifs.mediaApps`) | top right | |
  | Other apps | everything else | top right | |

  **Email** (Thunderbird, `Notifs.mailOf`): Thunderbird titles them "<account>
  received N new messages" and puts "<Subject> from <Sender>" in the body; the
  card shows the sender as the title, the subject as the text, the account
  above and "N new", one card per account.

  **Web apps**: a site's notification comes from the browser ("Brave"). Chromium
  browsers put the site in the body, so known sites (`Notifs.webServices`:
  WhatsApp, Teams, Outlook, Gmail, Google Chat/Meet/Calendar, Messenger,
  Instagram, Telegram, Discord, Slack) get their own name (`Notifs.appLabel`,
  used by rules, grouping and the tab's filter), type, and a body without the
  site line (`Notifs.bodyOf`). Web apps installed from Brave (or Chromium) show
  their own icon instead of the browser's: `Notifs.webApps` reads their
  launchers in `~/.local/share/applications` (when Brave's `Icon=` path doesn't
  exist, the icon is looked up by name in `~/.local/share/icons`).

  **Teams for Linux** draws its own in-window toasts by default; with
  `"notificationMethod": "electron"` in
  `~/.var/app/com.github.IsmaelMartinez.teams_for_linux/config/teams-for-linux/config.json`
  it sends them to the panel instead.

  **Per app** rules (Settings → Notifications → Per app, `appRules`): send an
  app to another place, "history only", or **mute** it (dropped, not even in
  the history). Not for critical notifications or calls. Do Not Disturb lets
  calls and finished downloads through (two switches; downloads are category
  `transfer.complete`, sent by `scripts/wm/DownloadWatch.py`), plus levels and
  security codes.
  Any type can be "Don't show (history only)". They last 3 s (low), 6 s
  (normal), 30 s (critical) or 1.8 s (levels); hovering pauses them.
  While the panel is open, the important ones (critical, calls, security codes,
  reminders: `Notifs.important`) show right below the panel card (place
  `under-panel`, from `PanelState.cardBottom`); the rest wait until it closes.
  Popups are muted by Do Not Disturb
  (critical ones still show, and levels and `SWAYNC_BYPASS_DND` ones too).
- keeps the history until dismissed (Notifications tab). Transient
  notifications are dropped when their popup ends. The history lives in
  memory: restarting the panel clears it.
- replaces instead of stacking: a notification with a sync tag
  (`x-canonical-private-synchronous`, as dunst / swaync) takes the place of the
  previous one with that tag, and isn't kept in the history. With an int
  `value` hint it is a compact **level** card: icon (speaker by level, mic,
  sun, keyboard — from the tag / summary), title, bar animating from the
  previous value, percentage (amber above 100%). `scripts/wm/Volume.sh`
  (tags `volume_notif`, `mic_notif`) and `Brightness.sh` (`brightness_notif`)
  send them, e.g. `notify-send -e -h string:x-canonical-private-synchronous:volume_notif -h int:value:65 Volume 65%`.
  The brightness and volume keys skip that round trip: Hyprland sends them to
  the panel (`GlobalShortcut` `quickshell:brightnessUp` / `brightnessDown`,
  `volumeUp` / `volumeDown` (5 %), `volumeUpFine` / `volumeDownFine` (1 %),
  `volumeMute`, `micMute` in `shell.qml`, bound in `UserConfigs/user_keybinds.lua`),
  `Brightness.step` / `Audio.stepVolume` (PipeWire directly) set it and
  `Notifs.showLevel` puts the card straight into the popups (a plain object,
  never in the history), so the bar shows on the key's frame.
- styles cards like the old swaync setup: wallust colors, 18 px corners, and a
  fixed dark card with the summary as a small red header for critical ones.
- runs the `default` action when a card is clicked; other actions are buttons.
- classifies notifications for the tab's filter (`Notifs.kind`): critical
  (urgency), messages (`im.*`/`email.*` category or a known chat/mail app),
  system (`device.*`/`network.*` or a known system tool), other apps. Edit
  `messagingApps` / `systemApps` in `services/Notifs.qml` to tune it.
- persists Do Not Disturb in `~/.local/state/quickshell-panel/dnd`.
- writes `count dnd` to `~/.cache/quickshell-panel/notifs` and signals waybar
  (`pkill -RTMIN+11 waybar`); the bell module (`custom/swaync` in
  `config/waybar/ModulesCustom`) runs `scripts/wm/NotifStatus.sh`.

Startup and fallbacks:

- Runs as the user service `quickshell-panel.service`
  (`config/systemd/user/`, `Type=dbus`, `Restart=always`), so exactly one copy
  owns `org.freedesktop.Notifications` and a crash is restarted within a second.
  It starts with `graphical-session.target`; `user_startup.lua` and
  `PanelToggle.sh` only `systemctl --user start` it (a no-op if running).
- `config/dbus-1/services/org.freedesktop.Notifications.service` (linked to
  `~/.local/share/dbus-1/services/`, which wins over `/usr/share`) makes D-Bus
  start that same service, not swaync or Plasma, if a notification arrives
  while nothing owns the bus name.
- `swaync.service` is masked, so nothing (e.g. a stray `swaync-client`) can
  D-Bus-activate swaync and take the name first. The swaync lines in
  `config/hypr/lua/startup.lua` and `configs/Startup_Apps.conf` are commented
  out, and `scripts/wm/Refresh.sh` no longer relaunches it.
- `install.sh` creates both links, masks swaync and enables the service.

Check who owns the bus: `busctl --user status org.freedesktop.Notifications | grep UserUnit`

**Back to swaync:** `systemctl --user disable --now quickshell-panel`,
`systemctl --user unmask swaync.service`, remove the D-Bus link, uncomment the
swaync startup line, start `swaync`, and restore the `custom/swaync` module and
the `SUPER SHIFT + N` bind (git history has the old versions).

## Controls and Settings

**Controls** (`zones/ControlCenter.qml`) is the "right now" tab:

- **Identity bar** — avatar, name, `user@host · distro on WM · uptime`, a
  **DND** pill (click toggles, **›** shows its detail in the right pane,
  right-click opens Settings → Notifications), battery, and **⚙ Settings ·
  lock · power menu**.
- **Toggles** — a 3×3 grid, row by row: Caffeine · Airplane · Wi-Fi /
  Night light · Game · Bluetooth / Screen record · Display · Light mode. Click
  toggles; **›** shows its detail in the right pane, or as a popover like
  Overview's notifications (`popoverAreas` in ControlCenter.qml,
  `PanelState.controlsPopover`; click outside, ✕ or Esc closes it): Caffeine
  and Night light over the tiles of columns 2–3 (growing down if needed),
  Screen record and Display over Sound & display at its size, scrolling when
  they need more room (wheel, ↑/↓, PgUp/PgDn; `Zone.scrollable`);
  right-click opens its Settings section (dark mode, caffeine).

  | Tile | Does | Detail |
  |---|---|---|
  | Wi-Fi | NetworkManager on/off; status starts with "VPN ·" while one is up | **Networks** / **VPN** views (`WifiZone`). An Ethernet row sits above the networks when there is a wired device (unplugged / click to connect / connected). Clicking the connected Wi-Fi network (or the On tile's ›), the connected Ethernet or a connected VPN shows its details (`services/NetInfo.qml`): state, IPv4/gateway/DNS/IPv6 (selectable), plus signal, speed, band/channel, security and MAC for Wi-Fi; speed, interface and MAC for Ethernet; type, server and interface for VPNs; auto-connect, Disconnect, Forget (asks twice; not for Ethernet), Advanced (`nm-connection-editor --edit <uuid>`). VPN: the NetworkManager VPN/WireGuard connections (`services/Vpn.qml`, `nmcli`), click to connect/disconnect, › or "Add or import" opens `nm-connection-editor` |
  | Bluetooth | adapter on/off (unblocks rfkill first) | paired devices (`BluetoothZone`) |
  | Dark mode | dark ↔ light, saved (panel and/or Rofi, never apps) | mode, palette, apply to; link to the launcher choice |
  | Night light | `scripts/wm/Hyprsunset.sh toggle` (same as SUPER N) | temperature, live via `hyprctl hyprsunset`, saved to `~/.config/lagos/nightlight-temp` for the script |
  | Caffeine | `systemd-inhibit --what=idle` (hypridle honors it) | 30 min / 1 hour / until off |
  | Airplane mode | `rfkill block` Wi-Fi + Bluetooth; off restores what was on | — |
  | Game mode | `scripts/wm/GameMode.sh` (state: Hyprland animations off) | — |
  | Screen record | start / stop `gpu-screen-recorder` (`services/Recorder.qml`; also SUPER ALT Print, IPC `record`); the panel closes on start, the tile shows the time | screen or region (slurp), 30/60 fps, audio none / system / system + mic; files in `~/Recordings/Screen_<date>.mp4` (with the radio's, `Config.recordingsDir`), notification when saved |
  | Display | opens its detail (popover over Sound & display, scrolls) | per monitor (`services/Displays.qml`): on/off (never the last one), mode, scale, via `hyprctl eval 'hl.monitor{…}'` until Hyprland reloads; nwg-displays / monitor profiles to keep a layout |

- **Sound & display** — output, microphone, brightness; click the device name
  to choose another one.
- **Detail pane** — System (stats + **power profile**, tuned-ppd /
  power-profiles-daemon) unless a toggle's detail is open. `Esc` closes a
  detail, then the panel.

**Settings** (⚙, or `qs -c panel ipc call panel settings [section]`) replaces
the tab's content: sections on the left, rows on the right, generated from the
schema in `common/Settings.qml`. Changes apply at once and a toast offers
**Undo**; each section can be reset. `← Settings` or `Esc` goes back.

Values live in `~/.config/lagos/panel-settings.json` (first run takes the mode
from the old `panel-theme.json`). Rows marked **SYSTEM** change files outside
the panel; `services/SystemSettings.qml` applies them:

| Setting | Applied by |
|---|---|
| Idle timeouts, "not while media is playing" | writes `~/.config/lagos/hypridle.conf` (variables `source`d by `config/hypr/hypridle.conf`, which keeps the defaults) and restarts hypridle |
| Battery alert levels | writes `~/.config/lagos/battery-alerts`, read by `scripts/wm/BatteryNotify.sh` every 30 s. Charger connected / unplugged: `services/Charger.qml` (laptops only, from UPower's `onBattery` at once: level and, if known, time to full / empty; icons in `icons/`) |
| Closing the lid (on battery · plugged in · with an external monitor) | writes `~/.config/lagos/lid`, read by `scripts/wm/LaptopLid.sh` each time the lid closes; it acts only while `lagos-lid.service` holds logind's lid inhibitor ("Handled by" shows it), otherwise logind decides |
| Power profile at login | set once per boot when the panel starts |
| Wallpaper rotation | a timer picks a random wallpaper and applies it like the Wallpapers tab |
| Blur | `scripts/wm/PanelBlur.sh on\|off\|toggle\|status`: saves `~/.config/lagos/panel-blur` (read by `UserConfigs/user_layer_rules.lua` when Hyprland loads) and replaces the two panel layer rules live with `hyprctl eval` |
| Where menus open (rofi) | `scripts/wm/RofiPosition.sh bottom\|center\|toggle\|status`: writes `config/hypr/rofi/position.rasi` (imported last by the Lagos rofi theme) |
| Colors from the wallpaper | `scripts/wm/WallustToggle.sh on\|off\|toggle\|status`: saves `~/.config/lagos/wallust`; when off, `WallustSwww.sh` updates the wallpaper links but skips wallust, so every caller (wallpaper picker, DarkLight, effects…) keeps the current palette; back on recolors from the current wallpaper |

Blur and wallust can also be changed from a terminal or a keybind with those
scripts; their state files are the source of truth and the Settings switches
follow them. Opacity has a script too: `scripts/wm/PanelOpacity.sh 80 | +5 | -5 | status`
(50–100%; light and inverted modes add 10–16% on top).

Panel settings (opacity, animations, open tab, close on outside click, dim,
size, quiet hours, popup duration, history limit, week start, event refresh)
are read live by `Theme`, `Config`, `PanelState` and `Notifs`.

**Add a setting:** a default in `Settings.defaults`, a row in its section of
`Settings.sections`, and read `Settings.v.<key>` where it matters (a system one
also goes in `SystemSettings`).

## Language

The panel speaks the system's language (`LANG`, the one chosen when
installing), or the one picked in Settings → Appearance → Language (System ·
English · Español). The code is written in English; `common/Tr.qml` looks each
text up in `i18n/<lang>.json` (English text → translation), and a missing one
stays English.

- **Text:** `Tr.t("Clear all")`, with arguments `Tr.t("Due %1: %2", when, what)`,
  plurals `Tr.n(count, "%1 message", "%1 messages")`. Never glue words around
  a value (`"in " + n + " min"`): the order changes between languages.
- **Dates:** `Tr.date(d, "ddd d MMM")` (`Qt.formatDate` is always English),
  `Tr.cap()` for a first capital (Spanish names are lowercase).
- **Data shown elsewhere** (the Settings schema, tab names, test kinds) stays
  English in the data and is translated where it's drawn (`SettingRow`,
  `SettingsView`, `Panel.qml`), so values and ids never change.
- **`common/When.js`** can't see singletons: `dayWord` / `describe` take `Tr`
  as their last argument. Capture keeps understanding both languages.
- **Scripts** (`scripts/wm/lagos_i18n.sh`, `lagos_i18n.py`) read the same
  setting and dictionary: `t "Battery at %1" "$cap"`.
- **A new language:** copy `i18n/es.json`, translate the values, add it to
  `Tr.languages` and to the Language row in `Settings.sections`.

## Data sources

| Zone | Source |
|---|---|
| Profile / identity bar | `services/Profile.qml`: `getent passwd`, `hostname`, `/etc/os-release`, `~/.face` avatar (initials if missing) |
| Notifications | D-Bus `org.freedesktop.Notifications` (this panel is the server). Media keys (`scripts/wm/MediaCtrl.sh`) act on the focused window's player, else one on the workspace, else what plays, else the last one toggled; their notice has the player's name in the title and the cover as an image hint marked `x-lagos-cover`, shown as big as the card allows |
| Weather / WeatherNow | `scripts/lib/Weather.py` → `~/.cache/open_meteo_cache.json` (location: see `scripts/wm/ToggleWeatherLoc.sh`) |
| Clock | `SystemClock` |
| Calendar | local clock + `scripts/events.py`; week start and refresh: Settings → Weather & calendar |
| System | `/proc/stat`, `/proc/meminfo`, coretemp hwmon, `df /`, `/sys/class/power_supply` |
| Media | MPRIS over D-Bus (`services/Media.qml`; the `playerctld` proxy is skipped, it duplicated the active player). Hover previews aren't music: a YouTube page that isn't a video (feed, search, channel) hides its player, and a browser's track counts for the bar only once its audio stream has made sound (`PwNodePeakMonitor`; a muted preview has no stream, a paused video's idle one never peaks); volume and outputs are the system's (PipeWire default sink); visualizer: `cava -p scripts/cava.conf` while the Media tab is open (this cava build has no PipeWire input, so it uses `pulse`). Radio (`services/Radio.qml`): stations in `~/.config/lagos/radio-stations` (`Name \| stream URL \| subtitle \| logo URL`; created with Radio BUAP, the default, `Settings.v.radioStation`), played by `mpv --no-video` with a JSON IPC socket the panel reads for the ICY title (what's on air); IPC `radio` starts / stops it. Library (`services/Library.qml`): MPD (`config/mpd/mpd.conf`: `~/Music`, PipeWire output, gapless, ReplayGain by album; user service `systemctl --user enable --now mpd`) driven by `scripts/library.py` over MPD's socket (`~/.local/state/mpd/socket`): albums grouped by album artist + album, covers from `cover/folder/front.jpg` or the embedded picture (cached), cache of the album list until MPD's database changes; albums as a grid or a list (`Settings.v.libraryView`), sorted like Spotify's library (`Settings.v.librarySort`: recents = last played from the panel, kept in `~/.local/state/quickshell-panel/library-played.json`, else newest; recently added = MPD's `Added`; alphabetical; artist by its sort name; year); searches ignore case and accents; an album with more than 12 tracks gets a track search (title, number or "3-07" on box sets; Enter plays the first match); an album's booklet = every image in its folder and subfolders (`Artwork/`, cover first): a thumbnail strip, a page (or the header cover) shows in the big art, crossfading (two Images taking turns), with ‹ › to page, ⤢ full size in the image viewer (`xdg-open`, closes the panel) and ↺ back to the playing art; MPD reaches the island and Overview as an MPRIS player through mpDris2 (`config/mpDris2/mpDris2.conf`); **Check quality** (`library.py verify`, needs numpy: Audiophile flavor) tells whether each track is really lossless: the codec ffprobe sees (an MP3/AAC renamed .flac = fake), a spectrum cliff ≥ 25 dB below 19.5 kHz (lossy encoders' lowpass = transcoded; a CD's own filter cuts at 20–22 kHz, so a 320k MP3 can't be told apart), a Hi-Res file whose content stops by ~22 kHz (a resampled CD), 24 bits whose low 8 are always 0 (padded 16-bit); results cached per file (size + mtime) in `~/.cache/quickshell-panel/verify.json`; a track's mark opens its spectrogram (`library.py spectrum`); "bit-perfect" = a sound card's real rate (`/proc/asound/card*/pcm*p/sub*/hw_params`) equals the music's. PipeWire may switch the device to the music's rate (the Audiophile flavor's `flavors/audiophile/config/pipewire/pipewire.conf.d/10-hires.conf`: 44.1–192 kHz). beets (Audiophile flavor, `flavors/audiophile/config/beets/config.yaml`) imports and tags into `Artist/Album (Year)/NN - Title`, with cover.jpg and ReplayGain. Player, radio or library view: `Settings.v.mediaMode`. Lyrics (`services/Lyrics.qml`, `scripts/lyrics.py`, `Settings.v.mediaLyrics`): a library file's `.lrc` or LYRICS tag, else LRCLIB (lrclib.net, free, no account; timed lyrics preferred), cached in `~/.cache/quickshell-panel/lyrics`. App volume: the PipeWire playback streams matching the player (desktop entry / name words: `com.spotify.Client`, `Firefox`, `mpd.PipeWire`, `mpv`) |
| Comms dock | `CommsDock.qml` + `services/Comms.qml`: messaging / mail apps (Settings → Comms dock, `Settings.v.commsApps`: desktop entry ids, or `name:<Name>` for a browser web app; WhatsApp, Thunderbird and Teams by default; add a suggested installed one or any app with a window open, reorder, remove — its window comes back) each run hidden in their special workspace `special:comms-<app>`, started at login by `scripts/wm/CommsStartup.sh` (IPC `commsStart`, launched through Hyprland with `gtk-launch`, then moved once their main window — the one titled with the app's name — appears). Per app, when it runs (`Settings.v.commsLife`, the options under its line): *Always on* (the default, opened at login), *When picked*, or *Closes after* 15 min – 2 h without use (shown, focused, playing through MPRIS or in a reply counts as use; checked every minute, closed with `quit()`). SUPER Y (IPC `comms`) shows the last one used, full screen above a macOS-style dock that mirrors the top bar: at rest it shows only as much as the bar takes from the top (the tops of its icons), it rises on hover, and the app's gap below is set live to match the room above (running dot, unread count from the title or new notifications, hover grows the icon and names it); a dock icon switches app or starts it; the shown one hides. Right click on an icon: reload / restart / quit, when it runs, remove; the gear at the end opens Settings → Comms dock. From the main side, the bar's Comms button after the workspaces (`Settings.v.barWsComms`, unread count, right click: settings). Clicking one of their notifications opens it there. Behind the shown app the monitor switches to an empty workspace `comms` (hidden in waybar) so the wallpaper shows through the slightly translucent app (window rule on `n[s:special:comms-]`, `dim_special = 0`); hiding goes back. Shown some other way (the app focusing itself), the panel moves to `comms` too, remembering where to go back. While one is shown it stays put (`UserConfigs/user_window_rules.lua`, `hl.on` workspace.active / window.active): switching workspace (keys, the bar, ALT TAB) goes back to `comms`, and the focus can't leave it except for pinned windows; leave with SUPER Y; SUPER TAB / SUPER SHIFT TAB go to the next / previous app (elsewhere they keep switching workspace and group tab; CTRL TAB goes to the app, e.g. its tabs). SUPER SHIFT Y (IPC `commsDock`): the keyboard to the dock (←/→, Enter, 1–9, Esc). Quick reply from the notification (Reply button): the app's own inline reply when it has one (`inlineReplySupported`), else for a message from a dock app (not mail) its action opens the chat as soon as the reply box opens, and on Enter `scripts/reply.sh` pastes the text and presses Enter in that window (`send_shortcut`). Only the focused window may read the clipboard, so it gets the focus for half a second, invisibly: opacity 0, animations and special-workspace blur off, the previous window keeping its look; then everything is restored (clipboard, opacities, options, focus), even on failure. Apps that reuse one notification (WhatsApp in Brave) replace its text in place: the earlier text stays in the history as a plain copy (`Notifs.archive`) and the new one pops up again. A message the app closes itself (WhatsApp Web does, after a few seconds) also stays as a copy. Read in the app, messages leave the history: when the unread count in its title ("(3) WhatsApp") drops to none, or the app is shown with none (for apps whose title has shown a count); a quick reply sent clears that chat. Do Not Disturb also quiets the apps' own sounds (WhatsApp Web plays its ping in the page): `scripts/dndmute.py` mutes the audio streams of the dock apps' processes (and their children; Chromium's sandboxed audio by its program name) while they're hidden. Its `pactl subscribe` dies with it (PR_SET_PDEATHSIG): each panel reload used to leave one behind until pipewire-pulse refused new clients — not the one shown or focused, one ringing with a call let through, or one recording (a call). WirePlumber remembers a muted app, so the names muted are kept in `~/.local/state/quickshell-panel/dnd-muted.json` and a stream of one shows up unmuted again after DND. Two web apps of one browser share its process: Brave (WhatsApp) is muted as a whole. Popup colors: Settings → Notifications → Colors (`notifTheme`: panel · system · dark · light · inverted; `Theme.notifications`, a third ColorPalette; Label / Glyph / IconButton / TextField take a `pal`). Settings → Notifications → Try them sends a test of each kind (marked `x-lagos-test`: no quick reply, a click opens nothing). Thunderbird's calendar reminder dialog floats small at the top right, pinned (window rule). A stopped MPRIS player with no track (a browser after a video) isn't listed. The bottom gap is one workspace rule for `n[s:special:comms-]` (`UserConfigs/user_window_rules.lua`); special workspaces are full size (`dwindle.special_scale_factor = 1`, `user_settings.lua`) |
| Forecast | `scripts/forecast.py` → Open-Meteo forecast + air-quality API (US AQI), same coordinates as waybar's weather cache |
| Wallpapers | `~/Pictures/wallpapers` (`wallpaperDir` in Config); thumbnails in `~/.cache/quickshell-panel/thumbs/`; applied with `scripts/wm/WallpaperSelect.sh <file>` (awww + wallust + bar refresh) |
| Sliders | `services/Audio.qml` (PipeWire default sink/source, device lists), `brightnessctl` |
| Wi-Fi / Bluetooth | `Quickshell.Networking` (NetworkManager), `Quickshell.Bluetooth` (BlueZ); new Wi-Fi networks open `nmcli --ask` in kitty; arrows open `nm-connection-editor` / `blueman-manager` |
