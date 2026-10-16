import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris
import "../common"
import "../services"

// The island at the center of the bar: a near-black pill, whatever the theme.
// Grown, it's the bigger view of the bar's right twin (bar/Glance.qml): the
// music while something plays (Media.active), else the weather.
//   rest       date · time
//   media      while a player plays and no twin shows it (playerShown): its
//              art on the left, an equalizer on the right; the time stays where it was
//   expanded   hovering it while a player plays (or paused it a moment ago):
//              it grows down with the art, title, progress and controls
//   weather    hovering it otherwise: it grows down with the weather (sky,
//              temperatures, rain in the next hours); a click on it: the Weather tab
//   rec        screen recording (services/Recorder.qml): red dot and elapsed
//              time; a click stops it
//   level      volume, brightness, progress… placed on the island (BarState.level):
//              icon · title · bar · percentage, the bar sliding from the last value
//   flash      a short message (BarState.say: Do Not Disturb, caffeine, volume),
//              with an Undo when it has one (click the island)
//   message    a chat message (BarState.message, instead of a popup): the
//              chat's photo, who and the text; hovering holds it and shows the
//              whole text with Reply and Open; a click opens the chat
// Click: the panel (open / close) · wheel: volume of the output.
// It doesn't grow while the panel is open (it would open behind it), and stays
// grown while a screenshot region is picked (slurp covers it: PanelState.capturing).
Rectangle {
    id: root

    readonly property var player: Media.player
    readonly property bool hasTrack: Media.hasTrack       // a hover preview doesn't count (services/Media.qml)
    readonly property bool playing: Media.playing
    readonly property bool music: Media.active
    property bool expandWanted: false
    // The bar already shows the player in a twin (TopBar.qml): then the pill
    // stays day · time · date while it plays (no small art, no equalizer), so
    // its width, and the twins' room, don't change when music starts or stops
    property bool playerShown: false
    readonly property var msg: BarState.message
    readonly property var lvl: BarState.level
    readonly property string mode: lvl ? "level"
        : BarState.flash ? "flash"
        : msg ? (expandWanted ? "messageOpen" : "message")
        : Recorder.recording ? "rec"
        : expandWanted && music ? "expanded"
        : expandWanted && Weather.ready ? "weather"
        : playing && !playerShown ? "media" : "rest"
    readonly property bool isMessage: mode === "message" || mode === "messageOpen"
    readonly property int pillH: Settings.v.barHeight - 6
    readonly property color ink: "#f1f3f5"
    readonly property color inkDim: Qt.rgba(241 / 255, 243 / 255, 245 / 255, 0.6)
    readonly property color accent: Theme.ensure(BarState.accent, color, 3)

    readonly property int expandedH: 196
    readonly property bool grown: mode === "expanded" || mode === "weather"
    width: grown ? 520 : isMessage ? 480 : (mode === "flash" ? flashRow.implicitWidth : mode === "level" ? levelRow.implicitWidth : topRow.implicitWidth) + 34
    height: grown ? expandedH : mode === "messageOpen" ? pillH + msgBody.implicitHeight + 58 : pillH
    radius: grown || mode === "messageOpen" ? 24 : pillH / 2
    color: Theme.mix(Theme.panel.base, "#000000", Theme.light ? 0.85 : 0.55)
    border.width: 1
    border.color: Qt.rgba(1, 1, 1, 0.07)
    clip: true
    Behavior on width { NumberAnimation { duration: 420; easing.type: Easing.OutBack; easing.overshoot: 1.3 } }
    Behavior on height { NumberAnimation { duration: 380; easing.type: Easing.OutBack; easing.overshoot: 0.9 } }
    Behavior on radius { NumberAnimation { duration: 300 } }

    // Hover intent: a pointer passing by doesn't open it. Leaving closes it a
    // moment later, unless a screenshot region is being picked (slurp's layer
    // takes the pointer): then it waits for the capture to end.
    HoverHandler {
        id: hover
        onHoveredChanged: {
            BarState.messageHold = hovered && !!root.msg;
            if (hovered) intent.restart(); else { intent.stop(); leave.restart(); }
        }
    }
    Timer { id: intent; interval: 220; onTriggered: if (!PanelState.open) root.expandWanted = true }
    Timer { id: leave; interval: 200; onTriggered: if (!hover.hovered && !PanelState.capturing) root.expandWanted = false }
    Connections {
        target: PanelState
        function onCapturingChanged() { if (!PanelState.capturing && !hover.hovered) root.expandWanted = false; }
        function onOpenChanged() { if (PanelState.open) root.expandWanted = false; }
    }
    onMsgChanged: if (!msg) BarState.messageHold = false

    // MPRIS positions don't update on their own
    Timer {
        interval: 1000
        repeat: true
        running: root.mode === "expanded" && root.playing
        onTriggered: root.player.positionChanged()
    }
    SystemClock { id: clock; precision: SystemClock.Minutes }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: BarState.flash?.undo ? BarState.undoFlash() : root.isMessage ? BarState.openMessage() : Recorder.recording ? Recorder.stop() : (PanelState.open = !PanelState.open)
        onWheel: w => {
            const a = Media.sink?.audio;
            if (!a) return;
            a.volume = Math.max(0, Math.min(1, a.volume + (w.angleDelta.y > 0 ? 0.05 : -0.05)));
            BarState.say(a.volume === 0 ? "" : "", "Volume " + Math.round(a.volume * 100) + "%");
        }
    }

    // ---------------- Top row (the pill) ----------------
    // Mirrored like the bar, around the time's colon (on the screen's center):
    //   [day | day of the month] · [hours] : [minutes] · [day of the month | month]
    // The hours and minutes boxes share one width, and so do the day and date
    // boxes (each label centered in its own), so both halves measure the same.
    // While a player plays, its art joins the day and the equalizer the date;
    // while recording, the REC counter takes the day's side
    Row {
        id: topRow
        visible: root.mode !== "flash" && root.mode !== "level" && !root.isMessage
        anchors.horizontalCenter: parent.horizontalCenter
        y: 0
        height: root.pillH
        readonly property bool showDate: Settings.v.barDate && root.mode !== "rec"
        // The day and the date roll together every few seconds, so each side
        // stays about three characters: "Tue 23:20 13" → "13 23:20 Oct"
        property bool later: false               // false: day | day of the month · true: day of the month | month
        readonly property int rollEvery: 6000    // ms between the two
        readonly property int rollOut: 450       // ms to fade / slide out, then in
        readonly property int rollIn: 600
        // Both boxes as wide as the widest of the three texts: the pill never changes size
        readonly property real dateBox: Math.ceil(Math.max(dayMetrics.advanceWidth, numMetrics.advanceWidth, monMetrics.advanceWidth))
        TextMetrics { id: dayMetrics; font: dateText.font; text: Qt.formatDate(clock.date, "ddd") }
        TextMetrics { id: numMetrics; font: dateText.font; text: Qt.formatDate(clock.date, "d") }
        TextMetrics { id: monMetrics; font: dateText.font; text: Qt.formatDate(clock.date, "MMM") }
        Timer {
            interval: topRow.rollEvery
            repeat: true
            running: topRow.showDate && topRow.visible
            onTriggered: roll.restart()
        }
        SequentialAnimation {
            id: roll
            ParallelAnimation {
                NumberAnimation { targets: [dayText, dateText]; property: "opacity"; to: 0; duration: topRow.rollOut; easing.type: Easing.InOutSine }
                NumberAnimation { targets: [dayText, dateText]; property: "anchors.verticalCenterOffset"; to: -6; duration: topRow.rollOut; easing.type: Easing.InOutSine }
            }
            ScriptAction { script: topRow.later = !topRow.later }
            PropertyAction { targets: [dayText, dateText]; property: "anchors.verticalCenterOffset"; value: 6 }
            ParallelAnimation {
                NumberAnimation { targets: [dayText, dateText]; property: "opacity"; to: 1; duration: topRow.rollIn; easing.type: Easing.OutSine }
                NumberAnimation { targets: [dayText, dateText]; property: "anchors.verticalCenterOffset"; to: 0; duration: topRow.rollIn; easing.type: Easing.OutSine }
            }
        }
        readonly property int gap: 10
        readonly property real outer: Math.max(leftGroup.implicitWidth, rightGroup.implicitWidth)
        readonly property bool sides: outer > 0
        readonly property real digits: Math.max(hourLabel.implicitWidth, minLabel.implicitWidth)
        readonly property var timeParts: (Settings.v.bar24h ? Qt.formatTime(clock.date, "HH:mm")
                                                            : Qt.formatTime(clock.date, "h:mm AP")).split(":")

        // Left: (art) · day, or the REC counter
        Item {
            visible: topRow.sides
            width: topRow.outer
            height: topRow.height
            Row {
                id: leftGroup
                anchors.centerIn: parent
                spacing: 8
                Row {
                    visible: root.mode === "rec"
                    spacing: 7
                    anchors.verticalCenter: parent.verticalCenter
                    Rectangle {
                        width: 9; height: 9; radius: 5
                        color: "#ff4d4d"
                        anchors.verticalCenter: parent.verticalCenter
                        SequentialAnimation on opacity {
                            running: root.mode === "rec"
                            loops: Animation.Infinite
                            NumberAnimation { to: 0.3; duration: 600 }
                            NumberAnimation { to: 1; duration: 600 }
                        }
                    }
                    Label { text: "REC " + Recorder.elapsed; color: "#ff8a8a"; font.pixelSize: 13; font.weight: Font.DemiBold; font.features: { "tnum": 1 } }
                }
                ClippingRectangle {
                    visible: root.mode === "media"
                    width: 20; height: 20; radius: 6
                    anchors.verticalCenter: parent.verticalCenter
                    color: root.accent
                    Image {
                        anchors.fill: parent
                        source: root.player?.trackArtUrl ?? ""
                        fillMode: Image.PreserveAspectCrop
                        sourceSize: Qt.size(40, 40)
                        asynchronous: true
                    }
                }
                Item {
                    visible: topRow.showDate
                    width: topRow.dateBox
                    height: dayText.implicitHeight
                    anchors.verticalCenter: parent.verticalCenter
                    Label {
                        id: dayText
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        text: topRow.later ? numMetrics.text : dayMetrics.text
                        color: root.inkDim
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        font.features: { "tnum": 1 }
                    }
                }
            }
        }
        Item { visible: topRow.sides; width: topRow.gap; height: 1 }

        // The time: hours | colon (the axis) | minutes
        Item {
            width: topRow.digits
            height: topRow.height
            Label {
                id: hourLabel
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                text: topRow.timeParts[0] ?? ""
                color: root.ink
                font.family: Theme.clockFont
                font.pixelSize: 15
                font.weight: Font.Bold
                font.features: { "tnum": 1 }
            }
        }
        Label {
            anchors.verticalCenter: parent.verticalCenter
            text: ":"
            color: root.ink
            font.family: Theme.clockFont
            font.pixelSize: 15
            font.weight: Font.Bold
        }
        Item {
            width: topRow.digits
            height: topRow.height
            Label {
                id: minLabel
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: topRow.timeParts[1] ?? ""
                color: root.ink
                font.family: Theme.clockFont
                font.pixelSize: 15
                font.weight: Font.Bold
                font.features: { "tnum": 1 }
            }
        }

        // Right: date · (equalizer)
        Item { visible: topRow.sides; width: topRow.gap; height: 1 }
        Item {
            visible: topRow.sides
            width: topRow.outer
            height: topRow.height
            Row {
                id: rightGroup
                anchors.centerIn: parent
                spacing: 8
                Item {
                    visible: topRow.showDate
                    width: topRow.dateBox
                    height: dateText.implicitHeight
                    anchors.verticalCenter: parent.verticalCenter
                    Label {
                        id: dateText
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                        text: topRow.later ? monMetrics.text : numMetrics.text
                        color: root.inkDim
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        font.features: { "tnum": 1 }
                    }
                }
                // Equalizer (decorative: moves while playing)
                Row {
                    visible: root.mode === "media"
                    spacing: 2
                    height: 14
                    anchors.verticalCenter: parent.verticalCenter
                    Repeater {
                        model: [520, 380, 610, 450]
                        delegate: Rectangle {
                            required property int modelData
                            width: 3
                            radius: 2
                            color: root.accent
                            anchors.verticalCenter: parent.verticalCenter
                            height: 4
                            SequentialAnimation on height {
                                running: root.playing && root.mode === "media"
                                loops: Animation.Infinite
                                NumberAnimation { to: 14; duration: modelData; easing.type: Easing.InOutSine }
                                NumberAnimation { to: 4; duration: modelData; easing.type: Easing.InOutSine }
                            }
                        }
                    }
                }
            }
        }
    }

    // ---------------- Level: icon · title · bar · percentage ----------------
    Row {
        id: levelRow
        visible: root.mode === "level"
        anchors.centerIn: parent
        spacing: 10
        readonly property real value: root.lvl ? Notifs.progressOf(root.lvl) : 0
        readonly property string glyph: { value; return root.lvl ? Notifs.levelGlyph(root.lvl) : ""; }
        // Slides from the last value to the new one
        property real shown: value
        Behavior on shown { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
        Glyph {
            visible: levelRow.glyph !== ""
            optical: true; text: levelRow.glyph; color: root.accent; font.pixelSize: 14
            anchors.verticalCenter: parent.verticalCenter
        }
        Image {
            visible: levelRow.glyph === ""
            width: 16; height: 16; sourceSize: Qt.size(32, 32)
            source: levelRow.glyph === "" && root.lvl ? Notifs.appIconOf(root.lvl) : ""
            anchors.verticalCenter: parent.verticalCenter
        }
        // The name only when the icon doesn't say it (a download's file, not "Brightness")
        Label {
            visible: levelRow.glyph === ""
            text: root.lvl ? Notifs.titleOf(root.lvl) : ""
            color: root.ink; font.pixelSize: 13; font.weight: Font.DemiBold
            elide: Text.ElideRight; width: Math.min(implicitWidth, 180)
            anchors.verticalCenter: parent.verticalCenter
        }
        Rectangle {
            width: 120; height: 6; radius: 3
            color: Qt.rgba(1, 1, 1, 0.14)
            anchors.verticalCenter: parent.verticalCenter
            Rectangle {
                width: parent.width * Math.max(0, Math.min(1, levelRow.shown / 100))
                height: parent.height; radius: parent.radius
                color: levelRow.value > 100 ? Theme.warn : root.accent
            }
        }
        Label {
            text: Math.round(levelRow.value) + "%"
            color: levelRow.value > 100 ? Theme.warn : root.ink
            font.pixelSize: 12; font.weight: Font.DemiBold; font.features: { "tnum": 1 }
            width: 34; horizontalAlignment: Text.AlignRight
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    // ---------------- Flash message ----------------
    Row {
        id: flashRow
        visible: root.mode === "flash"
        anchors.centerIn: parent
        spacing: 9
        Glyph { optical: true; text: BarState.flash?.icon ?? ""; color: root.accent; font.pixelSize: 14; anchors.verticalCenter: parent.verticalCenter }
        Label { text: BarState.flash?.text ?? ""; color: root.ink; font.pixelSize: 13; font.weight: Font.DemiBold; anchors.verticalCenter: parent.verticalCenter
                elide: Text.ElideRight; width: Math.min(implicitWidth, 360) }
        // Undo (click anywhere on the island)
        Rectangle {
            visible: !!BarState.flash?.undo
            implicitWidth: undoText.implicitWidth + 16
            implicitHeight: 20
            radius: 10
            color: root.accent
            anchors.verticalCenter: parent.verticalCenter
            Label { id: undoText; anchors.centerIn: parent; text: "Undo"; color: Theme.onColor(root.accent); font.pixelSize: 11; font.weight: Font.Bold }
        }
    }

    // ---------------- Message ----------------
    // Top row: photo (app icon on its corner) · who · the text, one line
    Item {
        visible: root.isMessage
        x: 14
        width: root.width - 28
        height: root.pillH
        Item {
            id: msgPic
            width: 22; height: 22
            anchors.verticalCenter: parent.verticalCenter
            ClippingRectangle {
                anchors.fill: parent
                radius: width / 2
                color: Qt.rgba(1, 1, 1, 0.1)
                Image {
                    id: msgPhoto
                    // The photo's file may be gone already (Brave deletes it): the app's icon
                    property bool photoFailed: false
                    readonly property bool usingPhoto: !!root.msg?.photo && !photoFailed
                    anchors.fill: parent
                    source: usingPhoto ? root.msg.photo : (root.msg?.icon ?? "")
                    fillMode: usingPhoto ? Image.PreserveAspectCrop : Image.PreserveAspectFit
                    sourceSize: Qt.size(44, 44)
                    asynchronous: true
                    onStatusChanged: if (status === Image.Error && usingPhoto) photoFailed = true
                    Connections { target: root; function onMsgChanged() { msgPhoto.photoFailed = false; } }
                }
            }
            Rectangle {
                visible: msgPhoto.usingPhoto && !!root.msg?.icon
                width: 12; height: 12; radius: 6
                anchors.right: parent.right; anchors.bottom: parent.bottom
                anchors.rightMargin: -3; anchors.bottomMargin: -3
                color: root.color
                Image { anchors.centerIn: parent; width: 10; height: 10; source: root.msg?.icon ?? ""; sourceSize: Qt.size(20, 20) }
            }
        }
        Label {
            id: msgWho
            anchors.left: msgPic.right
            anchors.leftMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            width: Math.min(implicitWidth, 160)
            text: root.msg?.who ?? ""
            color: root.ink
            font.pixelSize: 13
            font.weight: Font.DemiBold
        }
        Label {
            anchors.left: msgWho.right
            anchors.leftMargin: 8
            anchors.right: msgCount.left
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            visible: root.mode === "message"
            text: root.msg?.body ?? ""
            color: root.inkDim
            font.pixelSize: 13
        }
        Rectangle {
            id: msgCount
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            visible: (root.msg?.count ?? 1) > 1
            width: visible ? countText.implicitWidth + 12 : 0
            height: 18
            radius: 9
            color: root.accent
            Label { id: countText; anchors.centerIn: parent; text: root.msg?.count ?? ""; color: Theme.onColor(root.accent); font.pixelSize: 10; font.weight: Font.Bold }
        }
    }
    // Hovered: the whole text, Reply and Open
    ColumnLayout {
        visible: opacity > 0
        opacity: root.mode === "messageOpen" && root.height > root.pillH + 30 ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 140 } }
        x: 18
        y: root.pillH + 2
        width: root.width - 36
        spacing: 10
        Label {
            id: msgBody
            Layout.fillWidth: true
            text: root.msg?.body ?? ""
            color: root.ink
            font.pixelSize: 13
            wrapMode: Text.Wrap
            maximumLineCount: 4
        }
        Row {
            Layout.alignment: Qt.AlignRight
            spacing: 8
            Repeater {
                model: [
                    { label: "Reply", icon: "\uf112", ok: !!BarState.messageNotif() && Comms.canReply(BarState.messageNotif()), run: () => BarState.replyMessage() },
                    { label: "Open", icon: "\uf35d", ok: true, run: () => BarState.openMessage() }
                ]
                delegate: Rectangle {
                    required property var modelData
                    visible: modelData.ok
                    width: btnRow.implicitWidth + 22
                    height: 28
                    radius: 14
                    color: btnMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.16) : Qt.rgba(1, 1, 1, 0.09)
                    Row {
                        id: btnRow
                        anchors.centerIn: parent
                        spacing: 7
                        Glyph { optical: true; text: modelData.icon; color: root.accent; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
                        Label { text: modelData.label; color: root.ink; font.pixelSize: 12; font.weight: Font.DemiBold; anchors.verticalCenter: parent.verticalCenter }
                    }
                    MouseArea { id: btnMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: parent.modelData.run() }
                }
            }
        }
    }

    // ---------------- Expanded: the weather ----------------
    // The sky's icon on the left (as big as the player's art); on the right
    // the temperature and sky, the place and feels-like, the chance of rain
    // in the next hours, then high / low, humidity and wind
    RowLayout {
        visible: opacity > 0
        opacity: root.mode === "weather" && root.height > 140 ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 160 } }
        x: 14
        y: root.pillH + 4
        width: root.width - 28
        height: root.expandedH - root.pillH - 18
        spacing: 16

        Rectangle {
            Layout.preferredWidth: parent.height
            Layout.preferredHeight: parent.height
            radius: 16
            color: Qt.rgba(1, 1, 1, 0.06)
            Glyph {
                anchors.centerIn: parent
                optical: true
                text: Weather.icon
                font.pixelSize: 64
                color: root.accent
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            Row {
                spacing: 10
                Label { text: Math.round(Weather.temp) + "°"; color: root.ink; font.pixelSize: 26; font.weight: Font.Bold; font.features: { "tnum": 1 }; anchors.baseline: sky.baseline }
                Label { id: sky; text: Weather.description; color: root.ink; font.pixelSize: 15; font.weight: Font.DemiBold }
            }
            Label {
                text: [Weather.place, "feels like " + Math.round(Weather.feelsLike) + "°"].filter(s => s).join(" · ")
                color: root.inkDim
                font.pixelSize: 12
                Layout.fillWidth: true
            }

            // Chance of rain, hour by hour
            Item {
                id: rainChart
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 8
                readonly property var hours: Weather.rainNext
                Row {
                    anchors.fill: parent
                    Repeater {
                        model: rainChart.hours
                        delegate: Item {
                            required property int index
                            required property var modelData
                            width: rainChart.width / Math.max(1, rainChart.hours.length)
                            height: rainChart.height
                            Label {
                                id: pct
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: bar.top
                                anchors.bottomMargin: 2
                                text: modelData + "%"
                                color: modelData >= 50 ? root.accent : root.inkDim
                                font.pixelSize: 10
                                font.features: { "tnum": 1 }
                            }
                            Rectangle {
                                id: bar
                                anchors.bottom: hour.top
                                anchors.bottomMargin: 3
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: Math.min(22, parent.width * 0.55)
                                height: Math.max(3, (parent.height - hour.height - pct.height - 8) * modelData / 100)
                                radius: 4
                                color: modelData >= 50 ? root.accent : Qt.rgba(1, 1, 1, 0.22)
                            }
                            Label {
                                id: hour
                                anchors.horizontalCenter: parent.horizontalCenter
                                anchors.bottom: parent.bottom
                                text: index === 0 ? "Now" : Qt.formatTime(new Date(clock.date.getTime() + index * 3600000), Settings.v.bar24h ? "HH" : "h AP")
                                color: root.inkDim
                                font.pixelSize: 10
                            }
                        }
                    }
                }
            }

            // High / low · humidity · wind
            Row {
                Layout.topMargin: 6
                spacing: 16
                Repeater {
                    model: [
                        { icon: "\uf062", text: Math.round(Weather.high) + "°" },
                        { icon: "\uf063", text: Math.round(Weather.low) + "°" },
                        { icon: "\ue373", text: Weather.humidity + "%" },
                        { icon: "\uef16", text: Math.round(Weather.wind) + " km/h " + Weather.windCompass }
                    ]
                    delegate: Row {
                        required property var modelData
                        spacing: 5
                        Glyph { optical: true; text: modelData.icon; color: root.accent; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
                        Label { text: modelData.text; color: root.ink; font.pixelSize: 12; font.weight: Font.DemiBold; font.features: { "tnum": 1 }; anchors.verticalCenter: parent.verticalCenter }
                    }
                }
            }
        }
    }
    // A click on the card: the Weather tab
    MouseArea {
        visible: root.mode === "weather"
        y: root.pillH
        width: root.width
        height: root.height - root.pillH
        cursorShape: Qt.PointingHandCursor
        onClicked: { PanelState.open = true; PanelState.goTo("Weather", ""); }
    }

    // ---------------- Expanded: the player ----------------
    // Art on the left, as tall as the content; on the right the titles, the
    // cava visualizer (doubles as the seekable progress: played bars in the
    // accent) with the times, and shuffle · previous · play · next · loop
    readonly property bool vizOn: mode === "expanded"
    onVizOnChanged: Cava.users += vizOn ? 1 : -1
    Component.onDestruction: if (vizOn) Cava.users -= 1
    readonly property real progress: (player?.length ?? 0) > 0 ? Math.max(0, Math.min(1, player.position / player.length)) : 0

    RowLayout {
        visible: opacity > 0
        opacity: root.mode === "expanded" && root.height > 140 ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 160 } }
        x: 14
        y: root.pillH + 4
        width: root.width - 28
        height: root.expandedH - root.pillH - 18
        spacing: 16

        ClippingRectangle {
            Layout.preferredWidth: parent.height
            Layout.preferredHeight: parent.height
            radius: 16
            color: root.accent
            Image {
                anchors.fill: parent
                source: root.player?.trackArtUrl ?? ""
                fillMode: Image.PreserveAspectCrop
                sourceSize: Qt.size(280, 280)
                asynchronous: true
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: { PanelState.open = true; PanelState.goTo("Media", ""); }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            // Titles
            Label { text: root.player?.trackTitle ?? ""; color: root.ink; font.pixelSize: 15; font.weight: Font.DemiBold; Layout.fillWidth: true }
            Label {
                text: [root.player?.trackArtist ?? "", root.player?.identity ?? ""].filter(s => s).join(" · ")
                color: root.inkDim
                font.pixelSize: 12
                Layout.fillWidth: true
            }

            // Visualizer = progress
            Item {
                id: viz
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.topMargin: 6
                readonly property int count: 44
                readonly property real slot: width / count
                Row {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: times.top
                    anchors.bottomMargin: 3
                    height: parent.height - times.height - 3
                    Repeater {
                        model: viz.count
                        delegate: Item {
                            required property int index
                            width: viz.slot
                            height: parent.height
                            readonly property real level: Cava.bars.length ? (Cava.bars[Math.floor(index * Cava.bars.length / viz.count)] ?? 0) : 0
                            readonly property bool played: (index + 0.5) / viz.count <= root.progress
                            Rectangle {
                                anchors.bottom: parent.bottom
                                anchors.horizontalCenter: parent.horizontalCenter
                                width: Math.max(2, viz.slot * 0.6)
                                height: Math.max(3, parent.height * parent.level)
                                radius: width / 2
                                color: parent.played ? root.accent : Qt.rgba(1, 1, 1, 0.22)
                                Behavior on height { NumberAnimation { duration: 60 } }
                            }
                        }
                    }
                }
                RowLayout {
                    id: times
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    Label { text: Media.fmt(root.player?.position ?? 0); color: root.inkDim; font.pixelSize: 10; font.features: { "tnum": 1 } }
                    Item { Layout.fillWidth: true }
                    Label { text: Media.fmt(root.player?.length ?? 0); color: root.inkDim; font.pixelSize: 10; font.features: { "tnum": 1 } }
                }
                MouseArea {
                    anchors.fill: parent
                    enabled: (root.player?.canSeek ?? false) && (root.player?.length ?? 0) > 0
                    cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                    onClicked: m => root.player.position = root.player.length * Math.max(0, Math.min(1, m.x / width))
                }
            }

            // Shuffle · previous · play / pause · next · loop
            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 6
                Repeater {
                    model: [
                        { icon: "\uf074", size: 13, ok: root.player?.shuffleSupported ?? false, on: root.player?.shuffle ?? false,
                          run: () => root.player.shuffle = !root.player.shuffle },
                        { icon: "\uf048", size: 15, ok: root.player?.canGoPrevious ?? false, on: false, run: () => root.player?.previous() },
                        { icon: root.playing ? "\uf04c" : "\uf04b", size: 19, ok: root.player?.canTogglePlaying ?? true, on: false, big: true,
                          run: () => root.player?.togglePlaying() },
                        { icon: "\uf051", size: 15, ok: root.player?.canGoNext ?? false, on: false, run: () => root.player?.next() },
                        { icon: (root.player?.loopState ?? MprisLoopState.None) === MprisLoopState.Track ? "\u{f0458}" : "\uf01e", size: 13,
                          ok: root.player?.loopSupported ?? false, on: (root.player?.loopState ?? MprisLoopState.None) !== MprisLoopState.None,
                          run: () => Media.cycleLoop() }
                    ]
                    delegate: Item {
                        required property var modelData
                        Layout.fillWidth: true
                        implicitHeight: 32
                        Rectangle {
                            anchors.centerIn: parent
                            width: modelData.big ? 36 : 30
                            height: width
                            radius: width / 2
                            color: modelData.big ? root.accent : ctlMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.12) : "transparent"
                            Glyph {
                                anchors.centerIn: parent
                                optical: true
                                text: modelData.icon
                                font.pixelSize: modelData.size
                                color: modelData.big ? Theme.onColor(root.accent) : modelData.on ? root.accent : root.ink
                                opacity: modelData.ok ? 1 : 0.35
                            }
                            MouseArea {
                                id: ctlMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                enabled: modelData.ok
                                cursorShape: Qt.PointingHandCursor
                                onClicked: modelData.run()
                            }
                        }
                    }
                }
            }
        }
    }
}
