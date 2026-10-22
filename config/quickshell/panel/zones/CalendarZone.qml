import QtQuick
import QtQuick.Layouts
import "../common"
import "../services"

// ZONE: Calendar — month grid (left) and the selected day (right): today,
// everything still to hand in (Events.deadlines: Teams assignments and to-do
// tasks, soonest first, with the time left) and the events not over yet (the
// one going on marked "Now"); another day, what's due then and its events.
// Days with events get a dot. Click a day to see it; click the month name to
// go back to today. Events: services/Events.qml (scripts/events.py).
Zone {
    id: root

    property date today: new Date()
    readonly property date selected: Events.selected      // shared with the Calendar tab
    property bool showDayEvents: true                     // false: month grid only (Calendar tab)
    property real monthFraction: 0.58                     // month grid's share when events are shown
    readonly property int month: Events.month
    readonly property int year: Events.year

    function sameDay(a, b) { return a.toDateString() === b.toDateString(); }

    function shift(delta) {
        let m = Events.month + delta, y = Events.year;
        if (m < 0) { m = 11; y--; }
        if (m > 11) { m = 0; y++; }
        Events.year = y;
        Events.month = m;
    }

    function goToday() {
        today = new Date();
        Events.selected = today;
        Events.year = today.getFullYear();
        Events.month = today.getMonth();
    }

    // Only as many weeks as the month needs, starting on the week of the 1st
    function cells() {
        const first = new Date(year, month, 1);
        const offset = (first.getDay() - Config.firstWeekday + 7) % 7;
        const total = Math.ceil((offset + new Date(year, month + 1, 0).getDate()) / 7) * 7;
        const out = [];
        for (let i = 0; i < total; i++) out.push(new Date(year, month, 1 - offset + i));
        return out;
    }

    // Keep "today" right after midnight; back to today whenever the panel opens
    Timer {
        interval: 60000
        running: true
        repeat: true
        onTriggered: if (!root.sameDay(new Date(), root.today)) root.today = new Date()
    }
    Connections {
        target: PanelState
        function onOpenChanged() { if (PanelState.open) root.goToday(); }
    }

    RowLayout {
        id: content
        width: parent.width
        height: root.height - 2 * Theme.zonePadding
        spacing: 14

        // ---------------- Month grid ----------------
        ColumnLayout {
            id: monthColumn
            Layout.fillHeight: true
            Layout.preferredWidth: Math.round(content.width * (root.showDayEvents ? root.monthFraction : 1))
            Layout.maximumWidth: Math.round(content.width * (root.showDayEvents ? root.monthFraction : 1))
            spacing: 4

            RowLayout {
                id: monthHeader
                Layout.fillWidth: true
                Label {
                    Layout.fillWidth: true
                    text: Tr.cap(Tr.date(new Date(root.year, root.month, 1), "MMMM yyyy"))
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.goToday()
                    }
                }
                IconButton { icon: "\uf053"; iconSize: 11; implicitWidth: 28; implicitHeight: 26; border.width: 0; onClicked: root.shift(-1) }
                IconButton { icon: "\uf054"; iconSize: 11; implicitWidth: 28; implicitHeight: 26; border.width: 0; onClicked: root.shift(1) }
            }

            // Plain Grid with explicit cell sizes (derived from the column, not
            // from the grid itself, to avoid layout binding loops)
            Grid {
                id: grid
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 7

                // Keyboard: arrows move the selected day (±1 / ±7), PageUp/PageDown
                // change month, Home goes back to today
                activeFocusOnTab: true
                function moveBy(days) {
                    const d = new Date(Events.selected);
                    d.setDate(d.getDate() + days);
                    Events.selected = d;
                    if (d.getMonth() !== Events.month || d.getFullYear() !== Events.year) {
                        Events.year = d.getFullYear();
                        Events.month = d.getMonth();
                    }
                }
                Keys.onLeftPressed: moveBy(-1)
                Keys.onRightPressed: moveBy(1)
                Keys.onUpPressed: moveBy(-7)
                Keys.onDownPressed: moveBy(7)
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_Home) { root.goToday(); event.accepted = true; }
                    else if (event.key === Qt.Key_PageUp) { root.shift(-1); event.accepted = true; }
                    else if (event.key === Qt.Key_PageDown) { root.shift(1); event.accepted = true; }
                }

                readonly property var days: root.cells()
                readonly property real cellWidth: width / 7
                readonly property real cellHeight: (height - 18) / Math.max(1, days.length / 7)

                Repeater {
                    model: 7
                    delegate: Label {
                        required property int index
                        width: grid.cellWidth
                        height: 18
                        horizontalAlignment: Text.AlignHCenter
                        text: Tr.cap(Tr.locale.dayName((index + Config.firstWeekday) % 7, Locale.ShortFormat).slice(0, 2))
                        dim: true
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                    }
                }

                Repeater {
                    model: grid.days
                    delegate: Item {
                        id: dayCell
                        required property var modelData
                        readonly property bool inMonth: modelData.getMonth() === root.month
                        readonly property bool isToday: root.sameDay(modelData, root.today)
                        readonly property bool isSelected: root.sameDay(modelData, root.selected)
                        readonly property int count: Events.eventsOn(modelData).length

                        width: grid.cellWidth
                        height: grid.cellHeight
                        readonly property real size: Math.min(width, height) - 4

                        Rectangle {
                            anchors.centerIn: parent
                            width: dayCell.size
                            height: dayCell.size
                            radius: width / 2
                            color: dayCell.isToday ? Theme.accent
                                   : (dayMouse.containsMouse ? Theme.bgHover : "transparent")
                            border.color: grid.activeFocus ? Theme.vivid : Theme.accent
                            border.width: dayCell.isSelected ? (grid.activeFocus ? 2.5 : (dayCell.isToday ? 0 : 1.5)) : 0
                        }
                        Label {
                            anchors.centerIn: parent
                            anchors.verticalCenterOffset: dayCell.count > 0 ? -3 : 0
                            text: dayCell.modelData.getDate()
                            font.pixelSize: 13
                            font.weight: dayCell.isToday ? Font.Bold : Font.Normal
                            color: dayCell.isToday ? Theme.accentText : Theme.fg
                            opacity: dayCell.inMonth ? 1 : 0.3
                        }
                        // Event dot
                        Rectangle {
                            visible: dayCell.count > 0
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.verticalCenterOffset: 9
                            width: 4
                            height: 4
                            radius: 2
                            color: dayCell.isToday ? Theme.accentText : Theme.accent2
                            opacity: dayCell.inMonth ? 1 : 0.4
                        }
                        MouseArea {
                            id: dayMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Events.selected = dayCell.modelData;
                                if (!dayCell.inMonth) root.shift(dayCell.modelData < new Date(root.year, root.month, 1) ? -1 : 1);
                            }
                        }
                    }
                }
            }
        }

        // Divider
        Rectangle {
            visible: root.showDayEvents
            Layout.fillHeight: true
            Layout.preferredWidth: 1
            color: Theme.border
        }

        // ---------------- Selected day's events ----------------
        ColumnLayout {
            visible: root.showDayEvents
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 8

            // Today: everything still to hand in, then the events not over yet;
            // another day: what's due that day, then its events
            readonly property bool isToday: root.sameDay(root.selected, Events.now)
            readonly property var due: isToday ? Events.deadlines : Events.deadlinesOn(root.selected)
            readonly property var events: Events.dayEvents(root.selected)

            // "Today" (Tomorrow / Yesterday / Events for other days) over
            // "SUN · Oct 11", both centered
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1
                Label {
                    readonly property int diff: Math.round((new Date(root.selected).setHours(0, 0, 0, 0)
                                                            - new Date(root.today).setHours(0, 0, 0, 0)) / 86400000)
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: diff === 0 ? Tr.t("Today") : diff === 1 ? Tr.t("Tomorrow") : diff === -1 ? Tr.t("Yesterday") : Tr.t("Events")
                    font.pixelSize: 16
                    font.weight: Font.DemiBold
                }
                Label {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: Tr.date(root.selected, "ddd").toUpperCase() + " · " + Tr.cap(Tr.date(root.selected, Tr.t("MMM d")))
                    dim: true
                    font.pixelSize: 12
                    font.weight: Font.DemiBold
                    font.letterSpacing: 0.5
                }
            }

            Flickable {
                id: dayList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                contentHeight: dayCol.implicitHeight
                boundsBehavior: Flickable.StopAtBounds
                readonly property var due: parent.due
                readonly property var events: parent.events

                Column {
                    id: dayCol
                    width: dayList.width
                    spacing: 6

                    Label {
                        visible: dayList.due.length > 0
                        text: Tr.t("TO HAND IN · %1", dayList.due.length)
                        dim: true
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        font.letterSpacing: 1
                    }
                    Repeater {
                        model: dayList.due
                        delegate: DeadlineRow { required property var modelData; item: modelData; width: dayCol.width; compact: true }
                    }
                    Label {
                        visible: dayList.due.length > 0 && dayList.events.length > 0
                        topPadding: 4
                        text: Tr.t("EVENTS")
                        dim: true
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        font.letterSpacing: 1
                    }
                    Repeater {
                        model: dayList.events
                        delegate: Rectangle {
                            required property var modelData
                            readonly property bool live: Events.isNow(modelData)
                            width: dayCol.width
                            implicitHeight: info.implicitHeight + 12
                            radius: 8
                            color: Theme.withAlpha(Theme.accent2, live ? 0.22 : 0.10)

                            // Accent bar on the left
                            Rectangle {
                                width: 3
                                height: parent.height - 12
                                anchors.verticalCenter: parent.verticalCenter
                                x: 6
                                radius: 1.5
                                color: Theme.accent2
                            }

                            ColumnLayout {
                                id: info
                                x: 16
                                width: parent.width - 22
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 1
                                RowLayout {
                                    Layout.fillWidth: true
                                    spacing: 5
                                    Glyph {
                                        visible: modelData.important
                                        text: "\uf005"            // ★ important (Outlook); amber when High importance
                                        font.pixelSize: 9
                                        color: modelData.high ? Theme.warn : Theme.accent
                                    }
                                    Label {
                                        Layout.fillWidth: true
                                        text: modelData.title
                                        font.pixelSize: 12
                                        font.weight: Font.DemiBold
                                    }
                                    // Going on now
                                    Rectangle {
                                        visible: live
                                        implicitWidth: nowText.implicitWidth + 10
                                        implicitHeight: 16
                                        radius: 8
                                        color: Theme.accent2
                                        Label { id: nowText; anchors.centerIn: parent; text: Tr.t("Now"); font.pixelSize: 9; font.weight: Font.Bold; color: Theme.accent2Text }
                                    }
                                }
                                Label {
                                    Layout.fillWidth: true
                                    text: (modelData.allDay ? Tr.t("All day") : modelData.start + " – " + modelData.end)
                                          + (modelData.location ? "  ·  " + modelData.location : "")
                                    dim: true
                                    font.pixelSize: 11
                                }
                            }
                        }
                    }
                }

                // Empty state
                Label {
                    x: (dayList.width - width) / 2
                    y: (dayList.height - height) / 2
                    visible: dayList.due.length === 0 && dayList.events.length === 0
                    text: Events.loading ? Tr.t("Loading…") : root.sameDay(root.selected, Events.now) ? Tr.t("Nothing left today") : Tr.t("No events")
                    dim: true
                    font.pixelSize: 12
                }
            }
        }
    }
}
