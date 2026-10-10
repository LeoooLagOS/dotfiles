pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

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
// Default mode and inverted: Settings → Appearance (common/Settings.qml), or
// `qs -c panel ipc call panel themeMode light|dark|system` / `toggleInverted`.
// "system" follows DarkLight.sh (~/.local/state/hypr/theme_mode). The Controls
// tile switches dark/light for now only (`override`, not saved).
Singleton {
    id: root

    // ---------------- Mode ----------------
    readonly property string modeSetting: Settings.v.mode    // "system" | "dark" | "light"
    readonly property bool inverted: Settings.v.inverted
    property bool systemLight: false               // from DarkLight.sh
    readonly property bool defaultLight: modeSetting === "light" || (modeSetting === "system" && systemLight)
    property string override: ""                   // "dark" | "light" for now (Controls tile), "" = default
    readonly property bool light: override ? override === "light" : defaultLight
    readonly property bool original: !light && !inverted

    function setMode(m) { override = ""; Settings.set("mode", m); }
    function setInverted(on) { Settings.set("inverted", on); }
    // Controls tile: flip dark/light now; back to the default when it matches it
    function toggleLight() {
        const next = light ? "dark" : "light";
        override = (next === "light") === defaultLight ? "" : next;
    }
    // Duration of color/highlight transitions (Settings → Animations)
    readonly property int anim: Settings.v.animations ? 200 : 0

    // ---------------- 1. Wallust palette ----------------
    property color wallBackground: "#141416"
    property color wallForeground: "#d4d4d4"
    property var palette: ({})                 // color0 … color15
    readonly property color color0: palette.color0 ?? "#3a3a3a"
    readonly property color color9: palette.color9 ?? "#c0504d"
    readonly property color color12: palette.color12 ?? "#8a8a8a"

    // Accent hue/saturation/lightness, and the tone inverted surfaces are built
    // from: the accent, or the secondary accent if the accent is grey
    readonly property real aH: hue(color12)
    readonly property real aS: Math.max(0, color12.hslSaturation)
    readonly property real aL: color12.hslLightness
    readonly property bool accentGrey: aS < 0.15
    readonly property real invH: !accentGrey ? aH : accent2Source ? hue(accent2Source) : aH
    readonly property real invS: !accentGrey ? aS : accent2Source ? accent2Source.hslSaturation : 0.06

    // Panel card (translucent, blurred by Hyprland) and its opaque base color
    readonly property color base: original ? wallBackground
                                : !light ? (inverted ? Qt.hsla(invH, Math.min(0.42, invS * 0.75), 0.19, 1) : wallBackground)
                                : inverted ? Qt.hsla(invH, Math.min(0.55, invS), 0.86, 1)
                                : Qt.hsla(aH, Math.min(0.12, aS), 0.97, 1)
    // Settings → Opacity; the other modes add a little so the blur doesn't turn grey
    readonly property real bgOpacity: Math.min(1, Settings.v.opacity / 100 + (original ? 0 : !light ? 0.10 : inverted ? 0.16 : 0.14))
    readonly property color bg: withAlpha(base, bgOpacity)                                  // panel
    readonly property color bgAlt: original ? mix(wallBackground, color0, 0.5)              // zones
                                 : !light ? Qt.hsla(invH, Math.min(0.40, invS * 0.7), 0.26, 1)
                                 : inverted ? Qt.hsla(invH, Math.min(0.58, invS), 0.80, 1)
                                 : Qt.hsla(aH, Math.min(0.16, aS), 0.93, 1)
    readonly property color bgHover: original ? color0
                                   : !light ? Qt.hsla(invH, Math.min(0.38, invS * 0.7), 0.33, 1)
                                   : inverted ? Qt.hsla(invH, Math.min(0.58, invS), 0.73, 1)
                                   : Qt.hsla(aH, Math.min(0.18, aS), 0.88, 1)
    // Mostly neutral with a hint of the wallpaper (borders were full accent before)
    readonly property color border: original ? withAlpha(mix(fg, color12, 0.35), 0.18)
                                  : withAlpha(fg, !light ? 0.14 : inverted ? 0.12 : 0.10)
    readonly property color track: withAlpha(fg, original ? 0.10 : !light ? 0.16 : inverted ? 0.13 : 0.09)  // empty part of bars/sliders
    readonly property color backdrop: Qt.rgba(0, 0, 0, 0.1)        // blurred by Hyprland
    // Translucent layer over images and inset fields (name on a wallpaper tile…)
    readonly property color scrim: withAlpha(base, 0.75)

    // Primary accent: state only (active buttons, selected tab, today, played part)
    readonly property color accent: {
        if (original) return color12;
        if (!light) return Qt.hsla(invH, 0.35, 0.94, 1);                  // inverted dark: near-white
        if (inverted) return Qt.hsla(invH, Math.min(0.6, invS), 0.25, 1); // inverted light: deep ink
        let a = ensure(Qt.hsla(aH, aS, Math.min(aL, 0.5), 1), bgAlt, 3);
        if (contrast("#ffffff", a) < 4.5) a = ensure(a, "#ffffff", 4.5);
        return a;
    }
    // Text and icons drawn on top of the accent (selected day, active button…)
    readonly property color onAccent: original ? wallBackground
                                    : !light ? Qt.hsla(invH, Math.min(0.6, invS), 0.24, 1)
                                    : inverted ? Qt.hsla(invH, 0.4, 0.96, 1)
                                    : "#ffffff"
    // Selected tab: tinted in normal modes, a solid pill in inverted ones
    readonly property color tabBg: inverted ? accent : withAlpha(accent, 0.18)
    readonly property color tabFg: inverted ? onAccent : fg
    readonly property color tabIcon: inverted ? onAccent : accent
    readonly property color tabLine: inverted ? "transparent" : accent
    // Accent blended with the text color: for large elements (clock) where the
    // full accent would be too heavy
    readonly property color accentSoft: original ? mix(fg, accent, 0.6)
                                      : ensure(mix(fg, accent, inverted ? 0.25 : 0.6), bgAlt, 3)
    // Accent with boosted saturation, for the "showy" bits (cava, chart)
    readonly property color vivid: Qt.hsla(hue(accent), Math.min(1, accent.hslSaturation * 1.6 + 0.2),
                                           clamp(accent.hslLightness, 0.45, 0.65), 1)
    // Secondary accent: the palette color whose hue is farthest from the accent,
    // normalized so it reads on the zone surfaces (event dots, event bars…)
    readonly property var accent2Source: {
        let best = null, bestDist = 0;
        for (let i = 1; i <= 15; i++) {
            const c = palette["color" + i];
            if (!c) continue;
            const q = Qt.color(c);
            if (q.hslSaturation < 0.18) continue;            // skip greys
            if (nearSemantic(q.hslHue)) continue;            // don't look like warn/bad/good
            const dist = hueDist(q.hslHue, aH);
            if (dist > bestDist) { bestDist = dist; best = q; }
        }
        return (!best || bestDist < 0.08) ? null : best;
    }
    readonly property color accent2: {
        const s = accent2Source ?? Qt.color("#8f9cf3");     // nothing suitable: neutral lavender
        const h = hue(s), sat = s.hslSaturation;
        if (original) return accent2Source ? Qt.hsla(h, Math.max(0.45, sat), clamp(s.hslLightness, 0.55, 0.7), 1) : s;
        if (!light) return ensure(Qt.hsla(h, Math.max(0.45, sat), inverted ? 0.74 : 0.62, 1), bgAlt, 3);
        return ensure(Qt.hsla(h, Math.max(inverted ? 0.5 : 0.45, sat), inverted ? 0.36 : 0.45, 1), bgAlt, 3);
    }
    readonly property color onAccent2: onColor(accent2)
    // Dark or light text for any filled color (the wallust background in the original theme)
    function onColor(c) { return original ? wallBackground : lum(c) > 0.3 ? "#141414" : "#ffffff"; }

    // ---------------- 2. Neutral text ----------------
    readonly property color fg: original ? mix("#eceef2", wallForeground, 0.12)
                              : !light ? Qt.hsla(inverted ? invH : aH, inverted ? 0.30 : 0.08, 0.95, 1)
                              : inverted ? Qt.hsla(invH, Math.max(0.35, Math.min(0.5, invS)), 0.13, 1)
                              : Qt.hsla(aH, Math.min(0.15, aS), 0.12, 1)
    readonly property color fgDim: original ? withAlpha(fg, 0.58)
                                 : ensure(over(withAlpha(fg, !light ? 0.72 : inverted ? 0.68 : 0.62), bgAlt), bgAlt, 4.5)

    // ---------------- 3. Semantic colors ----------------
    // Standard green / amber / red, unless the wallust palette already uses that
    // hue (e.g. a red wallpaper with a red accent): then that level takes the
    // inverse (complementary hue) of the palette color it collides with, so a
    // warning never looks like decoration. Outside the original theme they are
    // also darkened (light modes) and pushed to 3:1 against the zones.
    readonly property color goodBase: "#6cc58a"
    readonly property color warnBase: "#e6b450"
    readonly property color badBase: "#ec6a6a"
    readonly property color good: semantic(goodBase)
    readonly property color warn: semantic(warnBase)
    readonly property color bad: semantic(badBase)
    readonly property color rain: original ? "#62a8e8" : semantic("#62a8e8")
    readonly property color critical: badBase               // critical notifications stay red
    function semantic(c) {
        if (original) return avoidPalette(c);
        const a = avoidPalette(c);
        return ensure(light ? Qt.hsla(hue(a), a.hslSaturation, 0.40, 1) : a, bgAlt, 3);
    }
    // Fixed data colors (temperature, AQI) stay as they are in the original
    // theme and are only pushed to 3:1 in the others
    function readable(c) { return original ? Qt.color(c) : ensure(c, bgAlt, 3); }

    // Saturated palette colors (the ones that carry the wallpaper's identity)
    readonly property var paletteHues: {
        const out = [];
        for (let i = 1; i <= 15; i++) {
            const c = palette["color" + i];
            if (!c) continue;
            const q = Qt.color(c);
            if (q.hslSaturation >= 0.3 && q.hslLightness > 0.25 && q.hslLightness < 0.85) out.push(q);
        }
        return out;
    }
    function hueDist(a, b) { const d = Math.abs(a - b); return Math.min(d, 1 - d); }
    function avoidPalette(base) {
        base = Qt.color(base);
        const hit = paletteHues.find(p => hueDist(p.hslHue, base.hslHue) < 0.05);
        if (!hit) return base;
        return Qt.hsla((hit.hslHue + 0.5) % 1, Math.max(0.5, hit.hslSaturation),
                       clamp(base.hslLightness, 0.55, 0.68), 1);
    }

    // Hues (0..1) taken by the semantic colors: red (bad), amber (warn), green (good)
    function nearSemantic(h) {
        return h < 0.045 || h > 0.955 || Math.abs(h - 0.11) < 0.055 || Math.abs(h - 0.39) < 0.05;
    }

    // Usage level (0..1) → good below warnAt, warn, then bad above badAt.
    // Always the semantic scale (never the accent); each level already moves to
    // its complementary hue if the wallust palette uses it (avoidPalette).
    function level(ratio, warnAt, badAt) {
        return ratio >= badAt ? bad : ratio >= warnAt ? warn : good;
    }
    // Battery-style level, where *low* is bad
    function lowLevel(ratio, warnBelow, badBelow) {
        return ratio <= badBelow ? bad : ratio <= warnBelow ? warn : good;
    }
    // Temperature (°C) → cold blue · mild teal-green · warm amber · hot red-orange
    function tempColor(t) {
        const stops = [[0, "#6ea8ff"], [12, "#62c6d6"], [20, "#8fd18a"], [27, "#f0b45a"], [34, "#f07a52"]];
        if (t <= stops[0][0]) return readable(stops[0][1]);
        for (let i = 1; i < stops.length; i++) {
            if (t <= stops[i][0]) {
                const [t0, c0] = stops[i - 1], [t1, c1] = stops[i];
                return readable(mix(Qt.color(c0), Qt.color(c1), (t - t0) / (t1 - t0)));
            }
        }
        return readable(stops[stops.length - 1][1]);
    }
    // US EPA AQI → the official EPA colors, fixed (never adjusted to the palette).
    // Bands: 0–50 Good, 51–100 Moderate, 101–150 Unhealthy for sensitive groups,
    // 151–200 Unhealthy, 201–300 Very unhealthy, 301+ Hazardous.
    // The two darkest official colors are lightened a bit to read on dark surfaces.
    function aqiColor(aqi) {
        return aqi < 0 ? fgDim : readable(
                aqi <= 50 ? "#00e400"      // Good (green)
             : aqi <= 100 ? "#ffff00"     // Moderate (yellow)
             : aqi <= 150 ? "#ff7e00"     // Unhealthy for sensitive groups (orange)
             : aqi <= 200 ? "#ff0000"     // Unhealthy (red)
             : aqi <= 300 ? "#a85cb8"     // Very unhealthy (official #8f3f97)
             : "#b8334f");                // Hazardous (official #7e0023)
    }

    // ---------------- Shape & type ----------------
    readonly property int panelRadius: 22
    readonly property int zoneRadius: 14
    readonly property int buttonRadius: 10
    readonly property int zonePadding: 12
    readonly property string font: "Inter"
    readonly property string iconFont: "JetBrainsMono Nerd Font"
    readonly property string clockFont: "Inter Display"      // large clock digits

    function withAlpha(c, a) { return Qt.rgba(c.r, c.g, c.b, a); }
    function mix(a, b, t) {
        a = Qt.color(a); b = Qt.color(b);
        return Qt.rgba(a.r * (1 - t) + b.r * t, a.g * (1 - t) + b.g * t,
                       a.b * (1 - t) + b.b * t, a.a * (1 - t) + b.a * t);
    }
    function clamp(v, lo, hi) { return Math.max(lo, Math.min(hi, v)); }
    // HSL hue in 0..1 (Qt gives -1 for greys)
    function hue(c) { return Math.max(0, Qt.color(c).hslHue); }
    // Color with alpha flattened over an opaque background
    function over(c, bgc) { c = Qt.color(c); return mix(bgc, Qt.rgba(c.r, c.g, c.b, 1), c.a); }
    // WCAG relative luminance and contrast ratio
    function lum(c) {
        c = Qt.color(c);
        const f = v => v <= 0.03928 ? v / 12.92 : Math.pow((v + 0.055) / 1.055, 2.4);
        return 0.2126 * f(c.r) + 0.7152 * f(c.g) + 0.0722 * f(c.b);
    }
    function contrast(a, b) {
        const x = lum(a), y = lum(b);
        return (Math.max(x, y) + 0.05) / (Math.min(x, y) + 0.05);
    }
    // Move the lightness away from `bgc` until the contrast reaches `min`
    function ensure(c, bgc, min) {
        c = Qt.color(c);
        const up = lum(bgc) < 0.2, h = hue(c), s = Math.max(0, c.hslSaturation);
        let l = c.hslLightness, out = c;
        for (let i = 0; i < 60 && contrast(out, bgc) < min; i++) {
            l = clamp(l + (up ? 0.02 : -0.02), 0, 1);
            out = Qt.hsla(h, s, l, c.a);
        }
        return out;
    }

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
