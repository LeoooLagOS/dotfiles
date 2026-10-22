import QtQuick
import Quickshell
import Quickshell.Widgets
import "../common"
import "../services"

// The right twin (TopBar.qml: from the readings to the same gap before the
// center as the window title's). First, the reminder: whatever is urgent
// (Events.soon: what's due within a few hours or overdue, an event about to
// start; Settings → Weather & calendar → Reminders), tinted by its urgency.
// Else the player while something plays (Media.active, still true 20 s after
// a pause): the art, title and artist; `noPlayer` skips it while the island
// grown shows the player. Else the next event of the calendar
// (services/Events.qml, the next 7 days) going on or still to come: its title,
// then when ("now · until 17:00", "in 20 min", "16:00 · in 2 h", "tomorrow
// 09:00", "Fri 09:00", "today" for all day) and where; with none, the first
// open to-do (services/Todos.qml); with neither, that the week is free.
// Scrolls when it doesn't fit (bar/Marquee.qml).
// Click: the Calendar tab (music: the Media tab) · middle click (music): play / pause.
BarPill {
    id: root
    property int fixedWidth: 340
    property bool hide: false
    property bool noPlayer: false               // the island grown shows the player
    signal openTab(string name)
    readonly property var urgent: Events.soon
    readonly property var player: Media.player
    readonly property bool music: !urgent && Media.active && !noPlayer

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
    // 0 today, 1 tomorrow…
    function daysTo(date) {
        const d = at(date, "12:00"), t = new Date(now);
        t.setHours(12, 0, 0, 0);
        return Math.round((d - t) / 86400000);
    }
    // "today" · "tomorrow" · "Fri"
    function dayName(date) {
        const days = daysTo(date);
        return days <= 0 ? Tr.t("today") : days === 1 ? Tr.t("tomorrow") : Tr.date(at(date, "12:00"), "ddd");
    }
    function whenOf(e) {
        if (e.allDay) return dayName(e.date);
        const start = at(e.date, e.start);
        if (start <= now) return e.end ? Tr.t("now · until %1", e.end) : Tr.t("now");
        const mins = Math.round((start - now) / 60000);
        if (mins < 60) return Tr.t("in %1 min", mins);
        const day = dayName(e.date);
        if (daysTo(e.date) <= 0) return e.start + " · " + Tr.t("in %1 h", Math.round(mins / 60));
        return day + " " + e.start;
    }
    readonly property string line: event
        ? "<b>" + esc(event.title) + "</b>  ·  " + esc(whenOf(event)) + (event.location ? "  ·  " + esc(event.location) : "")
        : todo ? "<b>" + esc(todo.text) + "</b>" + (Todos.isOverdue(todo) ? "  ·  " + Tr.t("overdue") : todo.due ? "  ·  " + Tr.t("due %1", esc(dayName(todo.due))) : "")
        : Tr.t("Nothing on the calendar this week")

    implicitWidth: fixedWidth
    opacity: hide ? 0 : 1
    Behavior on opacity { NumberAnimation { duration: 160 } }
    clip: true
    color: urgent ? Theme.withAlpha(urgent.color, hovered ? 0.30 : 0.20)
         : clickable && hovered ? Theme.bgHover : islands ? Theme.bg : "transparent"
    border.color: urgent ? Theme.withAlpha(urgent.color, 0.6) : Theme.border
    clickable: !hide
    onClicked: b => {
        if (music && b === Qt.MiddleButton) player.togglePlaying();
        else root.openTab(music ? "Media" : "Calendar");
    }

    Item {
        id: icon
        width: 18
        height: 18
        anchors.verticalCenter: parent.verticalCenter
        ClippingRectangle {
            anchors.fill: parent
            visible: root.music
            radius: 5
            color: BarState.accent
            Image {
                anchors.fill: parent
                source: root.music ? root.player?.trackArtUrl ?? "" : ""
                fillMode: Image.PreserveAspectCrop
                sourceSize: Qt.size(36, 36)
                asynchronous: true
            }
        }
        Glyph {
            anchors.centerIn: parent
            optical: true
            visible: !root.music
            text: root.urgent ? root.urgent.icon : root.todo ? "\uf0ae" : "\uf073"
            font.pixelSize: 14
            color: root.urgent ? root.urgent.color : BarState.accent
        }
    }
    Marquee {
        textFormat: Text.StyledText
        text: root.urgent ? "<b>" + root.esc(root.urgent.text) + "</b>"
            : root.music ? "<b>" + root.esc(root.player?.trackTitle) + "</b>"
                           + (root.player?.trackArtist ? "  ·  " + root.esc(root.player.trackArtist) : "")
            : root.line
        dim: !root.urgent && !root.music && !root.event && !root.todo
        width: Math.min(implicitWidth, Math.max(0, root.fixedWidth - 2 * root.pad - icon.width - root.spacing))
        anchors.verticalCenter: parent.verticalCenter
    }
}
