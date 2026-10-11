.pragma library

// Pure color helpers shared by Theme.qml and ColorPalette.qml (no state).

function withAlpha(c, a) { c = Qt.color(c); return Qt.rgba(c.r, c.g, c.b, a); }
function mix(a, b, t) {
    a = Qt.color(a); b = Qt.color(b);
    return Qt.rgba(a.r * (1 - t) + b.r * t, a.g * (1 - t) + b.g * t,
                   a.b * (1 - t) + b.b * t, a.a * (1 - t) + b.a * t);
}
function clamp(v, lo, hi) { return Math.max(lo, Math.min(hi, v)); }
// HSL hue in 0..1 (Qt gives -1 for greys)
function hue(c) { return Math.max(0, Qt.color(c).hslHue); }
function hueDist(a, b) { const d = Math.abs(a - b); return Math.min(d, 1 - d); }
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
// Hues (0..1) taken by the semantic colors: red (bad), amber (warn), green (good)
function nearSemantic(h) {
    return h < 0.045 || h > 0.955 || Math.abs(h - 0.11) < 0.055 || Math.abs(h - 0.39) < 0.05;
}
// rofi color literal: rgba(r, g, b, a) with 0–255 channels
function rasi(c, a) {
    c = Qt.color(c);
    return `rgba(${Math.round(c.r * 255)}, ${Math.round(c.g * 255)}, ${Math.round(c.b * 255)}, ${(a ?? c.a).toFixed(2)})`;
}
