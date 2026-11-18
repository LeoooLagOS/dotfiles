pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "../common"
import "../common/ColorMath.js" as C

// Rofi colors, per launcher group (Settings.launcherGroups). Writes
// ~/.config/lagos/rofi/<group>.rasi for every group; each config-*.rasi (and
// config.rasi for "apps") imports its group's file after the Lagos theme:
//   themed group   the lagos-* tokens of Theme.launchers (mode + palette)
//   other groups   the lagos-* tokens set back to the wallust dark defaults
//                  (@lagos-dark-*, config/hypr/wallust/templates/colors-rofi.rasi)
// A group is themed when Appearance → Apply to includes launchers and
// Launchers is "All" or names it. Rewritten when any of that changes; rofi
// reads the files each time a menu opens.
Singleton {
    id: root

    readonly property string dir: Quickshell.env("HOME") + "/.config/lagos/rofi"
    // ["all"] or group ids (a single id as a string is accepted too, e.g. from IPC)
    readonly property var picked: [].concat(Settings.v.themeLaunchers ?? "all")
    function themed(id) {
        return Theme.scope !== "panel" && (picked.includes("all") || picked.includes(id));
    }

    readonly property var tokenNames: ["surface", "zone", "hover", "fg", "fg-dim", "accent", "accent-soft",
                                       "selected-fg", "on-accent", "border", "urgent"]
    // The menus look like Windows 11's Start: a neutral card (#202020 dark,
    // #f3f3f3 light) with a hint of the wallpaper, nearly opaque; the search
    // field and the selected row a faint step of the text color, not a color
    // block; the accent only where focus is (the search line, the tab).
    // Inverted keeps the wallpaper-colored surfaces. Also with the default
    // theme (Theme.launchers is then dark, normal)
    readonly property var win: {
        const p = Theme.launchers;
        if (p.inverted) return { surface: C.rasi(p.base, 0.97), zone: C.rasi(p.bgAlt, 0.95),
                                 soft: C.rasi(p.tabBg), selFg: C.rasi(p.tabFg) };
        const card = C.mix(p.light ? "#f3f3f3" : "#202020", p.base, 0.12);
        return { surface: C.rasi(card, 0.96),
                 zone: p.light ? C.rasi("#ffffff", 0.85) : C.rasi(C.mix(card, "#ffffff", 0.07), 0.95),
                 soft: C.rasi(p.fg, p.light ? 0.06 : 0.08), selFg: C.rasi(p.fg) };
    }
    readonly property string surface: win.surface
    readonly property string zone: win.zone
    readonly property string themedTokens: {
        const p = Theme.launchers;
        const v = {
            "surface": surface,
            "zone": zone,
            "hover": C.rasi(p.bgHover),
            "fg": C.rasi(p.fg),
            "fg-dim": C.rasi(p.fgDim),
            "accent": C.rasi(p.accent),
            "accent-soft": win.soft,
            "selected-fg": win.selFg,
            "on-accent": C.rasi(p.accentText),
            "border": C.rasi(p.border),
            "urgent": C.rasi(p.bad)
        };
        return tokenNames.map(n => `  lagos-${n}: ${v[n]};`).join("\n");
    }
    readonly property string defaultTokens: tokenNames.map(n => `  lagos-${n}: ${
        n === "surface" ? surface : n === "zone" ? zone : n === "accent-soft" ? win.soft
        : n === "selected-fg" ? win.selFg : "@lagos-dark-" + n};`).join("\n")
    // Corners like the windows' (Hyprland's decoration:rounding, Theme.windowRadius),
    // themed or not: the menus float like windows
    // And the room the menus have so they never touch the panel's card
    // (Panel.qml: Settings width / height % of the area below the bar,
    // Config.topMargin under it), on the focused monitor. rofi counts from
    // below the bar too (it keeps out of the space the bar reserves):
    //   lagos-room            height below the card: 10 px from the bottom
    //                         edge (position.rasi) and 8 px under the card
    //                         (Config.spacing); the big menus fill it, up to
    //                         Windows 11's start menu (720 px)
    //   lagos-room-top        "centered" menus start there, 8 px under the card (a
    //                         centered layer can't be moved: margins only apply to
    //                         an anchored edge, so they hang from the top instead)
    //   lagos-side-width      menus under the logo (SUPER R, SUPER X): to 8 px left of the card
    readonly property var screen: Quickshell.screens.find(x => x.name === Hyprland.focusedMonitor?.name) ?? Quickshell.screens[0] ?? null
    readonly property int reserved: !BarState.enabled ? 0 : BarState.zone
    readonly property int areaH: (screen?.height ?? 1080) - reserved
    readonly property int cardBottom: Config.topMargin + Math.round(areaH * Config.heightFraction)
    readonly property int cardLeft: Math.round(((screen?.width ?? 1920) - Math.round((screen?.width ?? 1920) * Config.widthFraction)) / 2)
    readonly property int room: Math.max(200, Math.min(720, areaH - cardBottom - 10 - Config.spacing))
    readonly property int roomTop: cardBottom + Config.spacing
    readonly property int sideWidth: Math.max(280, Math.min(480, cardLeft - 8 - Config.spacing))
    readonly property string radiusTokens: `  lagos-radius: ${Theme.windowRadius}px;\n  lagos-radius-inner: ${Theme.innerRadius}px;\n`
        + `  lagos-room: ${room}px;\n  lagos-room-top: ${roomTop}px;\n  lagos-side-width: ${sideWidth}px;`
    readonly property string mode: (Theme.launchers.light ? "light" : "dark") + (Theme.launchers.inverted ? " inverted" : "")

    function text(id) {
        const on = themed(id);
        return `/* Written by the Quickshell panel (services/LauncherTheme.qml): ${on ? mode : "default theme"} */\n`
             + `* {\n${on ? themedTokens : defaultTokens}\n${radiusTokens}\n}\n`;
    }
    // Everything the files depend on; a change rewrites them (debounced)
    readonly property string state: JSON.stringify([Settings.launcherGroups.map(g => themed(g.id)), themedTokens, defaultTokens, radiusTokens])
    onStateChanged: writer.restart()
    Component.onCompleted: writer.restart()

    Timer {
        id: writer
        interval: 300
        onTriggered: {
            for (let i = 0; i < files.count; i++) {
                const f = files.objectAt(i);
                f.setText(root.text(f.group));
            }
        }
    }
    Instantiator {
        id: files
        model: Settings.launcherGroups
        delegate: FileView {
            required property var modelData
            readonly property string group: modelData.id
            path: root.dir + "/" + modelData.id + ".rasi"
            atomicWrites: true
            printErrors: false
            preload: false
        }
    }
    // FileView doesn't create directories
    Process { running: true; command: ["mkdir", "-p", root.dir] }
}
