pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../common"

// The browsers' theme (Settings → Wallpaper → Browsers): writes
// ~/.config/lagos/app-colors/staging/browser.json, which scripts/AppColors.sh hands to
// every browser that follows the colors (while that switch is on):
//   { "seed": "#rrggbb", "scheme": "dark" | "light" | "device", "variant": "tonal" | "vibrant" }
//   seed     the vivid accent of the panel's palette for the browser's mode and palette (the
//            accent's hue, saturation boosted): Chromium builds its whole theme from it (policy
//            BrowserThemeColor). Not the accent itself: tuned for text contrast, it can be near
//            white or ink, and a theme grown from it comes out flat
//   scheme   policy BrowserColorScheme; Firefox: `pywalfox dark | light | auto`
//   variant  Chromium's color variant: tonal spot (normal) or vibrant (inverted: surfaces
//            take more of the wallpaper's color). A preference, not a policy: the browser
//            gets it the next time it starts
// Mode and palette follow the panel's (Appearance → Mode / Palette) unless set apart.
Singleton {
    id: root

    readonly property string dir: Quickshell.env("HOME") + "/.config/lagos/app-colors/staging"
    readonly property string modeSetting: Settings.v.browserMode ?? "panel"          // panel | system | dark | light
    readonly property string paletteSetting: Settings.v.browserPalette ?? "panel"    // panel | normal | inverted
    readonly property string scheme: modeSetting === "panel" ? (Theme.chosenLight ? "light" : "dark")
                                   : modeSetting === "system" ? "device" : modeSetting
    readonly property bool light: scheme === "light" || (scheme === "device" && Theme.systemLight)
    readonly property bool inverted: paletteSetting === "panel" ? Theme.chosenInverted : paletteSetting === "inverted"

    // The panel's palette rules, for the browser's own mode and palette
    ColorPalette {
        id: pal
        light: root.light
        inverted: root.inverted
        opacity: Settings.v.opacity
        wallBackground: Theme.wallBackground
        wallForeground: Theme.wallForeground
        palette: Theme.palette
    }
    function hex(c) {
        c = Qt.color(c);
        const h = v => Math.round(v * 255).toString(16).padStart(2, "0");
        return "#" + h(c.r) + h(c.g) + h(c.b);
    }
    readonly property string text: JSON.stringify({ seed: hex(pal.vivid), scheme: scheme,
                                                    variant: inverted ? "vibrant" : "tonal" }, null, 2) + "\n"
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
        path: root.dir + "/browser.json"
        atomicWrites: true
        printErrors: false
        preload: false
    }
}
