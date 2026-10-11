pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
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
    readonly property string themedTokens: {
        const p = Theme.launchers;
        const v = {
            "surface": C.rasi(p.base, Math.max(0.92, p.bgOpacity)),
            "zone": C.rasi(p.bgAlt, p.original ? 0.70 : 0.95),
            "hover": C.rasi(p.bgHover),
            "fg": C.rasi(p.fg),
            "fg-dim": C.rasi(p.fgDim),
            "accent": C.rasi(p.accent),
            "accent-soft": C.rasi(p.tabBg),
            "selected-fg": C.rasi(p.tabFg),
            "on-accent": C.rasi(p.accentText),
            "border": C.rasi(p.border),
            "urgent": C.rasi(p.bad)
        };
        return tokenNames.map(n => `  lagos-${n}: ${v[n]};`).join("\n");
    }
    readonly property string defaultTokens: tokenNames.map(n => `  lagos-${n}: @lagos-dark-${n};`).join("\n")
    readonly property string mode: (Theme.launchers.light ? "light" : "dark") + (Theme.launchers.inverted ? " inverted" : "")

    function text(id) {
        const on = themed(id);
        return `/* Written by the Quickshell panel (services/LauncherTheme.qml): ${on ? mode : "default theme"} */\n`
             + `* {\n${on ? themedTokens : defaultTokens}\n}\n`;
    }
    // Everything the files depend on; a change rewrites them (debounced)
    readonly property string state: JSON.stringify([Settings.launcherGroups.map(g => themed(g.id)), themedTokens])
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
