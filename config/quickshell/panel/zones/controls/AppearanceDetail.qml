import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../common"
import "../../services"

// DETAIL: the look, top to bottom:
//   SYSTEM             GTK / Qt apps' light or dark (scripts/wm/SystemMode.sh: only that, at once),
//                      and what "System" means below
//   PANEL & LAUNCHERS  same settings as Settings → Appearance → Panel & launchers (that page
//                      also picks which launchers follow it)
//   APPS               each app chosen in Settings → Appearance → In the Appearance panel: lagOS
//                      colors (its own mode and palette, "Panel" following the ones above) or
//                      vanilla (its stock look, light or dark like the system). Same settings as
//                      Settings → Wallpaper → Apps that follow the colors
//     browsers   appColorsBrowsers (+ Firefox's) · browserMode / browserPalette (services/BrowserTheme.qml)
//     obsidian   appColorsObsidian · obsidianMode / obsidianPalette (services/ObsidianTheme.qml)
Zone {
    id: root
    // The apps that can take a look of their own: name, icon, the switch(es) for lagOS colors
    // (off: vanilla) and their mode and palette settings
    readonly property var apps: ({
        browsers: { label: Tr.t("Browsers"), icon: "\uf0ac", on: ["appColorsBrowsers", "appColorsFirefox"],
                    mode: "browserMode", palette: "browserPalette" },
        obsidian: { label: "Obsidian", icon: "\uf02d", on: ["appColorsObsidian"],
                    mode: "obsidianMode", palette: "obsidianPalette" }
    })
    title: Tr.t("Appearance")
    scrollable: true                    // with apps below, it can outgrow the card
    icon: Theme.chosenLight ? "" : ""
    closable: true
    ColumnLayout {
        width: parent.width
        spacing: 8

        // ---------------- System ----------------
        Label { text: Tr.t("SYSTEM"); dim: true; font.pixelSize: 11; font.weight: Font.DemiBold; font.letterSpacing: 1 }
        Segmented {
            Layout.fillWidth: true
            value: Theme.systemLight ? "light" : "dark"
            options: [{ value: "dark", label: Tr.t("Dark"), icon: "" }, { value: "light", label: Tr.t("Light"), icon: "" }]
            onSelected: v => Quickshell.execDetached([Quickshell.env("HOME") + "/.config/hypr/scripts/SystemMode.sh",
                                                     v === "light" ? "Light" : "Dark"])
        }
        Label {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            dim: true
            font.pixelSize: 11
            text: Tr.t("GTK and Qt apps, and whatever is set to System below.")
        }

        // ---------------- Panel & launchers ----------------
        Label { text: Tr.t("PANEL & LAUNCHERS"); dim: true; font.pixelSize: 11; font.weight: Font.DemiBold; font.letterSpacing: 1; Layout.topMargin: 6 }
        Label { text: Tr.t("MODE"); dim: true; font.pixelSize: 11; font.weight: Font.DemiBold; font.letterSpacing: 1 }
        Segmented {
            Layout.fillWidth: true
            value: Theme.modeSetting
            options: [{ value: "system", label: Tr.t("System") }, { value: "dark", label: Tr.t("Dark"), icon: "" },
                      { value: "light", label: Tr.t("Light"), icon: "" }]
            onSelected: v => Theme.setMode(v)
        }
        Label { text: Tr.t("PALETTE"); dim: true; font.pixelSize: 11; font.weight: Font.DemiBold; font.letterSpacing: 1 }
        Segmented {
            Layout.fillWidth: true
            value: Theme.chosenInverted
            options: [{ value: false, label: Tr.t("Normal") }, { value: true, label: Tr.t("Inverted") }]
            onSelected: v => Theme.setInverted(v)
        }
        Label { text: Tr.t("APPLY TO"); dim: true; font.pixelSize: 11; font.weight: Font.DemiBold; font.letterSpacing: 1 }
        Segmented {
            Layout.fillWidth: true
            value: Theme.scope
            options: [{ value: "panel", label: Tr.t("Panel") }, { value: "both", label: Tr.t("Both") }, { value: "launchers", label: Tr.t("Launchers") }]
            onSelected: v => Settings.set("themeScope", v)
        }
        Label {
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            dim: true
            font.pixelSize: 11
            text: Tr.t("Launchers are the Rofi menus. The rest keeps the system theme.")
        }
        Chip { text: Tr.t("Choose launchers"); icon: ""; onClicked: PanelState.openSettings("appearance") }

        // ---------------- Apps ----------------
        // What each app's three rows mean, once above them
        Label {
            visible: (Settings.v.appearanceApps ?? []).some(k => root.apps[k])
            Layout.fillWidth: true
            Layout.topMargin: 6
            wrapMode: Text.Wrap
            dim: true
            font.pixelSize: 11
            text: Tr.t("For each app: lagOS colors or its own (Vanilla, light or dark like the system); then its mode and its palette. Panel: the same as above.")
        }
        // The apps chosen in Settings → Appearance → In the Appearance panel
        Repeater {
            model: (Settings.v.appearanceApps ?? []).filter(k => root.apps[k])
            delegate: ColumnLayout {
                id: appCol
                required property string modelData
                readonly property var app: root.apps[modelData]
                readonly property bool lagos: Settings.v[app.on[0]] ?? true
                Layout.fillWidth: true
                Layout.topMargin: 6
                spacing: 6
                RowLayout {
                    spacing: 6
                    Glyph { text: appCol.app.icon; font.pixelSize: 11; color: Theme.fgDim }
                    Label { text: appCol.app.label.toUpperCase(); dim: true; font.pixelSize: 11; font.weight: Font.DemiBold; font.letterSpacing: 1 }
                }
                // lagOS colors or its stock look (the switch scripts/AppColors.sh follows)
                Segmented {
                    Layout.fillWidth: true
                    value: appCol.lagos
                    options: [{ value: true, label: Tr.t("lagOS colors") }, { value: false, label: Tr.t("Vanilla") }]
                    onSelected: v => appCol.app.on.forEach(k => Settings.set(k, v))
                }
                Segmented {
                    visible: appCol.lagos
                    Layout.fillWidth: true
                    value: Settings.v[appCol.app.mode] ?? "panel"
                    options: [{ value: "panel", label: Tr.t("Panel") }, { value: "system", label: Tr.t("System") },
                              { value: "dark", label: Tr.t("Dark") }, { value: "light", label: Tr.t("Light") }]
                    onSelected: v => Settings.set(appCol.app.mode, v)
                }
                Segmented {
                    visible: appCol.lagos
                    Layout.fillWidth: true
                    value: Settings.v[appCol.app.palette] ?? "panel"
                    options: [{ value: "panel", label: Tr.t("Panel") }, { value: "normal", label: Tr.t("Normal") },
                              { value: "inverted", label: Tr.t("Inverted") }]
                    onSelected: v => Settings.set(appCol.app.palette, v)
                }
            }
        }
    }
}
