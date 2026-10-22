import QtQuick
import QtQuick.Layouts
import "../services"

// A day as a timeline (AgendaZone's Timeline view): the hours down the side,
// each event a block at its time (overlapping ones side by side), the free
// gaps of half an hour or more marked "Free 1 h 30", what's due that day as a
// flag at its time, and on today a line at the current time (scrolled to it).
// All-day events go above, as chips.
//   DayTimeline { day: Events.selected; width: …; height: … }
Item {
    id: root
    property date day: new Date()
    readonly property bool isToday: Events.key(day) === Events.key(Events.now)
    readonly property var all: Events.eventsOn(day).filter(e => !Events.isDeadline(e))
    readonly property var allDay: all.filter(e => e.allDay)
    readonly property var dues: Events.deadlinesOn(day)
    readonly property int hourH: 44
    readonly property int labelW: 38

    // Minutes from midnight of `day`, clamped to the day (an event from last
    // night starts at 0, one past midnight ends at 24 h)
    function minsOf(d) {
        const start = new Date(day); start.setHours(0, 0, 0, 0);
        return Math.max(0, Math.min(1440, (d - start) / 60000));
    }
    // Timed events: { e, from, to, lane, lanes }
    readonly property var blocks: {
        const list = all.filter(e => !e.allDay).map(e => ({ e: e, from: minsOf(Events.startOf(e)), to: minsOf(Events.endOf(e)) }))
            .filter(b => b.to > b.from).sort((a, b) => a.from - b.from || b.to - a.to);
        // Lanes: the first free one; a group of overlapping events shares the count
        let group = [], groupEnd = -1;
        const close = () => { const n = Math.max(...group.map(b => b.lane)) + 1; for (const b of group) b.lanes = n; group = []; };
        for (const b of list) {
            if (b.from >= groupEnd && group.length) close();
            const used = group.filter(o => o.to > b.from).map(o => o.lane);
            b.lane = 0;
            while (used.includes(b.lane)) b.lane++;
            group.push(b);
            groupEnd = Math.max(groupEnd, b.to);
        }
        if (group.length) close();
        return list;
    }
    // The hours shown: 7–22 at least, more if something is earlier or later
    readonly property int firstHour: Math.min(7, ...blocks.map(b => Math.floor(b.from / 60)), ...dues.map(x => x.due.getHours()))
    readonly property int lastHour: Math.max(22, ...blocks.map(b => Math.ceil(b.to / 60)), ...dues.map(x => x.due.getHours() + 1))
    function yOf(mins) { return (mins - firstHour * 60) / 60 * hourH; }
    // Free gaps (30 min or more) between the busy times, from now on for today
    readonly property var gaps: {
        const from0 = isToday ? Math.max(firstHour * 60, minsOf(Events.now)) : firstHour * 60;
        const busy = blocks.map(b => [b.from, b.to]).sort((a, b) => a[0] - b[0]);
        const out = [];
        let t = from0;
        for (const [a, b] of busy) {
            if (a - t >= 30) out.push([t, a]);
            t = Math.max(t, b);
        }
        if (lastHour * 60 - t >= 30) out.push([t, lastHour * 60]);
        return out;
    }
    function span(m) { const h = Math.floor(m / 60), mm = Math.round(m % 60); return (h ? h + " h" : "") + (h && mm ? " " : "") + (mm ? mm + " min" : ""); }

    ColumnLayout {
        anchors.fill: parent
        spacing: 6

        Flow {
            visible: root.allDay.length > 0
            Layout.fillWidth: true
            spacing: 4
            Repeater {
                model: root.allDay
                delegate: Rectangle {
                    required property var modelData
                    implicitWidth: Math.min(t.implicitWidth + 16, root.width)
                    implicitHeight: 22
                    radius: 11
                    color: Theme.withAlpha(Theme.accent2, 0.18)
                    Label { id: t; anchors.centerIn: parent; width: Math.min(implicitWidth, root.width - 16); text: modelData.title; font.pixelSize: 10; font.weight: Font.DemiBold; elide: Text.ElideRight }
                }
            }
        }

        Flickable {
            id: flick
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            contentHeight: (root.lastHour - root.firstHour) * root.hourH + 12
            boundsBehavior: Flickable.StopAtBounds
            // Today: the current time a little below the top; else the first event
            function settle() {
                const target = root.isToday ? root.yOf(root.minsOf(Events.now)) - 60
                             : root.blocks.length ? root.yOf(root.blocks[0].from) - 20 : 0;
                contentY = Math.max(0, Math.min(contentHeight - height, target));
            }
            Component.onCompleted: Qt.callLater(settle)
            onVisibleChanged: if (visible) Qt.callLater(settle)
            Connections { target: root; function onDayChanged() { Qt.callLater(flick.settle); } }

            Item {
                width: flick.width
                height: flick.contentHeight
                y: 6

                // Hours
                Repeater {
                    model: root.lastHour - root.firstHour + 1
                    delegate: Item {
                        required property int index
                        y: index * root.hourH
                        width: parent.width
                        Label { y: -7; width: root.labelW - 6; horizontalAlignment: Text.AlignRight
                                text: String(root.firstHour + index).padStart(2, "0") + ":00"; dim: true; font.pixelSize: 9; font.features: { "tnum": 1 } }
                        Rectangle { x: root.labelW; width: parent.width - root.labelW; height: 1; color: Theme.withAlpha(Theme.fg, 0.07) }
                    }
                }

                // Free gaps
                Repeater {
                    model: root.gaps
                    delegate: Rectangle {
                        required property var modelData
                        x: root.labelW + 4
                        y: root.yOf(modelData[0]) + 2
                        width: parent.width - root.labelW - 6
                        height: Math.max(0, root.yOf(modelData[1]) - root.yOf(modelData[0]) - 4)
                        radius: 6
                        color: "transparent"
                        border.width: 1
                        border.color: Theme.withAlpha(Theme.good, 0.35)
                        Label {
                            visible: parent.height >= 16
                            anchors.centerIn: parent
                            text: Tr.t("Free %1", root.span(modelData[1] - modelData[0]))
                            color: Theme.withAlpha(Theme.good, 0.85)
                            font.pixelSize: 9
                            font.weight: Font.DemiBold
                        }
                    }
                }

                // Events
                Repeater {
                    model: root.blocks
                    delegate: Rectangle {
                        required property var modelData
                        readonly property real laneW: (parent.width - root.labelW - 6) / modelData.lanes
                        readonly property bool live: Events.isNow(modelData.e)
                        x: root.labelW + 4 + modelData.lane * laneW
                        y: root.yOf(modelData.from) + 1
                        width: laneW - 3
                        height: Math.max(16, root.yOf(modelData.to) - root.yOf(modelData.from) - 2)
                        radius: 6
                        color: Theme.withAlpha(Theme.accent2, live ? 0.42 : Events.isOver(modelData.e) ? 0.10 : 0.24)
                        clip: true
                        Rectangle { width: 3; height: parent.height; radius: 1.5; color: Theme.accent2 }
                        Column {
                            x: 8; y: 3
                            width: parent.width - 11
                            Label { width: parent.width; text: modelData.e.title; font.pixelSize: 10; font.weight: Font.DemiBold; elide: Text.ElideRight
                                    dim: Events.isOver(modelData.e) }
                            Label { visible: parent.parent.height >= 30; width: parent.width; dim: true; font.pixelSize: 9; elide: Text.ElideRight
                                    text: modelData.e.start + " – " + modelData.e.end + (modelData.e.location ? " · " + modelData.e.location : "") }
                        }
                    }
                }

                // What's due: a flag at its time
                Repeater {
                    model: root.dues
                    delegate: Item {
                        required property var modelData
                        readonly property color tint: Events.dueColor(modelData)
                        x: root.labelW
                        y: root.yOf(root.minsOf(modelData.due)) - (modelData.dateOnly ? 10 : 0)
                        width: parent.width - root.labelW
                        Rectangle { width: parent.width; height: 2; color: parent.tint; opacity: 0.8 }
                        Rectangle {
                            x: parent.width - width - 2
                            y: -9
                            implicitWidth: flagRow.implicitWidth + 12
                            implicitHeight: 18
                            radius: 9
                            color: parent.tint
                            Row {
                                id: flagRow
                                anchors.centerIn: parent
                                spacing: 4
                                Glyph { text: ""; font.pixelSize: 8; color: Theme.onColor(parent.parent.color); anchors.verticalCenter: parent.verticalCenter }
                                Label { text: modelData.title + (modelData.dateOnly ? "" : " · " + Qt.formatTime(modelData.due, "HH:mm"))
                                        font.pixelSize: 9; font.weight: Font.Bold; color: Theme.onColor(parent.parent.color)
                                        width: Math.min(implicitWidth, root.width - root.labelW - 40); elide: Text.ElideRight
                                        anchors.verticalCenter: parent.verticalCenter }
                            }
                        }
                    }
                }

                // Now
                Item {
                    visible: root.isToday
                    x: root.labelW - 4
                    y: root.yOf(root.minsOf(Events.now))
                    width: parent.width - root.labelW + 4
                    Rectangle { y: -4; width: 8; height: 8; radius: 4; color: Theme.bad }
                    Rectangle { x: 4; y: -1; width: parent.width - 4; height: 2; color: Theme.bad }
                }
            }
        }
    }
}
