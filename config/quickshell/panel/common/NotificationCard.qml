import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Notifications
import "../services"

// One notification, used by the popups and the Notifications tab.
// Normal notifications use the wallust palette; critical ones use a fixed dark
// palette with the summary as a small red header (same look as swaync had).
Rectangle {
    id: card
    required property var notif
    property bool popup: false          // popups clamp the body to 3 lines
    property bool compact: false        // small card: one-line body, no actions
    property bool showApp: false        // show the app name above the summary
    property bool hovered: mouse.containsMouse
    // Popups take Settings → Notifications → Colors; cards in the panel, the panel's
    readonly property var pal: popup ? Theme.notifications : Theme.panel
    // Quick reply (services/Comms.qml): the Reply button opens ReplyBox.qml,
    // which outlives this card (the app may close its notification any moment)
    readonly property bool canReply: !compact && Comms.canReply(notif)
    // For the log: whether a message's popup offers Reply, and why not (no text),
    // and where its picture comes from
    function logReply() {
        if (popup && notif && Notifs.placeKind(notif) === "message")
            console.info("quick reply offered:", canReply, "| app", notif.appName, "| entry", notif.desktopEntry,
                         "| from", Comms.defs.filter(d => Comms.isFrom(d, notif)).map(d => d.key).join(",") || "-",
                         "| actions", (notif.actions ?? []).map(a => a.identifier).join(","), "| inline", !!notif.hasInlineReply,
                         "| picture", showPhoto ? "photo" : "icon", "| image", notif.image || "-", "| appIcon", notif.appIcon || "-");
    }
    readonly property bool critical: notif?.urgency === NotificationUrgency.Critical

    // Fixed palette for critical notifications (independent of the wallpaper)
    readonly property color critBg: Qt.rgba(32 / 255, 32 / 255, 34 / 255, 0.72)
    readonly property color critBorder: Qt.rgba(1, 1, 1, 0.10)
    readonly property color critFg: "#f2f2f2"
    readonly property color critDim: Qt.rgba(235 / 255, 235 / 255, 245 / 255, 0.62)
    readonly property color critMark: "#ff453a"

    // Keyboard: Enter runs the default action, Delete/Backspace dismisses
    activeFocusOnTab: true
    function runDefault() {
        const def = notif?.actions.find(a => a.identifier === "default");
        // The chat is open now (its action, or the dock app brought up): all its
        // messages go, not only this one (the app closes just the one clicked;
        // the copies kept in the history have no action). Taken before:
        // invoking may destroy notif
        const opens = !!def || (!!notif && Comms.defs.some(d => Comms.isFrom(d, notif)));
        const chat = opens && !Notifs.isTest(notif) ? Notifs.chatOf(notif) : [];
        // WhatsApp / Thunderbird live hidden (services/Comms.qml): bring them up with the dock
        if (notif) Comms.showFor(notif);
        if (def) def.invoke();
        // From the service: this card goes away with the first one
        if (chat.length) Notifs.dismissAll(chat);
    }
    Keys.onReturnPressed: runDefault()
    Keys.onEnterPressed: runDefault()
    Keys.onDeletePressed: notif.dismiss()
    Keys.onPressed: event => { if (event.key === Qt.Key_Backspace) { notif.dismiss(); event.accepted = true; } }

    // Type (Notifs.placeKind): progress bar, security code, call buttons, grouped messages
    readonly property string place: notif ? Notifs.placeKind(notif) : ""
    readonly property string code: place === "security" ? Notifs.codeOf(notif) : ""
    // In the history a chat is one card: its newest message, the earlier ones
    // under it (the last 3, one line each). Clicking "N messages" expands it:
    // every message, whole; on a popup too (the ones it counts, kept in the
    // history), which then stays until closed
    property bool expanded: false
    readonly property var thread: compact ? []
        : popup ? (expanded ? Notifs.threadOf(notif).slice(0, Notifs.countOf(notif)) : [])
        : Notifs.threadOf(notif)
    readonly property var olderMessages: thread.slice(1)
    readonly property int grouped: Math.max(Notifs.countOf(notif), thread.length)
    readonly property bool canExpand: grouped > 1 && !compact && !isMail
    readonly property bool isMail: !!Notifs.mailOf(notif)
    property bool copied: false

    // Level notification (volume, brightness…): Notifs.progressOf ≥ 0
    readonly property real level: Notifs.progressOf(notif)
    readonly property bool isLevel: place === "level"
    // Starts at the replaced notification's level and animates to this one's
    property real barLevel: Notifs.levelFrom[notif?.id] ?? level
    Behavior on barLevel { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
    Component.onCompleted: { barLevel = Qt.binding(() => card.level); logReply(); }
    implicitHeight: isLevel ? levelRow.implicitHeight + 22 : content.implicitHeight + (compact ? 16 : 24)
    radius: compact ? 12 : 18
    color: critical ? critBg : (popup ? card.pal.bg : card.pal.bgAlt)
    border.color: critical ? critBorder : card.pal.border
    border.width: 1

    // Notification bodies use Pango markup; Qt's StyledText doesn't know <span>,
    // so bold spans become <b>, other spans are unwrapped, newlines become <br>.
    function toStyled(s) {
        if (!s) return "";
        return s.replace(/<span([^>]*)>([\s\S]*?)<\/span>/g,
                         (m, attrs, inner) => /weight=['"]?bold/.test(attrs) ? "<b>" + inner + "</b>" : inner)
                .replace(/\n/g, "<br>");
    }

    // Messages and calls: the chat's photo (Settings → Picture on messages),
    // with the app's icon as a badge; "App icon" shows only the icon
    readonly property bool chat: place === "message" || place === "call"
    readonly property string photoSource: chat && Settings.v.msgPicture !== "icon" ? Notifs.photoOf(notif) : ""
    // The photo's file may be gone (Brave deletes it when the notification
    // closes, but the history keeps the card): then the app's icon
    property string brokenPhoto: ""
    readonly property bool showPhoto: photoSource !== "" && photoSource !== brokenPhoto
    // Icon: photo > image hint (not on chats set to "App icon") > app icon > generic bell
    readonly property string iconSource: (showPhoto ? photoSource : "")
        || (!chat ? Notifs.imageOf(notif) : "")
        || appIconSource
    // The app's icon (path or theme name)
    readonly property string appIconSource: Notifs.appIconOf(notif)

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        // Clicking the card runs the default action, if any
        onClicked: card.runDefault()
    }

    // ---------------- Level: icon · title · bar · percentage ----------------
    // Icon from the sync tag / summary (speaker by level, mic, sun, keyboard),
    // else the notification's own icon
    readonly property string levelGlyph: {
        const what = (Notifs.syncTag(notif) + " " + (notif?.summary ?? "")).toLowerCase();
        const off = level === 0 || /mute/i.test(notif?.body ?? "");
        if (/mic/.test(what)) return off ? "\uf131" : "\uf130";
        if (/bright|screen|backlight|kbd|keyboard/.test(what)) return /kbd|keyboard/.test(what) ? "\uf11c" : "\uf185";
        if (/vol|audio|sound/.test(what)) return off ? "\u{f0581}" : level < 34 ? "\u{f057f}" : level < 67 ? "\u{f0580}" : "\u{f057e}";
        return "";
    }
    RowLayout {
        id: levelRow
        visible: card.isLevel
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 12
        anchors.rightMargin: 16
        spacing: 12

        Rectangle {
            implicitWidth: 34; implicitHeight: 34; radius: 17
            color: card.level === 0 ? card.pal.bgHover : card.pal.accent
            Glyph { pal: card.pal;
                anchors.centerIn: parent
                visible: card.levelGlyph !== ""
                text: card.levelGlyph
                font.pixelSize: 15
                color: card.level === 0 ? card.pal.fgDim : card.pal.accentText
            }
            Image {
                anchors.centerIn: parent
                visible: card.levelGlyph === ""
                width: 20; height: 20
                source: card.levelGlyph === "" ? card.iconSource : ""
                sourceSize: Qt.size(40, 40)
                fillMode: Image.PreserveAspectFit
            }
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 6
            RowLayout {
                Layout.fillWidth: true
                Label { pal: card.pal;
                    Layout.fillWidth: true
                    text: (card.notif?.summary || card.notif?.appName || "").replace(/[:\s]+$/, "").trim()
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
                // The body when it isn't just the number ("Muted", a device…)
                Label { pal: card.pal;
                    readonly property string b: Notifs.plain(Notifs.bodyOf(card.notif)).trim()
                    visible: b !== "" && !/^\d+\s*%$/.test(b)
                    text: b
                    dim: true
                    font.pixelSize: 12
                }
                Label { pal: card.pal;
                    // "Muted" alone says it; no "0%" next to it
                    visible: card.level > 0 || /^\d/.test(Notifs.plain(Notifs.bodyOf(card.notif)).trim())
                    text: Math.round(card.level) + "%"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    font.features: { "tnum": 1 }
                    color: card.level > 100 ? card.pal.warn : card.pal.fg
                }
            }
            Bar {
                Layout.fillWidth: true
                implicitHeight: 6
                radius: 3
                value: card.barLevel / 100
                fillColor: card.level > 100 ? card.pal.warn : card.pal.accent
            }
        }
    }

    ColumnLayout {
        id: content
        visible: !card.isLevel
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: card.compact ? 8 : 12
        anchors.leftMargin: card.compact ? 10 : 14
        anchors.rightMargin: card.compact ? 8 : 12
        spacing: 8

        RowLayout {
            Layout.fillWidth: true
            spacing: 12

            // Icon
            Item {
                Layout.preferredWidth: 32
                Layout.preferredHeight: 32
                Layout.alignment: Qt.AlignTop
                // A photo is round (a chat) and fills the circle; an image
                // hint (screenshot…) gets rounded corners
                readonly property bool photo: card.showPhoto
                ClippingRectangle {
                    anchors.fill: parent
                    radius: parent.photo ? width / 2 : Notifs.imageOf(card.notif) ? 8 : 0
                    color: "transparent"
                    Image {
                        id: icon
                        anchors.fill: parent
                        source: card.iconSource
                        onStatusChanged: if (status === Image.Error && card.showPhoto) card.brokenPhoto = card.photoSource
                        sourceSize: Qt.size(64, 64)
                        fillMode: parent.parent.photo ? Image.PreserveAspectCrop : Image.PreserveAspectFit
                        asynchronous: true
                    }
                }
                // The app's icon on the photo's corner
                Rectangle {
                    visible: parent.photo && icon.status === Image.Ready && badge.status === Image.Ready
                    width: 16; height: 16; radius: 8
                    anchors.right: parent.right; anchors.bottom: parent.bottom
                    anchors.rightMargin: -3; anchors.bottomMargin: -3
                    color: card.critical ? card.critBg : card.pal.bg
                    Image {
                        id: badge
                        anchors.centerIn: parent
                        width: 13; height: 13
                        source: parent.parent.photo ? card.appIconSource : ""
                        sourceSize: Qt.size(32, 32)
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                    }
                }
                Glyph { pal: card.pal;
                    anchors.centerIn: parent
                    visible: icon.status !== Image.Ready
                    text: card.place === "call" ? "\uf095" : card.place === "security" ? "\uf084" : card.place === "reminder" ? "\uf073" : "\uf0f3"
                    color: card.critical ? card.critMark : card.pal.fgDim
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Label { pal: card.pal;
                    Layout.fillWidth: true
                    // App (Notifications tab) and/or context (the email account)
                    visible: (card.showApp && !!card.notif) || Notifs.contextOf(card.notif) !== ""
                    text: [card.showApp ? Notifs.appLabel(card.notif) : "", Notifs.contextOf(card.notif)]
                          .filter(t => t).join(" · ").toUpperCase()
                    elide: Text.ElideRight
                    color: card.critical ? card.critDim : card.pal.fgDim
                    font.pixelSize: 9
                    font.weight: Font.DemiBold
                    font.letterSpacing: 1
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Label { pal: card.pal;
                        Layout.fillWidth: true
                        text: Notifs.titleOf(card.notif)
                        elide: Text.ElideRight
                        color: card.critical ? card.critMark : card.pal.fg
                        font.pixelSize: card.critical ? 12 : (card.compact ? 13 : 15)
                        font.weight: card.critical ? Font.Bold : Font.DemiBold
                    }
                    // Grouped messages: how many this card stands for; click
                    // to see them all (or fold them back)
                    Rectangle {
                        visible: card.grouped > 1
                        implicitHeight: 18
                        implicitWidth: Math.max(18, groupLabel.implicitWidth + 12)
                        radius: 9
                        color: groupMouse.containsMouse ? Qt.lighter(card.pal.accent, 1.15) : card.pal.accent
                        Label { pal: card.pal; id: groupLabel; anchors.centerIn: parent
                                text: card.grouped + (card.isMail ? " new" : " messages") + (card.canExpand ? (card.expanded ? "  \u25b4" : "  \u25be") : "")
                                color: card.pal.accentText; font.pixelSize: 10; font.weight: Font.DemiBold }
                        MouseArea { id: groupMouse; anchors.fill: parent; enabled: card.canExpand
                                    hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: card.expanded = !card.expanded }
                    }
                    Label { pal: card.pal;
                        text: Notifs.timeAgo(card.notif)
                        color: card.critical ? card.critDim : card.pal.fgDim
                        font.pixelSize: 11
                    }
                    // Close (×)
                    Rectangle {
                        Layout.preferredWidth: 22
                        Layout.preferredHeight: 22
                        radius: 11
                        color: closeMouse.containsMouse ? (card.critical ? Qt.rgba(1, 1, 1, 0.12) : card.pal.bgHover)
                                                       : (card.critical ? Qt.rgba(1, 1, 1, 0.08) : "transparent")
                        Glyph { pal: card.pal; anchors.centerIn: parent; text: "\uf00d"; font.pixelSize: 11; color: card.critical ? card.critDim : card.pal.fgDim }
                        MouseArea { id: closeMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: card.thread.length > 1 ? Notifs.dismissThread(card.notif) : card.notif.dismiss() }
                    }
                }

                Label { pal: card.pal;
                    Layout.fillWidth: true
                    visible: text !== ""
                    text: card.toStyled(Notifs.bodyOf(card.notif))
                    textFormat: Text.StyledText
                    wrapMode: Text.Wrap
                    elide: Text.ElideRight
                    maximumLineCount: card.compact ? 1 : (card.popup ? 3 : 8)
                    color: card.critical ? card.critFg : card.pal.fgDim
                    font.pixelSize: card.compact ? 12 : 14
                    onLinkActivated: link => Qt.openUrlExternally(link)
                }

                // The chat's earlier messages under the newest (oldest last):
                // 3, one line each; expanded, all of them, whole
                Repeater {
                    model: card.expanded ? card.olderMessages : card.olderMessages.slice(0, 3)
                    delegate: RowLayout {
                        required property var modelData
                        Layout.fillWidth: true
                        spacing: 8
                        Label { pal: card.pal
                            Layout.fillWidth: true
                            text: card.expanded ? card.toStyled(Notifs.bodyOf(modelData)) : Notifs.plain(Notifs.bodyOf(modelData))
                            textFormat: card.expanded ? Text.StyledText : Text.PlainText
                            wrapMode: card.expanded ? Text.Wrap : Text.NoWrap
                            elide: Text.ElideRight
                            maximumLineCount: card.expanded ? 8 : 1
                            dim: true
                            font.pixelSize: card.expanded ? 13 : 12
                            onLinkActivated: link => Qt.openUrlExternally(link)
                        }
                        Label { pal: card.pal; Layout.alignment: Qt.AlignTop; text: Notifs.timeAgo(modelData); dim: true; font.pixelSize: 10 }
                    }
                }
                Label { pal: card.pal
                    visible: !card.expanded && card.olderMessages.length > 3
                    text: "+" + (card.olderMessages.length - 3) + " earlier"
                    dim: true
                    font.pixelSize: 11
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: card.expanded = true }
                }

                // Progress (downloads, copies…): a bar that fills in place
                RowLayout {
                    Layout.fillWidth: true
                    Layout.topMargin: 4
                    visible: card.place === "progress"
                    spacing: 10
                    Bar {
                        Layout.fillWidth: true
                        implicitHeight: 6
                        radius: 3
                        value: Math.min(1, card.level / 100)
                        Behavior on value { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                    }
                    Label { pal: card.pal; text: Math.round(card.level) + "%"; font.pixelSize: 12; font.weight: Font.DemiBold; font.features: { "tnum": 1 } }
                }
            }
        }

        // Actions (except "default", which is the card click)
        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            visible: (actionsRepeater.count > 0 || card.code !== "" || card.canReply) && !card.compact

            // Quick reply: opens the box below
            Rectangle {
                visible: card.canReply
                Layout.fillWidth: true
                implicitHeight: 30
                radius: 10
                color: replyMouse.containsMouse ? card.pal.bgHover : Theme.withAlpha(card.pal.accent, 0.16)
                Row {
                    anchors.centerIn: parent
                    spacing: 8
                    Glyph { pal: card.pal; text: "\uf112"; font.pixelSize: 11; anchors.verticalCenter: parent.verticalCenter }
                    Label { pal: card.pal; text: "Reply"; font.pixelSize: 12; font.weight: Font.DemiBold; anchors.verticalCenter: parent.verticalCenter }
                }
                MouseArea {
                    id: replyMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Comms.startReply(card.notif)
                }
            }

            // Security code: copy it (wl-copy) without opening anything
            Rectangle {
                visible: card.code !== ""
                Layout.fillWidth: true
                implicitHeight: 30
                radius: 10
                color: card.copied ? Theme.withAlpha(card.pal.good, 0.25) : (codeMouse.containsMouse ? card.pal.bgHover : Theme.withAlpha(card.pal.accent, 0.16))
                Row {
                    anchors.centerIn: parent
                    spacing: 8
                    Glyph { pal: card.pal; text: card.copied ? "\uf00c" : "\uf0c5"; font.pixelSize: 11; color: card.critical ? card.critFg : card.pal.fg; anchors.verticalCenter: parent.verticalCenter }
                    Label { pal: card.pal;
                        text: card.copied ? "Copied" : "Copy code  " + card.code
                        color: card.critical ? card.critFg : card.pal.fg
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                        font.family: card.copied ? Theme.font : "JetBrains Mono"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                MouseArea {
                    id: codeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { Quickshell.execDetached(["wl-copy", card.code]); card.copied = true; }
                }
            }

            Repeater {
                id: actionsRepeater
                model: (card.notif?.actions ?? []).filter(a => a.identifier !== "default")
                delegate: Rectangle {
                    id: act
                    required property var modelData
                    // Calls: answer in green, decline in red
                    readonly property color tone: card.place !== "call" ? "transparent"
                        : /answer|accept|contestar|aceptar|responder|join|unirse/i.test(modelData.text) ? card.pal.good
                        // Fixed red: card.pal.bad shifts hue when the wallpaper is red
                        : /decline|reject|rechazar|colgar|hang ?up|ignore|ignorar/i.test(modelData.text) ? card.pal.critical
                        : "transparent"
                    readonly property bool toned: tone.a > 0
                    Layout.fillWidth: true
                    implicitHeight: card.place === "call" ? 36 : 30
                    radius: card.place === "call" ? 18 : 10
                    color: toned ? (actMouse.containsMouse ? Qt.lighter(tone, 1.1) : tone)
                         : actMouse.containsMouse ? (card.critical ? Qt.rgba(1, 1, 1, 0.12) : card.pal.bgHover)
                                                  : (card.critical ? Qt.rgba(1, 1, 1, 0.06) : Theme.withAlpha(card.pal.fg, 0.06))
                    Label { pal: card.pal;
                        anchors.centerIn: parent
                        width: parent.width - 12
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData.text
                        font.weight: act.toned ? Font.DemiBold : Font.Normal
                        color: act.toned ? card.pal.onColor(act.tone) : card.critical ? card.critFg : card.pal.fg
                        font.pixelSize: 12
                    }
                    MouseArea { id: actMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: modelData.invoke() }
                }
            }
        }

    }

    FocusRing {}
}
