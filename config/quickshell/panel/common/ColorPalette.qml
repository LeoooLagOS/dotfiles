import QtQuick
import "ColorMath.js" as C

// One computed palette: every mode-dependent color, from the wallust colors and
// a mode (light × inverted). Theme.qml builds two of them: the panel's and the
// Rofi launchers' (they differ when the theme applies to only one of them, see
// Settings → Appearance → Panel & launchers). The design rules are in Theme.qml.
QtObject {
    id: root

    // ---------------- Inputs ----------------
    property bool light: false
    property bool inverted: false
    property real opacity: 72                    // Settings → Opacity (%)
    property color wallBackground: "#141416"
    property color wallForeground: "#d4d4d4"
    property var palette: ({})                   // wallust color0 … color15
    readonly property bool original: !light && !inverted

    readonly property color color0: palette.color0 ?? "#3a3a3a"
    readonly property color color9: palette.color9 ?? "#c0504d"
    readonly property color color12: palette.color12 ?? "#8a8a8a"

    // Accent hue/saturation/lightness, and the tone inverted surfaces are built
    // from: the accent, or the secondary accent if the accent is grey
    readonly property real aH: C.hue(color12)
    readonly property real aS: Math.max(0, color12.hslSaturation)
    readonly property real aL: color12.hslLightness
    readonly property bool accentGrey: aS < 0.15
    readonly property real invH: !accentGrey ? aH : accent2Source ? C.hue(accent2Source) : aH
    readonly property real invS: !accentGrey ? aS : accent2Source ? accent2Source.hslSaturation : 0.06

    // Panel card (translucent, blurred by Hyprland) and its opaque base color
    readonly property color base: original ? wallBackground
                                : !light ? (inverted ? Qt.hsla(invH, Math.min(0.42, invS * 0.75), 0.19, 1) : wallBackground)
                                : inverted ? Qt.hsla(invH, Math.min(0.55, invS), 0.86, 1)
                                : Qt.hsla(aH, Math.min(0.12, aS), 0.97, 1)
    // `opacity` (Settings → Opacity); the other modes add a little so the blur doesn't turn grey
    readonly property real bgOpacity: Math.min(1, opacity / 100 + (original ? 0 : !light ? 0.10 : inverted ? 0.16 : 0.14))
    readonly property color bg: C.withAlpha(base, bgOpacity)                                  // panel
    readonly property color bgAlt: original ? C.mix(wallBackground, color0, 0.5)              // zones
                                 : !light ? Qt.hsla(invH, Math.min(0.40, invS * 0.7), 0.26, 1)
                                 : inverted ? Qt.hsla(invH, Math.min(0.58, invS), 0.80, 1)
                                 : Qt.hsla(aH, Math.min(0.16, aS), 0.93, 1)
    readonly property color bgHover: original ? color0
                                   : !light ? Qt.hsla(invH, Math.min(0.38, invS * 0.7), 0.33, 1)
                                   : inverted ? Qt.hsla(invH, Math.min(0.58, invS), 0.73, 1)
                                   : Qt.hsla(aH, Math.min(0.18, aS), 0.88, 1)
    // Mostly neutral with a hint of the wallpaper (borders were full accent before)
    readonly property color border: original ? C.withAlpha(C.mix(fg, color12, 0.35), 0.18)
                                  : C.withAlpha(fg, !light ? 0.14 : inverted ? 0.12 : 0.10)
    readonly property color track: C.withAlpha(fg, original ? 0.10 : !light ? 0.16 : inverted ? 0.13 : 0.09)  // empty part of bars/sliders
    readonly property color backdrop: Qt.rgba(0, 0, 0, 0.1)        // blurred by Hyprland
    // Translucent layer over images and inset fields (name on a wallpaper tile…)
    readonly property color scrim: C.withAlpha(base, 0.75)

    // Primary accent: state only (active buttons, selected tab, today, played part)
    readonly property color accent: {
        if (original) return color12;
        if (!light) return Qt.hsla(invH, 0.35, 0.94, 1);                  // inverted dark: near-white
        if (inverted) return Qt.hsla(invH, Math.min(0.6, invS), 0.25, 1); // inverted light: deep ink
        let a = C.ensure(Qt.hsla(aH, aS, Math.min(aL, 0.5), 1), bgAlt, 3);
        if (C.contrast("#ffffff", a) < 4.5) a = C.ensure(a, "#ffffff", 4.5);
        return a;
    }
    // Text and icons drawn on top of the accent (selected day, active button…)
    readonly property color accentText: original ? wallBackground
                                    : !light ? Qt.hsla(invH, Math.min(0.6, invS), 0.24, 1)
                                    : inverted ? Qt.hsla(invH, 0.4, 0.96, 1)
                                    : "#ffffff"
    // Selected tab: tinted in normal modes, a solid pill in inverted ones
    readonly property color tabBg: inverted ? accent : C.withAlpha(accent, 0.18)
    readonly property color tabFg: inverted ? accentText : fg
    readonly property color tabIcon: inverted ? accentText : accent
    readonly property color tabLine: inverted ? "transparent" : accent
    // Accent blended with the text color: for large elements (clock) where the
    // full accent would be too heavy
    readonly property color accentSoft: original ? C.mix(fg, accent, 0.6)
                                      : C.ensure(C.mix(fg, accent, inverted ? 0.25 : 0.6), bgAlt, 3)
    // Accent with boosted saturation, for the "showy" bits (cava, chart)
    readonly property color vivid: Qt.hsla(C.hue(accent), Math.min(1, accent.hslSaturation * 1.6 + 0.2),
                                           C.clamp(accent.hslLightness, 0.45, 0.65), 1)
    // Secondary accent: the palette color whose hue is farthest from the accent,
    // normalized so it reads on the zone surfaces (event dots, event bars…)
    readonly property var accent2Source: {
        let best = null, bestDist = 0;
        for (let i = 1; i <= 15; i++) {
            const c = palette["color" + i];
            if (!c) continue;
            const q = Qt.color(c);
            if (q.hslSaturation < 0.18) continue;            // skip greys
            if (C.nearSemantic(q.hslHue)) continue;            // don't look like warn/bad/good
            const dist = C.hueDist(q.hslHue, aH);
            if (dist > bestDist) { bestDist = dist; best = q; }
        }
        return (!best || bestDist < 0.08) ? null : best;
    }
    readonly property color accent2: {
        const s = accent2Source ?? Qt.color("#8f9cf3");     // nothing suitable: neutral lavender
        const h = C.hue(s), sat = s.hslSaturation;
        if (original) return accent2Source ? Qt.hsla(h, Math.max(0.45, sat), C.clamp(s.hslLightness, 0.55, 0.7), 1) : s;
        if (!light) return C.ensure(Qt.hsla(h, Math.max(0.45, sat), inverted ? 0.74 : 0.62, 1), bgAlt, 3);
        return C.ensure(Qt.hsla(h, Math.max(inverted ? 0.5 : 0.45, sat), inverted ? 0.36 : 0.45, 1), bgAlt, 3);
    }
    readonly property color accent2Text: onColor(accent2)
    // Dark or light text for any filled color (the wallust background in the original theme)
    function onColor(c) { return original ? wallBackground : C.lum(c) > 0.3 ? "#141414" : "#ffffff"; }

    // ---------------- 2. Neutral text ----------------
    readonly property color fg: original ? C.mix("#eceef2", wallForeground, 0.12)
                              : !light ? Qt.hsla(inverted ? invH : aH, inverted ? 0.30 : 0.08, 0.95, 1)
                              : inverted ? Qt.hsla(invH, Math.max(0.35, Math.min(0.5, invS)), 0.13, 1)
                              : Qt.hsla(aH, Math.min(0.15, aS), 0.12, 1)
    readonly property color fgDim: original ? C.withAlpha(fg, 0.58)
                                 : C.ensure(C.over(C.withAlpha(fg, !light ? 0.72 : inverted ? 0.68 : 0.62), bgAlt), bgAlt, 4.5)

    // ---------------- 3. Semantic colors ----------------
    // Amber and red are reserved for warnings: always amber and red, whatever
    // the wallpaper. When the wallust palette uses that hue too (a red
    // wallpaper), warnClash / badClash are true and the readings mark the
    // warning with a solid disc behind their icon (bar/StatItem.qml,
    // common/StatRow.qml), so it can't pass for decoration. Green (good) still
    // takes the inverse (complementary hue) of a palette color it collides
    // with. Outside the original theme they are also darkened (light modes)
    // and pushed to 3:1 against the zones.
    readonly property color goodBase: "#6cc58a"
    readonly property color warnBase: "#e6b450"
    readonly property color badBase: "#ec6a6a"
    readonly property color good: semantic(goodBase)
    readonly property color warn: alarm(warnBase)
    readonly property color bad: alarm(badBase)
    readonly property bool warnClash: clashes(warnBase)
    readonly property bool badClash: clashes(badBase)
    readonly property color rain: original ? "#62a8e8" : semantic("#62a8e8")
    readonly property color critical: badBase               // critical notifications stay red
    function alarm(c) {
        c = Qt.color(c);
        if (original) return c;
        return C.ensure(light ? Qt.hsla(C.hue(c), c.hslSaturation, 0.40, 1) : c, bgAlt, 3);
    }
    function clashes(c) {
        c = Qt.color(c);
        return paletteHues.some(p => C.hueDist(p.hslHue, c.hslHue) < 0.05);
    }
    function semantic(c) {
        if (original) return avoidPalette(c);
        const a = avoidPalette(c);
        return C.ensure(light ? Qt.hsla(C.hue(a), a.hslSaturation, 0.40, 1) : a, bgAlt, 3);
    }
    // Fixed data colors (temperature, AQI) stay as they are in the original
    // theme and are only pushed to 3:1 in the others
    function readable(c) { return original ? Qt.color(c) : C.ensure(c, bgAlt, 3); }

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
    function avoidPalette(base) {
        base = Qt.color(base);
        const hit = paletteHues.find(p => C.hueDist(p.hslHue, base.hslHue) < 0.05);
        if (!hit) return base;
        return Qt.hsla((hit.hslHue + 0.5) % 1, Math.max(0.5, hit.hslSaturation),
                       C.clamp(base.hslLightness, 0.55, 0.68), 1);
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
                return readable(C.mix(Qt.color(c0), Qt.color(c1), (t - t0) / (t1 - t0)));
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
}
