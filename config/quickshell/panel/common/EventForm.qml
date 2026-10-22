import QtQuick
import QtQuick.Layouts
import "../services"

// Form to create a local event (saved to ~/.config/lagos/calendars/panel.ics
// through Events.add). Date defaults to the day selected in the calendar.
Item {
    id: root
    signal done()

    Keys.onEscapePressed: event => { done(); event.accepted = true; }

    property bool allDay: false
    property int reminder: 15

    readonly property bool dateOk: /^\d{4}-\d{2}-\d{2}$/.test(date.text) && !isNaN(new Date(date.text + "T12:00"))
    readonly property bool startOk: allDay || /^([01]?\d|2[0-3]):[0-5]\d$/.test(start.text)
    readonly property bool endOk: allDay || end.text === "" || /^([01]?\d|2[0-3]):[0-5]\d$/.test(end.text)
    readonly property bool valid: title.text.trim() !== "" && dateOk && startOk && endOk

    function pad(t) { const [h, m] = t.split(":"); return String(h).padStart(2, "0") + ":" + m; }

    function reset() {
        title.text = ""; location.text = "";
        date.text = Events.key(Events.selected);
        const now = new Date();
        const h = (now.getHours() + 1) % 24;
        start.text = String(h).padStart(2, "0") + ":00";
        end.text = String((h + 1) % 24).padStart(2, "0") + ":00";
        allDay = false; reminder = 15;
        title.focusInput();
    }
    onVisibleChanged: if (visible) reset()

    function save() {
        if (!valid) return;
        Events.add({
            title: title.text.trim(), date: date.text, allDay: allDay,
            start: allDay ? "" : pad(start.text), end: allDay || !end.text ? "" : pad(end.text),
            location: location.text.trim(), reminder: allDay ? 0 : reminder
        });
        done();
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        Label { text: Tr.t("New event"); font.pixelSize: 15; font.weight: Font.DemiBold }

        TextField { id: title; Layout.fillWidth: true; placeholder: Tr.t("Title"); icon: ""; onAccepted: root.save() }

        // Date + quick picks
        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            TextField { id: date; Layout.fillWidth: true; placeholder: "YYYY-MM-DD"; icon: ""; invalid: date.text !== "" && !root.dateOk }
            Repeater {
                model: [{ label: Tr.t("Today"), days: 0 }, { label: Tr.t("Tomorrow"), days: 1 }]
                delegate: Chip {
                    required property var modelData
                    implicitHeight: 30
                    radius: 10
                    text: modelData.label
                    onClicked: { const d = new Date(); d.setDate(d.getDate() + modelData.days); date.text = Events.key(d); }
                }
            }
        }

        // All day toggle + times
        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            Chip {
                implicitHeight: 30
                radius: 10
                icon: root.allDay ? "\uf14a" : "\uf096"
                text: Tr.t("All day")
                active: root.allDay
                onClicked: root.allDay = !root.allDay
            }
            TextField { id: start; Layout.fillWidth: true; visible: !root.allDay; placeholder: Tr.t("Start 09:00"); icon: ""; invalid: !root.startOk }
            TextField { id: end; Layout.fillWidth: true; visible: !root.allDay; placeholder: Tr.t("End"); invalid: !root.endOk }
        }

        TextField { id: location; Layout.fillWidth: true; placeholder: Tr.t("Location (optional)"); icon: ""; onAccepted: root.save() }

        // Reminder
        RowLayout {
            Layout.fillWidth: true
            visible: !root.allDay
            spacing: 8
            z: 2
            Label { text: Tr.t("Remind me"); dim: true; font.pixelSize: 11 }
            Dropdown {
                icon: ""
                value: root.reminder
                listWidth: 140
                options: [
                    { label: Tr.t("No reminder"), value: 0 }, { label: Tr.t("5 min before"), value: 5 },
                    { label: Tr.t("10 min before"), value: 10 }, { label: Tr.t("15 min before"), value: 15 },
                    { label: Tr.t("30 min before"), value: 30 }, { label: Tr.t("1 hour before"), value: 60 }
                ]
                onSelected: v => root.reminder = v
            }
            Item { Layout.fillWidth: true }
        }

        Item { Layout.fillHeight: true }

        Label {
            Layout.fillWidth: true
            visible: Events.lastError !== ""
            text: Events.lastError
            color: Theme.bad
            font.pixelSize: 11
            wrapMode: Text.Wrap
        }

        // Save
        Chip {
            Layout.fillWidth: true
            implicitHeight: 34
            radius: 10
            filled: true
            bold: true
            enabled: root.valid
            text: Tr.t("Save event")
            onClicked: root.save()
        }
    }
}
