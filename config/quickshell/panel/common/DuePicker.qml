import QtQuick
import QtQuick.Layouts
import "When.js" as When

// When a to-do is due, set in one tap: Today · Tomorrow · the next weekdays ·
// Next week · No date, or typed ("vie 18:00", "15 oct", "mañana 9am":
// common/When.js); and whether it repeats.
//   DuePicker { due: "2026-10-16"; time: ""; repeat: ""; onPicked: (due, time) => …; onRepeatPicked: r => … }
ColumnLayout {
    id: root
    property string due: ""
    property string time: ""
    property string repeat: ""
    signal picked(string due, string time)
    signal repeatPicked(string repeat)
    spacing: 6

    function dayKey(n) { const d = new Date(); d.setHours(12, 0, 0, 0); d.setDate(d.getDate() + n); return When.parse("hoy", d).date; }
    readonly property var days: {
        const out = [{ label: Tr.t("Today"), due: dayKey(0) }, { label: Tr.t("Tomorrow"), due: dayKey(1) }];
        for (let n = 2; n <= 5; n++) out.push({ label: Tr.date(new Date(dayKey(n) + "T12:00"), "ddd"), due: dayKey(n) });
        const mon = ((8 - new Date().getDay()) % 7) || 7;
        out.push({ label: Tr.t("Next week"), due: dayKey(mon) });
        out.push({ label: Tr.t("No date"), due: "" });
        return out;
    }

    Flow {
        Layout.fillWidth: true
        spacing: 4
        Repeater {
            model: root.days
            delegate: Chip {
                required property var modelData
                implicitHeight: 22
                fontSize: 10
                text: modelData.label
                active: root.due === modelData.due
                onClicked: root.picked(modelData.due, modelData.due ? root.time : "")
            }
        }
    }
    TextField {
        id: typed
        Layout.fillWidth: true
        implicitHeight: 26
        icon: ""
        placeholder: Tr.t("Or type it: “vie 18:00”, “15 oct”, “mañana 9am”")
        readonly property var parsed: text.trim() ? When.parse(text + " #task") : null
        invalid: !!parsed && !parsed.date
        onAccepted: if (parsed?.date) { root.picked(parsed.date, parsed.start); text = ""; }
    }
    Flow {
        Layout.fillWidth: true
        spacing: 4
        Repeater {
            model: [["", Tr.t("Once")], ["daily", Tr.t("Daily")], ["weekdays", Tr.t("Weekdays")], ["weekly", Tr.t("Weekly")], ["monthly", Tr.t("Monthly")]]
            delegate: Chip {
                required property var modelData
                implicitHeight: 22
                fontSize: 10
                icon: modelData[0] ? "" : ""
                text: modelData[1]
                tint: Theme.accent2
                active: root.repeat === modelData[0]
                onClicked: root.repeatPicked(modelData[0])
            }
        }
    }
}
