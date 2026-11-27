pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../common"

// Obsidian's colors (Settings → Wallpaper → Obsidian, and Controls → Appearance): writes
// ~/.config/lagos/app-colors/staging/obsidian.css, a CSS snippet scripts/AppColors.sh copies
// into each vault while that switch is on; Obsidian reloads snippets live. Built from the
// panel's own palette rules (ColorPalette) for Obsidian's mode and palette, so it looks like
// the panel in each of light / dark × normal / inverted. Mode and palette follow the
// panel's (Appearance → Mode / Palette) unless set apart. The snippet covers both of
// Obsidian's base themes, so it shows whichever one Obsidian is set to.
Singleton {
    id: root

    readonly property string dir: Quickshell.env("HOME") + "/.config/lagos/app-colors/staging"
    readonly property string modeSetting: Settings.v.obsidianMode ?? "panel"          // panel | system | dark | light
    readonly property string paletteSetting: Settings.v.obsidianPalette ?? "panel"    // panel | normal | inverted
    readonly property bool light: modeSetting === "panel" ? Theme.chosenLight
                                : modeSetting === "system" ? Theme.systemLight : modeSetting === "light"
    readonly property bool inverted: paletteSetting === "panel" ? Theme.chosenInverted : paletteSetting === "inverted"

    ColorPalette {
        id: p
        light: root.light
        inverted: root.inverted
        opacity: 100                    // a window, not a translucent panel: opaque surfaces
        wallBackground: Theme.wallBackground
        wallForeground: Theme.wallForeground
        palette: Theme.palette
    }
    function hex(c) {
        c = Qt.color(c);
        const h = v => Math.round(v * 255).toString(16).padStart(2, "0");
        return "#" + h(c.r) + h(c.g) + h(c.b);
    }
    // A color at some opacity, over whatever is under it
    function a(c, pct) { return `color-mix(in srgb, ${hex(c)} ${pct}%, transparent)`; }

    readonly property string text: `/* lagOS colors for Obsidian: written by the Quickshell panel (services/ObsidianTheme.qml),
 * ${light ? "light" : "dark"}, ${inverted ? "inverted" : "normal"} palette. Don't edit: it's rewritten. */
.theme-dark, .theme-light {
  color-scheme: ${light ? "light" : "dark"};

  /* Surfaces: the note on the panel's base, the side panes on its zone color */
  --background-primary: ${hex(p.base)};
  --background-primary-alt: ${hex(p.bgAlt)};
  --background-secondary: ${hex(p.bgAlt)};
  --background-secondary-alt: color-mix(in srgb, ${hex(p.fg)} 6%, ${hex(p.bgAlt)});
  --titlebar-background: ${hex(p.bgAlt)};
  --titlebar-background-focused: color-mix(in srgb, ${hex(p.fg)} 4%, ${hex(p.bgAlt)});
  --background-modifier-border: ${a(p.fg, 14)};
  --background-modifier-border-hover: ${a(p.fg, 24)};
  --background-modifier-hover: ${a(p.fg, 7)};
  --background-modifier-active-hover: ${a(p.accent, 15)};

  /* Text */
  --text-normal: ${hex(p.fg)};
  --text-muted: color-mix(in srgb, ${hex(p.fg)} 70%, ${hex(p.base)});
  --text-faint: color-mix(in srgb, ${hex(p.fg)} 45%, ${hex(p.base)});
  --text-on-accent: ${hex(p.accentText)};
  --text-selection: ${a(p.accent, 30)};
  --text-highlight-bg: ${a(p.accent2, 30)};

  /* Accent: links, buttons, the active file, checkboxes */
  --color-accent: ${hex(p.accent)};
  --color-accent-1: color-mix(in srgb, ${hex(p.accent)} 85%, ${hex(p.fg)});
  --color-accent-2: color-mix(in srgb, ${hex(p.accent)} 70%, ${hex(p.fg)});
  --text-accent: ${hex(p.accent)};
  --text-accent-hover: color-mix(in srgb, ${hex(p.accent)} 80%, ${hex(p.fg)});
  --interactive-accent: ${hex(p.accent)};
  --interactive-accent-hover: color-mix(in srgb, ${hex(p.accent)} 85%, ${hex(p.fg)});
  --link-color: ${hex(p.accent2)};
  --link-external-color: ${hex(p.accent2)};
  --h1-color: ${hex(p.fg)};
  --h2-color: ${hex(p.fg)};
}
`
    // Only once the wallpaper's palette is loaded (else the default grey would be written)
    readonly property bool ready: Object.keys(Theme.palette ?? {}).length > 0
    onTextChanged: if (ready) writer.restart()
    onReadyChanged: if (ready) writer.restart()

    Timer {
        id: writer
        interval: 400
        onTriggered: file.setText(root.text)
    }
    FileView {
        id: file
        path: root.dir + "/obsidian.css"
        atomicWrites: true
        printErrors: false
        preload: false
    }
}
