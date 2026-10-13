import QtQuick
import Quickshell
import "../common"
import "../services"

// The left twin's other face (TopBar.qml). First, whatever is urgent
// (Events.soon: what's due within a few hours or overdue, an event about to
// start; Settings → Weather & calendar → Reminders), over the window title,
// tinted by its urgency. Then a video call (Call.onLeft): the app, the
// meeting and its microphone / camera buttons (bar/CallButtons.qml; click: its
// window). Else, on an empty workspace, the next event of the calendar
// (services/Events.qml, the next 7 days) going on or still to come: its title,
// then when ("now · until 17:00", "in 20 min", "16:00 · in 2 h", "tomorrow
// 09:00", "Fri 09:00", "today" for all day) and where; with none, the first
// open to-do (services/Todos.qml); with neither, that the week is free.
// Scrolls when it doesn't fit (bar/Marquee.qml). Click: the Calendar tab.
BarPill {
    id: root
    property int fixedWidth: 340
    property bool hide: false
    signal openTab(string name)
    readonly property var urgent: Events.soon
    readonly property bool call: !urgent && Call.onLeft

    readonly property date now: clock.date
    SystemClock { id: clock; precision: SystemClock.Minutes }

    function dayKey(d) {
        return d.getFullYear() + "-" + String(d.getMonth() + 1).padStart(2, "0") + "-" + String(d.getDate()).padStart(2, "0");
    }
    function at(date, hm) { return new Date(date + "T" + (hm || "00:00")); }
    // The first event not over yet
    readonly property var event: {
        const today = dayKey(now);
        return Events.upcoming.find(e => e.allDay ? e.date >= today
                                                  : at(e.date, e.end || e.start) > now) ?? null;
    }
    readonly property var todo: event ? null : Todos.sorted("all").find(i => !i.done) ?? null
    function esc(s) { return String(s ?? "").replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;"); }
    // "today" · "tomorrow" · "Fri"
    function dayName(date) {
        const d = at(date, "12:00"), t = new Date(now);
        t.setHours(12, 0, 0, 0);
        const days = Math.round((d - t) / 86400000);
        return days <= 0 ? "today" : days === 1 ? "tomorrow" : Qt.formatDate(d, "ddd");
    }
    function whenOf(e) {
        if (e.allDay) return dayName(e.date);
        const start = at(e.date, e.start);
        if (start <= now) return e.end ? "now · until " + e.end : "now";
        const mins = Math.round((start - now) / 60000);
        if (mins < 60) return "in " + mins + " min";
        const day = dayName(e.date);
        if (day === "today") return e.start + " · in " + Math.round(mins / 60) + " h";
        return day + " " + e.start;
    }
    readonly property string line: event
        ? "<b>" + esc(event.title) + "</b>  ·  " + esc(whenOf(event)) + (event.location ? "  ·  " + esc(event.location) : "")
        : todo ? "<b>" + esc(todo.text) + "</b>" + (Todos.isOverdue(todo) ? "  ·  overdue" : todo.due ? "  ·  due " + esc(dayName(todo.due)) : "")
        : "Nothing on the calendar this week"

    implicitWidth: fixedWidth
    opacity: hide ? 0 : 1
    Behavior on opacity { NumberAnimation { duration: 160 } }
    clip: true
    color: urgent ? Theme.withAlpha(urgent.color, hovered ? 0.30 : 0.20)
         : clickable && hovered ? Theme.bgHover : islands ? Theme.bg : "transparent"
    border.color: urgent ? Theme.withAlpha(urgent.color, 0.6) : Theme.border
    clickable: !hide
    onClicked: root.call ? Call.show() : root.openTab("Calendar")

    Glyph {
        id: icon
        optical: true
        text: root.urgent ? root.urgent.icon : root.call ? "\u{f0567}" : root.todo ? "" : ""
        font.pixelSize: 14
        color: root.urgent ? root.urgent.color : BarState.accent
        anchors.verticalCenter: parent.verticalCenter
    }
    Marquee {
        textFormat: Text.StyledText
        text: root.urgent ? "<b>" + root.esc(root.urgent.text) + "</b>"
            : root.call ? "<b>" + root.esc(Call.name) + "</b>" + (Call.detail ? "  ·  " + root.esc(Call.detail) : "")
            : root.line
        dim: !root.urgent && !root.call && !root.event && !root.todo
        width: Math.min(implicitWidth, Math.max(0, root.fixedWidth - 2 * root.pad - icon.width - root.spacing
                           - (callButtons.visible ? callButtons.width + root.spacing : 0)))
        anchors.verticalCenter: parent.verticalCenter
    }
    CallButtons {
        id: callButtons
        visible: root.call
        anchors.verticalCenter: parent.verticalCenter
    }
}
