import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../common"
import "../../services"

// Settings → Modes (vault ADR-0016): pick a mode, change what it does, Save.
// A built-in you change is saved as your copy (Reset brings it back); yours
// can be deleted. Export writes ~/Downloads/<id>.lagos-mode.json, to share;
// Import lists the ones waiting there. Personal is the "no mode": nothing to edit.
ColumnLayout {
    id: root
    spacing: 10

    property string sel: Modes.isPersonal ? "work" : Modes.currentId
    property var draft: null
    property bool dirty: false
    readonly property var src: Modes.byId(sel)
    onSrcChanged: if (!dirty) load()
    onSelChanged: { dirty = false; load(); }
    function load() {
        draft = src ? JSON.parse(JSON.stringify(src)) : null;
        if (!draft) return;
        nameField.text = Modes.nameOf(draft);
        appsField.text = (draft.notifications?.apps ?? []).join(", ");
        peopleField.text = (draft.notifications?.people ?? []).join(", ");
        openField.text = (draft.open ?? []).join(", ");
        minutesField.text = String(draft.timer?.minutes ?? 60);
        const p = draft.timer?.pomodoro ?? { work: 25, break: 5, long: 15, every: 4 };
        workField.text = String(p.work); breakField.text = String(p.break);
        longField.text = String(p.long); everyField.text = String(p.every);
    }
    Component.onCompleted: load()
    function patch(o) { draft = Object.assign({}, draft, o); dirty = true; }
    function patchN(o) { patch({ notifications: Object.assign({ allow: "all", apps: [], people: [] }, draft.notifications, o) }); }
    function list(text) { return String(text).split(",").map(w => w.trim()).filter(w => w); }
    function num(text, d) { const n = parseInt(text, 10); return n > 0 ? n : d; }
    // The fields' text into the draft, then to disk
    function save() {
        const m = Object.assign({}, draft);
        m.name = nameField.text.trim() || m.name;
        m.notifications = Object.assign({}, m.notifications, { apps: list(appsField.text), people: list(peopleField.text) });
        m.open = list(openField.text);
        if (timerKind === "minutes") m.timer = { minutes: num(minutesField.text, 60) };
        else if (timerKind === "pomodoro") m.timer = { pomodoro: { work: num(workField.text, 25), break: num(breakField.text, 5), long: num(longField.text, 15), every: num(everyField.text, 4) } };
        else m.timer = null;
        Modes.save(m);
        dirty = false;
        if (Modes.currentId === m.id) BarState.say(m.icon, Tr.t("Saved · applies the next time you choose it"));
    }
    readonly property string timerKind: draft?.timer?.pomodoro ? "pomodoro" : draft?.timer?.minutes ? "minutes" : "none"
    readonly property var icons: ["", "", "", "", "", "", "", "", "", "",
                                  "", "", "", "", "", "", "", "", "", ""]

    // ---------------- Which mode ----------------
    Flow {
        Layout.fillWidth: true
        spacing: 6
        Repeater {
            model: Modes.modes.filter(m => m.id !== "personal")
            delegate: Chip {
                required property var modelData
                icon: modelData.icon
                text: Modes.nameOf(modelData) + (modelData.id === Modes.currentId ? " ●" : "")
                active: modelData.id === root.sel
                onClicked: root.sel = modelData.id
            }
        }
        Chip {
            icon: ""
            text: Tr.t("New")
            onClicked: root.sel = Modes.duplicate("personal", Tr.t("New mode"))
        }
    }

    Label { visible: !root.draft; text: Tr.t("Choose a mode"); dim: true; font.pixelSize: 12 }

    ColumnLayout {
        visible: !!root.draft
        Layout.fillWidth: true
        spacing: 10

        // ---------------- Name and icon ----------------
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Label { text: Tr.t("Name"); font.pixelSize: 12; Layout.preferredWidth: 130 }
            TextField { id: nameField; Layout.fillWidth: true; onAccepted: root.dirty = true }
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Label { text: Tr.t("Icon"); font.pixelSize: 12; Layout.preferredWidth: 130; Layout.alignment: Qt.AlignTop }
            Flow {
                Layout.fillWidth: true
                spacing: 4
                Repeater {
                    model: root.icons
                    delegate: Rectangle {
                        required property string modelData
                        width: 30; height: 30; radius: 8
                        color: root.draft?.icon === modelData ? Theme.withAlpha(Theme.accent, 0.25) : iconMouse.containsMouse ? Theme.bgHover : "transparent"
                        border.color: root.draft?.icon === modelData ? Theme.accent : Theme.border
                        Glyph { anchors.centerIn: parent; text: parent.modelData; font.pixelSize: 13 }
                        MouseArea { id: iconMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.patch({ icon: parent.modelData }) }
                    }
                }
            }
        }

        // ---------------- Notifications ----------------
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Label { text: Tr.t("Notifications"); font.pixelSize: 12; Layout.preferredWidth: 130 }
            Segmented {
                Layout.fillWidth: true
                options: [{ value: "all", label: Tr.t("All") }, { value: "list", label: Tr.t("Only some") }, { value: "none", label: Tr.t("None") }]
                value: root.draft?.notifications?.allow ?? "all"
                onSelected: v => root.patchN({ allow: v })
            }
        }
        ColumnLayout {
            visible: root.draft?.notifications?.allow === "list"
            Layout.fillWidth: true
            Layout.leftMargin: 140
            spacing: 6
            TextField { id: appsField; Layout.fillWidth: true; placeholder: Tr.t("Apps, by name: teams, outlook, calendar"); onAccepted: root.dirty = true }
            // The apps that sent something lately, to add with a click
            Flow {
                Layout.fillWidth: true
                spacing: 4
                Repeater {
                    model: [...new Set(Notifs.list.map(n => String(n.appName || "").toLowerCase()).filter(a => a))].slice(0, 12)
                    delegate: Chip {
                        required property string modelData
                        text: modelData
                        fontSize: 10
                        active: root.list(appsField.text).includes(modelData)
                        onClicked: {
                            const l = root.list(appsField.text);
                            appsField.text = (l.includes(modelData) ? l.filter(x => x !== modelData) : l.concat([modelData])).join(", ");
                            root.dirty = true;
                        }
                    }
                }
            }
            TextField { id: peopleField; Layout.fillWidth: true; placeholder: Tr.t("People, by name as they appear in the message"); onAccepted: root.dirty = true }
            Label { text: Tr.t("Always let through: critical ones, calls (if allowed), battery and system notices"); dim: true; font.pixelSize: 11; wrapMode: Text.Wrap; Layout.fillWidth: true }
        }

        // ---------------- Comms dock ----------------
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Label { text: Tr.t("Comms dock"); font.pixelSize: 12; Layout.preferredWidth: 130 }
            Segmented {
                Layout.fillWidth: true
                options: [{ value: "all", label: Tr.t("All its apps") }, { value: "some", label: Tr.t("Only some") }]
                value: Array.isArray(root.draft?.comms) ? "some" : "all"
                onSelected: v => root.patch({ comms: v === "all" ? null : (Array.isArray(root.draft.comms) ? root.draft.comms : []) })
            }
        }
        Flow {
            visible: Array.isArray(root.draft?.comms)
            Layout.fillWidth: true
            Layout.leftMargin: 140
            spacing: 4
            Repeater {
                model: Comms.allDefs
                delegate: Chip {
                    required property var modelData
                    readonly property string word: modelData.name.toLowerCase()
                    text: modelData.name
                    active: Modes.words(root.draft?.comms).some(w => (modelData.ref + " " + word).toLowerCase().includes(w))
                    onClicked: {
                        const l = Modes.words(root.draft.comms);
                        const hit = l.filter(w => (modelData.ref + " " + word).toLowerCase().includes(w));
                        root.patch({ comms: hit.length ? l.filter(w => !hit.includes(w)) : l.concat([word]) });
                    }
                }
            }
        }

        // ---------------- Switches ----------------
        Repeater {
            model: [["caffeine", "Caffeine", "On", "Off"], ["night", "Night light", "On", "Off"], ["dark", "Theme", "Dark", "Light"], ["game", "Game mode", "On", "Off"]]
            delegate: RowLayout {
                required property var modelData
                Layout.fillWidth: true
                spacing: 10
                Label { text: Tr.t(modelData[1]); font.pixelSize: 12; Layout.preferredWidth: 130 }
                Segmented {
                    Layout.fillWidth: true
                    options: [{ value: "keep", label: Tr.t("Leave it") }, { value: "on", label: Tr.t(modelData[2]) }, { value: "off", label: Tr.t(modelData[3]) }]
                    value: root.draft?.[modelData[0]] === true ? "on" : root.draft?.[modelData[0]] === false ? "off" : "keep"
                    onSelected: v => { const o = {}; o[modelData[0]] = v === "keep" ? null : v === "on"; root.patch(o); }
                }
            }
        }

        // ---------------- Apps to open ----------------
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Label { text: Tr.t("Open on entering"); font.pixelSize: 12; Layout.preferredWidth: 130 }
            TextField { id: openField; Layout.fillWidth: true; placeholder: Tr.t("Desktop entry ids: md.obsidian.Obsidian, firefox"); onAccepted: root.dirty = true }
        }

        // ---------------- Timer ----------------
        RowLayout {
            Layout.fillWidth: true
            spacing: 10
            Label { text: Tr.t("Timer"); font.pixelSize: 12; Layout.preferredWidth: 130 }
            Segmented {
                Layout.fillWidth: true
                options: [{ value: "none", label: Tr.t("None") }, { value: "minutes", label: Tr.t("Ends after") }, { value: "pomodoro", label: "Pomodoro" }]
                value: root.timerKind
                onSelected: v => root.patch({ timer: v === "minutes" ? { minutes: root.num(minutesField.text, 60) }
                                                    : v === "pomodoro" ? { pomodoro: { work: root.num(workField.text, 25), break: root.num(breakField.text, 5), long: root.num(longField.text, 15), every: root.num(everyField.text, 4) } }
                                                    : null })
            }
        }
        RowLayout {
            visible: root.timerKind === "minutes"
            Layout.leftMargin: 140
            spacing: 6
            TextField { id: minutesField; Layout.preferredWidth: 70; onAccepted: root.dirty = true }
            Label { text: Tr.t("minutes, then back to Personal"); dim: true; font.pixelSize: 11 }
        }
        GridLayout {
            visible: root.timerKind === "pomodoro"
            Layout.leftMargin: 140
            columns: 4
            columnSpacing: 6
            rowSpacing: 4
            Label { text: Tr.t("Focus"); dim: true; font.pixelSize: 11 }
            TextField { id: workField; Layout.preferredWidth: 60; onAccepted: root.dirty = true }
            Label { text: Tr.t("Break"); dim: true; font.pixelSize: 11 }
            TextField { id: breakField; Layout.preferredWidth: 60; onAccepted: root.dirty = true }
            Label { text: Tr.t("Long break"); dim: true; font.pixelSize: 11 }
            TextField { id: longField; Layout.preferredWidth: 60; onAccepted: root.dirty = true }
            Label { text: Tr.t("Every (focuses)"); dim: true; font.pixelSize: 11 }
            TextField { id: everyField; Layout.preferredWidth: 60; onAccepted: root.dirty = true }
        }

        // ---------------- Actions ----------------
        Flow {
            Layout.fillWidth: true
            Layout.topMargin: 4
            spacing: 6
            Chip { text: Tr.t("Save"); filled: true; bold: true; onClicked: root.save() }
            Chip { text: Tr.t("Use now"); icon: ""; onClicked: { if (root.dirty) root.save(); Modes.set(root.sel, ""); } }
            Chip { text: Tr.t("Duplicate"); icon: ""; onClicked: root.sel = Modes.duplicate(root.sel, Tr.t("%1 (copy)", nameField.text)) }
            Chip {
                visible: Modes.isCustom(root.sel)
                text: Modes.isBuiltin(root.sel) ? Tr.t("Reset") : Tr.t("Delete")
                icon: Modes.isBuiltin(root.sel) ? "" : ""
                tint: Theme.bad
                onClicked: { const id = root.sel; root.dirty = false; Modes.remove(id); if (!Modes.isBuiltin(id)) root.sel = "work"; }
            }
            Chip { text: Tr.t("Export"); icon: ""; onClicked: Modes.exportMode(root.sel) }
            Chip { text: Tr.t("Import…"); icon: ""; active: importBox.visible; onClicked: { importBox.visible = !importBox.visible; if (importBox.visible) Modes.findImportable(); } }
        }
        ColumnLayout {
            id: importBox
            visible: false
            Layout.fillWidth: true
            spacing: 4
            Label { text: Tr.t("Mode files in ~/Downloads (*.lagos-mode.json): click one to add it"); dim: true; font.pixelSize: 11; wrapMode: Text.Wrap; Layout.fillWidth: true }
            Label { visible: !Modes.importable.length; text: Tr.t("None found"); dim: true; font.pixelSize: 11 }
            Flow {
                Layout.fillWidth: true
                spacing: 4
                Repeater {
                    model: Modes.importable
                    delegate: Chip {
                        required property string modelData
                        text: modelData.split("/").pop()
                        icon: ""
                        onClicked: { Modes.importFile(modelData); importBox.visible = false; }
                    }
                }
            }
        }
        Label {
            visible: root.dirty
            text: Tr.t("Unsaved changes")
            color: Theme.warn
            font.pixelSize: 11
        }
    }
}
