pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "ColorMath.js" as C

// Colors. Three layers:
//   1. Surfaces + accents follow the wallpaper (wallust file shared with waybar,
//      reloaded whenever wallust regenerates it).
//   2. Text is neutral (only slightly tinted), so the accent stands out.
//   3. Semantic colors (good / warn / bad / rain, temperature and air-quality
//      scales) are fixed, so data reads the same on any wallpaper.
// Rule of thumb: ~60% neutral surfaces, ~30% text, ~10% accent. Use `accent`
// only for state (active, selected, today, played), `accent2` for secondary
// highlights, and the semantic colors for data.
//
// Four modes: dark / light (`light`) × normal / inverted (`inverted`).
//   normal    neutral surfaces, accent = the wallpaper color (color12)
//   inverted  surfaces take the accent's hue at a fixed lightness (deep in
//             dark, pastel in light) and the accent becomes the neutral
//             extreme (near-white in dark, deep ink in light)
// Text, accent and semantic colors are pushed to WCAG contrast (4.5:1 text,
// 3:1 icons/bars) against the zone surface, so any wallpaper stays legible.
// Dark + normal is the original theme, unchanged.
// The palette rules live in ColorPalette.qml; this singleton holds the mode, loads
// the wallust colors and builds two palettes:
//   panel      what the panel draws with (re-exported below: Theme.accent…)
//   launchers  the Rofi menus' colors (services/LauncherTheme.qml writes them)
// Settings → Appearance → Panel & launchers (also the Controls "Dark mode" tile):
//   mode            system | dark | light ("system" follows DarkLight.sh,
//                   ~/.local/state/hypr/theme_mode)
//   inverted        normal / inverted palette
//   themeScope      panel | both | launchers: where that choice applies; the
//                   other side keeps the default theme (dark, normal)
//   themeLaunchers  which Rofi menus follow it (["all"] or group ids)
// Never GTK/Qt apps or browsers: those keep the system theme.
// IPC: `themeMode light|dark|system`, `toggleInverted`, `currentTheme`.
Singleton {
    id: root

    // ---------------- Mode ----------------
    readonly property string modeSetting: Settings.v.mode      // "system" | "dark" | "light"
    readonly property string scope: Settings.v.themeScope      // "panel" | "both" | "launchers"
    property bool systemLight: false                            // from DarkLight.sh
    // The user's choice…
    readonly property bool chosenLight: modeSetting === "light" || (modeSetting === "system" && systemLight)
    readonly property bool chosenInverted: Settings.v.inverted
    // …and what the panel shows (the default theme when the choice is for launchers only)
    readonly property bool panelThemed: scope !== "launchers"
    readonly property bool light: panelThemed && chosenLight
    readonly property bool inverted: panelThemed && chosenInverted
    readonly property bool original: panel.original

    function setMode(m) { Settings.set("mode", m); }
    function setInverted(on) { Settings.set("inverted", on); }
    // Controls tile: flip dark/light (and stop following the system)
    function toggleLight() { setMode(chosenLight ? "dark" : "light"); }
    // Duration of color/highlight transitions (Settings → Animations)
    readonly property int anim: Settings.v.animations ? 200 : 0

    // ---------------- Wallust colors ----------------
    property color wallBackground: "#141416"
    property color wallForeground: "#d4d4d4"
    property var palette: ({})                 // color0 … color15

    // ---------------- Palettes ----------------
    readonly property ColorPalette panel: ColorPalette {
        light: root.light
        inverted: root.inverted
        opacity: Settings.v.opacity
        wallBackground: root.wallBackground
        wallForeground: root.wallForeground
        palette: root.palette
    }
    readonly property ColorPalette launchers: ColorPalette {
        light: root.scope !== "panel" && root.chosenLight
        inverted: root.scope !== "panel" && root.chosenInverted
        opacity: Settings.v.opacity
        wallBackground: root.wallBackground
        wallForeground: root.wallForeground
        palette: root.palette
    }

    // ---------------- Panel colors (see ColorPalette.qml) ----------------
    readonly property color base: panel.base
    readonly property real bgOpacity: panel.bgOpacity
    readonly property color bg: panel.bg
    readonly property color bgAlt: panel.bgAlt
    readonly property color bgHover: panel.bgHover
    readonly property color border: panel.border
    readonly property color track: panel.track
    readonly property color backdrop: panel.backdrop
    readonly property color scrim: panel.scrim
    readonly property color accent: panel.accent
    readonly property color accentText: panel.accentText
    readonly property color tabBg: panel.tabBg
    readonly property color tabFg: panel.tabFg
    readonly property color tabIcon: panel.tabIcon
    readonly property color tabLine: panel.tabLine
    readonly property color accentSoft: panel.accentSoft
    readonly property color vivid: panel.vivid
    readonly property color accent2: panel.accent2
    readonly property color accent2Text: panel.accent2Text
    readonly property color fg: panel.fg
    readonly property color fgDim: panel.fgDim
    readonly property color good: panel.good
    readonly property color warn: panel.warn
    readonly property color bad: panel.bad
    readonly property color rain: panel.rain
    readonly property color critical: panel.critical
    function onColor(c) { return panel.onColor(c); }
    function level(ratio, warnAt, badAt) { return panel.level(ratio, warnAt, badAt); }
    function lowLevel(ratio, warnBelow, badBelow) { return panel.lowLevel(ratio, warnBelow, badBelow); }
    function tempColor(t) { return panel.tempColor(t); }
    function aqiColor(aqi) { return panel.aqiColor(aqi); }

    // ---------------- Shape & type ----------------
    readonly property int panelRadius: 22
    readonly property int zoneRadius: 14
    readonly property int buttonRadius: 10
    readonly property int zonePadding: 12
    readonly property string font: "Inter"
    readonly property string iconFont: "JetBrainsMono Nerd Font"
    readonly property string clockFont: "Inter Display"      // large clock digits

    // Color helpers (common/ColorMath.js)
    function withAlpha(c, a) { return C.withAlpha(c, a); }
    function mix(a, b, t) { return C.mix(a, b, t); }
    function ensure(c, bgc, min) { return C.ensure(c, bgc, min); }

    FileView {
        path: Quickshell.env("HOME") + "/.config/waybar/wallust/colors-waybar.css"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: {
            const re = /@define-color\s+([\w-]+)\s+(#[0-9A-Fa-f]{6})/g;
            const txt = text();
            const pal = {};
            let m;
            while ((m = re.exec(txt)) !== null) {
                if (m[1] === "background") root.wallBackground = m[2];
                else if (m[1] === "foreground") root.wallForeground = m[2];
                else if (/^color\d+$/.test(m[1])) pal[m[1]] = m[2];
            }
            root.palette = pal;
        }
    }

    // System light/dark, written by scripts/wm/DarkLight.sh
    FileView {
        path: (Quickshell.env("XDG_STATE_HOME") || Quickshell.env("HOME") + "/.local/state") + "/hypr/theme_mode"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: root.systemLight = text().trim() === "Light"
    }
}
