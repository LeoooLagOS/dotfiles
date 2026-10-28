import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import "../common"
import "../services"

// The start menu: drops from the distro logo (BarState.startOn), like Windows'
// Start. Search and pinned apps (right click: pin / unpin), all apps, the
// flavor's mode (services/Flavors.qml: its audio and its apps), the style
// (services/Styles.qml) and light / dark, and who / settings / lock / power.
// The mouse path; every part shows its keyboard path next to it, and the rofi
// menus keep working on their own keys (ADR-0014): SUPER D apps, SUPER ALT F
// flavors, SUPER X the Win+X system menu (also from the footer).
// SUPER alone opens it too (a release bind in user_keybinds.lua).
// Keyboard: typing searches, ↑/↓ and Enter in the list, Tab through the rest,
// Esc clears the search, then closes.
PanelWindow {
    id: root
    property var barWindow: null
    property string screenName: ""
    readonly property bool open: screenName !== "" && BarState.startOn === screenName

    visible: open || card.opacity > 0
    color: "transparent"
    exclusionMode: ExclusionMode.Normal
    anchors { top: true; left: true }
    margins { top: 6; left: 8 }
    implicitWidth: 480
    implicitHeight: card.implicitHeight + 2
    WlrLayershell.namespace: "quickshell:start-menu"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    PopupGrab {
        open: root.open
        windows: [root, root.barWindow]
        onClose: root.close()
    }

    function close() { BarState.startOn = ""; }
    function run(cmd) { close(); Quickshell.execDetached(["bash", "-c", cmd]); }
    // Through Hyprland, so the app isn't a child of the panel (as Comms does)
    function launch(id) {
        close();
        Quickshell.execDetached(["hyprctl", "dispatch", `hl.dsp.exec_cmd("gtk-launch ${id}.desktop")`]);
    }
    function iconOf(e) { return Quickshell.iconPath(e?.icon ?? "", true) || Quickshell.iconPath("application-x-executable", true); }

    // ---------------- Apps ----------------
    readonly property var apps: DesktopEntries.applications.values.filter(e => !e.noDisplay)
        .sort((a, b) => a.name.localeCompare(b.name))
    // Pinned: Settings.v.startPinned (desktop ids); null = these, the ones installed
    readonly property var defaultPins: ["thunar", "kitty", "one.ablaze.floorp", "org.mozilla.firefox", "com.brave.Browser",
                                        "com.spotify.Client", "org.kde.okular", "org.mixxx.Mixxx"]
    readonly property var pinned: (Settings.v.startPinned ?? defaultPins).map(id => DesktopEntries.byId(id)).filter(e => !!e)
    function togglePin(e) {
        const ids = pinned.map(p => p.id);
        Settings.set("startPinned", ids.includes(e.id) ? ids.filter(i => i !== e.id) : ids.concat([e.id]));
    }

    property bool showAll: false
    readonly property string query: search.text.trim().toLowerCase()
    readonly property bool listing: query !== "" || showAll
    // A name that starts with the words first, then any that contains them
    readonly property var results: {
        if (query === "") return showAll ? apps : [];
        const words = e => (e.name + " " + (e.genericName ?? "") + " " + (e.keywords ?? []).join(" ")).toLowerCase();
        const hits = apps.filter(e => words(e).includes(query));
        return hits.filter(e => e.name.toLowerCase().startsWith(query))
            .concat(hits.filter(e => !e.name.toLowerCase().startsWith(query)));
    }
    property int sel: 0
    onResultsChanged: sel = 0

    onOpenChanged: if (open) {
        search.text = "";
        showAll = false;
        Flavors.refresh();
        Qt.callLater(search.focusInput);
    }

    // A keybind, the way the keyboard path is shown next to the mouse one
    component Kbd: Rectangle {
        property string keys: ""
        implicitWidth: kbdText.implicitWidth + 10
        implicitHeight: 18
        radius: 5
        color: "transparent"
        border.color: Theme.border
        Label { id: kbdText; anchors.centerIn: parent; text: parent.keys; dim: true; font.pixelSize: 9; font.weight: Font.DemiBold }
    }
    component Section: RowLayout {
        id: section
        property string title: ""
        property string keys: ""
        Layout.fillWidth: true
        Layout.topMargin: 4
        Label { text: section.title; dim: true; font.pixelSize: 11; font.weight: Font.DemiBold; Layout.fillWidth: true }
        Kbd { keys: section.keys; visible: section.keys !== "" }
    }

    Rectangle {
        id: card
        width: parent.width
        implicitHeight: col.implicitHeight + 28
        radius: 18
        color: Theme.bg
        border.color: Theme.border
        opacity: root.open ? 1 : 0
        scale: root.open ? 1 : 0.97
        transformOrigin: Item.TopLeft
        Behavior on opacity { NumberAnimation { duration: 140 } }
        Behavior on scale { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }

        Keys.onEscapePressed: { if (root.showAll && search.text === "") root.showAll = false; else root.close(); }
        Keys.onDownPressed: if (root.listing) root.sel = Math.min(root.sel + 1, root.results.length - 1)
        Keys.onUpPressed: if (root.listing) root.sel = Math.max(root.sel - 1, 0)

        ColumnLayout {
            id: col
            x: 14
            y: 14
            width: parent.width - 28
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                TextField {
                    id: search
                    Layout.fillWidth: true
                    implicitHeight: 36
                    icon: "\uf002"
                    placeholder: Tr.t("Search apps")
                    onAccepted: if (root.results[root.sel]) root.launch(root.results[root.sel].id)
                }
                Kbd { keys: "SUPER D" }
            }

            // ---------------- Search results / all apps ----------------
            RowLayout {
                visible: root.showAll && root.query === ""
                Layout.fillWidth: true
                Label { text: Tr.t("All apps"); dim: true; font.pixelSize: 11; font.weight: Font.DemiBold; Layout.fillWidth: true }
                Chip { text: Tr.t("Back"); icon: "\uf053"; onClicked: root.showAll = false }
            }
            ListView {
                id: list
                visible: root.listing
                Layout.fillWidth: true
                implicitHeight: Math.min(contentHeight, 380)
                clip: true
                model: root.results
                currentIndex: root.sel
                boundsBehavior: Flickable.StopAtBounds
                onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)
                delegate: Rectangle {
                    required property var modelData
                    required property int index
                    width: list.width
                    implicitHeight: 40
                    radius: 10
                    color: index === root.sel ? Theme.withAlpha(Theme.accent, 0.18) : rowMouse.containsMouse ? Theme.bgHover : "transparent"
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 10
                        IconImage { implicitSize: 24; source: root.iconOf(modelData) }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Label { text: modelData.name; font.pixelSize: 12; Layout.fillWidth: true; elide: Text.ElideRight }
                            Label { visible: !!modelData.genericName; text: modelData.genericName ?? ""; dim: true; font.pixelSize: 10; Layout.fillWidth: true; elide: Text.ElideRight }
                        }
                        Glyph { visible: root.pinned.some(p => p.id === modelData.id); text: "\uf08d"; font.pixelSize: 10; color: Theme.fgDim }
                    }
                    MouseArea {
                        id: rowMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton
                        onClicked: m => m.button === Qt.RightButton ? root.togglePin(modelData) : root.launch(modelData.id)
                    }
                }
            }
            Label {
                visible: root.query !== "" && root.results.length === 0
                text: Tr.t("No apps match")
                dim: true
                font.pixelSize: 12
                Layout.alignment: Qt.AlignHCenter
                Layout.margins: 12
            }

            // ---------------- Home: pinned, mode, style ----------------
            ColumnLayout {
                visible: !root.listing
                Layout.fillWidth: true
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    Label { text: Tr.t("Pinned"); dim: true; font.pixelSize: 11; font.weight: Font.DemiBold; Layout.fillWidth: true }
                    Chip { text: Tr.t("All apps"); icon: "\uf054"; onClicked: root.showAll = true }
                }
                GridLayout {
                    Layout.fillWidth: true
                    columns: 5
                    columnSpacing: 4
                    rowSpacing: 4
                    Repeater {
                        model: root.pinned
                        delegate: Rectangle {
                            id: tile
                            required property var modelData
                            Layout.fillWidth: true
                            implicitHeight: 70
                            radius: 12
                            color: tileMouse.containsMouse || activeFocus ? Theme.bgHover : "transparent"
                            activeFocusOnTab: true
                            Keys.onReturnPressed: root.launch(modelData.id)
                            Keys.onEnterPressed: root.launch(modelData.id)
                            ColumnLayout {
                                anchors.centerIn: parent
                                width: parent.width - 8
                                spacing: 5
                                IconImage { implicitSize: 30; source: root.iconOf(tile.modelData); Layout.alignment: Qt.AlignHCenter }
                                Label { text: tile.modelData.name; font.pixelSize: 10; elide: Text.ElideRight; horizontalAlignment: Text.AlignHCenter; Layout.fillWidth: true }
                            }
                            MouseArea {
                                id: tileMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                acceptedButtons: Qt.LeftButton | Qt.RightButton
                                onClicked: m => m.button === Qt.RightButton ? root.togglePin(tile.modelData) : root.launch(tile.modelData.id)
                            }
                            FocusRing {}
                        }
                    }
                }
                Label {
                    visible: root.pinned.length === 0
                    text: Tr.t("Right click an app in All apps to pin it here")
                    dim: true
                    font.pixelSize: 11
                }

                // The flavor's mode: its audio, and its apps one click away
                Section { title: Tr.t("Mode"); keys: "SUPER ALT F"; visible: Flavors.installed.length > 0 }
                Flow {
                    visible: Flavors.installed.length > 0
                    Layout.fillWidth: true
                    spacing: 6
                    Repeater {
                        model: Flavors.installed
                        delegate: Chip {
                            required property var modelData
                            icon: modelData.icon
                            text: modelData.name
                            active: modelData.active
                            onClicked: Flavors.set(modelData.id)
                        }
                    }
                }
                Label {
                    visible: Flavors.installed.length > 0
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    dim: true
                    font.pixelSize: 11
                    text: Flavors.current ? Flavors.current.audio : Tr.t("Pick what you're going to do: the sound adjusts to it")
                }
                Flow {
                    visible: (Flavors.current?.apps.length ?? 0) > 0
                    Layout.fillWidth: true
                    spacing: 6
                    Repeater {
                        model: Flavors.current?.apps ?? []
                        delegate: Chip {
                            required property var modelData
                            icon: "\uf04b"
                            text: modelData.name
                            onClicked: root.launch(modelData.id)
                        }
                    }
                }

                // The style, and light / dark apart (any style takes either)
                Section { title: Tr.t("Style") }
                Flow {
                    Layout.fillWidth: true
                    spacing: 6
                    Repeater {
                        model: Styles.presets
                        delegate: Chip {
                            required property var modelData
                            icon: modelData.icon
                            text: modelData.name
                            active: Styles.current?.id === modelData.id
                            onClicked: Styles.apply(modelData.id)
                        }
                    }
                }
                Label {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    dim: true
                    font.pixelSize: 11
                    text: Styles.current ? Styles.current.description : Tr.t("Your own: changed in Settings")
                }
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Segmented {
                        Layout.fillWidth: true
                        options: [{ value: "system", label: Tr.t("Follow system") },
                                  { value: "dark", label: Tr.t("Dark"), icon: "\uf186" },
                                  { value: "light", label: Tr.t("Light"), icon: "\uf185" }]
                        value: Settings.v.mode
                        onSelected: v => Theme.setMode(v)
                    }
                    Chip { text: Tr.t("More"); icon: "\uf141"; onClicked: { root.close(); PanelState.open = true; PanelState.openSettings("appearance"); } }
                }
            }

            // ---------------- Who, the system menu, settings, lock, power ----------------
            Rectangle { Layout.fillWidth: true; Layout.topMargin: 4; implicitHeight: 1; color: Theme.border }
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                ClippingRectangle {
                    implicitWidth: 30
                    implicitHeight: 30
                    radius: 15
                    color: Theme.accent2
                    Label { anchors.centerIn: parent; visible: avatar.status !== Image.Ready; text: Profile.initials; color: Theme.accent2Text; font.pixelSize: 11; font.weight: Font.DemiBold }
                    Image { id: avatar; anchors.fill: parent; source: Profile.avatar; fillMode: Image.PreserveAspectCrop; sourceSize: Qt.size(60, 60); visible: status === Image.Ready }
                }
                Label { text: Profile.fullName; font.pixelSize: 12; font.weight: Font.DemiBold; Layout.fillWidth: true; elide: Text.ElideRight }
                // The Win+X menu, by mouse too
                Chip { text: Tr.t("System menu"); icon: "\uf0c9"; onClicked: root.run("$HOME/.config/hypr/scripts/RofiSystemMenu.sh") }
                Kbd { keys: "SUPER X" }
                IconButton { icon: "\uf013"; iconSize: 13; implicitWidth: 32; implicitHeight: 30; onClicked: { root.close(); PanelState.open = true; PanelState.openSettings("appearance"); } }
                IconButton { icon: "\uf023"; iconSize: 12; implicitWidth: 32; implicitHeight: 30; onClicked: root.run(Config.lockCmd) }
                IconButton { icon: "\uf011"; iconSize: 12; implicitWidth: 32; implicitHeight: 30; iconColor: Theme.bad; onClicked: root.run(Config.powerCmd) }
            }
        }
    }
}
