# swaync — notification popups & panel

> **Not in use:** swaync is no longer the notification daemon. Notifications,
> popups and the notification list are handled by the Quickshell panel —
> see [`config/quickshell/panel`](../quickshell/panel/README.md#notifications)
> (which also explains how to switch back). This folder is kept for reference.

This folder configures [SwayNotificationCenter](https://github.com/ErikReider/SwayNotificationCenter)
(swaync 0.12): the notification popups at the top of the screen and the panel
opened with `Super+Shift+N`.

| File          | What it controls                                                      |
|---------------|-----------------------------------------------------------------------|
| `config.json` | **What** is shown: panel zones and their order, sizes, timeouts, position |
| `style.css`   | **How** it looks: colors, fonts, spacing, corners (one section per zone) |
| `*.bak`, `*.pre-*` | Backups of earlier styles — safe to delete                       |

Apply changes without restarting:

```sh
swaync-client -R    # reload config.json
swaync-client -rs   # reload style.css
```

---

## The panel is built from zones

The panel is a vertical stack of **widgets**. The `"widgets"` list in
`config.json` *is* the panel, top to bottom:

```json
"widgets": ["dnd", "buttons-grid", "mpris", "volume", "backlight", "title", "notifications"]
```

| Zone                          | Widget          | Configured in `widget-config` | CSS section in `style.css` |
|-------------------------------|-----------------|-------------------------------|----------------------------|
| Do Not Disturb toggle         | `dnd`           | `"dnd"`                       | `ZONE: Do Not Disturb`     |
| Quick buttons (power, lock…)  | `buttons-grid`  | `"buttons-grid"`              | `ZONE: Quick buttons`      |
| Media — now playing           | `mpris`         | `"mpris"`                     | `ZONE: Media`              |
| Volume / Brightness sliders   | `volume`, `backlight` | `"volume"`, `"backlight"` | `ZONE: Volume and Brightness` |
| "Notifications" header + Clear| `title`         | `"title"`                     | `ZONE: "Notifications" header` |
| Notification list             | `notifications` | —                             | `ZONE: Notification list`  |

- **Reorder** a zone: move its name in the `"widgets"` list.
- **Remove** a zone: delete its name from the list (its `widget-config` entry can stay).
- **Configure** a zone: edit its entry under `"widget-config"`.
- **Restyle** a zone: edit only its `ZONE:` section in `style.css`. Each widget
  gets the CSS class `.widget-<name>` (e.g. `.widget-mpris`).

> If `"notifications"` is missing from the list, swaync adds it at the bottom.

### Available widget types

| Widget         | What it does                                                         |
|----------------|----------------------------------------------------------------------|
| `title`        | Text header with an optional "Clear all" button                      |
| `dnd`          | Do Not Disturb switch                                                |
| `notifications`| The notification list (only one allowed)                             |
| `mpris`        | Media player controls with album art                                 |
| `buttons-grid` | Grid of buttons, each running a shell command                        |
| `menubar`      | Buttons that open dropdown menus of commands                         |
| `volume`       | Volume slider (+ optional per-app volumes)                           |
| `backlight`    | Screen brightness slider                                             |
| `slider`       | Generic slider driven by your own get/set shell commands             |
| `label`        | **Static** text (cannot run commands or show images)                 |
| `inhibitors`   | Shows apps currently inhibiting notifications                        |

Full option list for every widget: `/etc/xdg/swaync/configSchema.json`.

---

## Adding a new zone

Any widget type can be used several times by giving each copy a name after `#`.
Each copy is configured and styled on its own.

**Example — a "Profile" greeting and an "Apps" row of buttons above DND:**

1. Add them to the list in `config.json`:

   ```json
   "widgets": ["label#profile", "buttons-grid#apps", "dnd", "buttons-grid", "mpris", ...]
   ```

2. Configure them under `"widget-config"`:

   ```json
   "label#profile": {
     "text": "Hi there",
     "max-lines": 1
   },
   "buttons-grid#apps": {
     "actions": [
       { "label": "Web", "command": "firefox" },
       { "label": "Term", "command": "kitty" },
       { "label": "Files", "command": "nautilus" }
     ]
   }
   ```

   Labels can be plain text or Nerd Font icons (search glyphs at
   https://www.nerdfonts.com/cheat-sheet) — JetBrainsMono Nerd Font is the
   fallback font, so icon glyphs render.

3. Style them in `style.css`, in a new `ZONE:` section placed where the zone
   appears in the panel. The name after `#` becomes an **extra CSS class**
   on the widget (verified — `#profile` as a CSS id does *not* work):

   ```css
   /* ---------------------------------------------------------------------------
      ZONE: Profile                                  widget: "label#profile"
      --------------------------------------------------------------------------- */
   .widget-label.profile > label {
       font-size: 1.4rem;
       font-weight: 600;
   }
   ```

4. Reload: `swaync-client -R && swaync-client -rs`.

### Limits of swaync zones

Zones are limited to the widget types above. In particular there is no way to
show **dynamic** content (avatar, username, uptime, weather, system stats) —
`label` is static text only. For fully custom zones, the panel would have to
be built with a widget toolkit such as **eww** or **AGS** instead.

---

## Look & behaviour reference

### Colors

Colors come from **wallust** (`~/.config/waybar/wallust/colors-waybar.css`),
regenerated on every wallpaper change. The wallpaper scripts reload swaync
automatically. The palette names are defined once at the top of `style.css`:

| Name       | Used for                         |
|------------|----------------------------------|
| `@bg`      | Card/panel background (72% opaque, blurred by Hyprland) |
| `@bg-alt`  | Zone backgrounds inside the panel |
| `@border`  | Thin outlines                     |
| `@fg`, `@fg-dim` | Text, secondary text        |
| `@accent`  | Sliders, switches                 |

**Critical notifications** use a separate, fixed palette (`@crit-*`) — a dark
frosted card with a small red "⚠ CRITICAL" header — so they look the same on
any wallpaper. The header is the notification's *summary* text, styled small
and red; senders put the real title in the body.

### Sizes & timeouts (`config.json`)

| Key                         | Value | Meaning                               |
|-----------------------------|-------|---------------------------------------|
| `notification-window-width` | 360   | Popup width (px)                      |
| `notification-icon-size`    | 32    | App icon size in cards                |
| `control-center-width`      | 450   | Panel width                           |
| `timeout` / `timeout-low`   | 6 / 3 | Seconds before normal / low popups hide |
| `timeout-critical`          | 30    | Seconds before critical popups hide (0 = never) |

### Blur (Hyprland, not swaync)

Blur is configured in `~/.config/hypr/UserConfigs/`:

- `user_layer_rules.lua` — enables blur for the `swaync-control-center` layer.
  The panel layer is fullscreen with a ~10% transparent backdrop
  (`.blank-window`), so `ignore_alpha = 0` blurs the whole screen behind the
  panel; raise it to e.g. `0.3` to blur only the panel itself.
- `user_decorations.lua` — global blur strength (`size = 4, passes = 1`).
  This affects every blurred surface, not just swaync.

---

## Related: battery alerts

`~/.config/hypr/UserScripts/BatteryNotify.sh` (autostarted from
`UserConfigs/user_startup.lua`) sends notifications while discharging at 50%
and 20%, and critical notifications plus a centered popup at 10% and 5%.
The popup's window rule (float, center, pin, rounding, dim) is in
`UserConfigs/user_window_rules.lua`.
