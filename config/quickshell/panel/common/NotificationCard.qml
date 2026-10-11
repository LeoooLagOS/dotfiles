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
        if (def) def.invoke();
    }
    Keys.onReturnPressed: runDefault()
    Keys.onEnterPressed: runDefault()
    Keys.onDeletePressed: notif.dismiss()
    Keys.onPressed: event => { if (event.key === Qt.Key_Backspace) { notif.dismiss(); event.accepted = true; } }

    // Type (Notifs.placeKind): progress bar, security code, call buttons, grouped messages
    readonly property string place: notif ? Notifs.placeKind(notif) : ""
    readonly property string code: place === "security" ? Notifs.codeOf(notif) : ""
    readonly property int grouped: Notifs.countOf(notif)
    readonly property bool isMail: !!Notifs.mailOf(notif)
    property bool copied: false

    // Level notification (volume, brightness…): Notifs.progressOf ≥ 0
    readonly property real level: Notifs.progressOf(notif)
    readonly property bool isLevel: place === "level"
    // Starts at the replaced notification's level and animates to this one's
    property real barLevel: Notifs.levelFrom[notif?.id] ?? level
    Behavior on barLevel { NumberAnimation { duration: 160; easing.type: Easing.OutCubic } }
    Component.onCompleted: barLevel = Qt.binding(() => card.level)
    implicitHeight: isLevel ? levelRow.implicitHeight + 22 : content.implicitHeight + (compact ? 16 : 24)
    radius: compact ? 12 : 18
    color: critical ? critBg : (popup ? Theme.bg : Theme.bgAlt)
    border.color: critical ? critBorder : Theme.border
    border.width: 1

    // Notification bodies use Pango markup; Qt's StyledText doesn't know <span>,
    // so bold spans become <b>, other spans are unwrapped, newlines become <br>.
    function toStyled(s) {
        if (!s) return "";
        return s.replace(/<span([^>]*)>([\s\S]*?)<\/span>/g,
                         (m, attrs, inner) => /weight=['"]?bold/.test(attrs) ? "<b>" + inner + "</b>" : inner)
                .replace(/\n/g, "<br>");
    }

    // App icon: image hint > app icon (path or theme name) > generic bell
    readonly property string iconSource: {
        const n = notif;
        if (!n) return "";
        // image hint; "image://icon/<name>" is a theme icon that may not exist
        if (n.image && !n.image.startsWith("image://icon/")) return n.image;
        // A web app installed from the browser: its own icon, not the browser's
        const web = Notifs.webAppIcon(n);
        if (web) return web.startsWith("file://") || web.startsWith("/") ? web
                      : Quickshell.hasThemeIcon(web) ? Quickshell.iconPath(web) : "";
        const imgIcon = n.image ? n.image.slice("image://icon/".length) : "";
        if (n.appIcon && (n.appIcon.startsWith("/") || n.appIcon.includes("://"))) return n.appIcon;
        // Only theme icons that exist (iconPath alone returns a "missing" image)
        for (const name of [imgIcon, n.appIcon, n.desktopEntry, (n.appName || "").toLowerCase()])
            if (name && Quickshell.hasThemeIcon(name)) return Quickshell.iconPath(name);
        return "";
    }

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
            color: card.level === 0 ? Theme.bgHover : Theme.accent
            Glyph {
                anchors.centerIn: parent
                visible: card.levelGlyph !== ""
                text: card.levelGlyph
                font.pixelSize: 15
                color: card.level === 0 ? Theme.fgDim : Theme.accentText
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
                Label {
                    Layout.fillWidth: true
                    text: (card.notif?.summary || card.notif?.appName || "").replace(/[:\s]+$/, "").trim()
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
                // The body when it isn't just the number ("Muted", a device…)
                Label {
                    readonly property string b: Notifs.plain(Notifs.bodyOf(card.notif)).trim()
                    visible: b !== "" && !/^\d+\s*%$/.test(b)
                    text: b
                    dim: true
                    font.pixelSize: 12
                }
                Label {
                    // "Muted" alone says it; no "0%" next to it
                    visible: card.level > 0 || /^\d/.test(Notifs.plain(Notifs.bodyOf(card.notif)).trim())
                    text: Math.round(card.level) + "%"
                    font.pixelSize: 13
                    font.weight: Font.DemiBold
                    font.features: { "tnum": 1 }
                    color: card.level > 100 ? Theme.warn : Theme.fg
                }
            }
            Bar {
                Layout.fillWidth: true
                implicitHeight: 6
                radius: 3
                value: card.barLevel / 100
                fillColor: card.level > 100 ? Theme.warn : Theme.accent
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
                ClippingRectangle {
                    anchors.fill: parent
                    radius: card.notif?.image ? 8 : 0
                    color: "transparent"
                    Image {
                        id: icon
                        anchors.fill: parent
                        source: card.iconSource
                        sourceSize: Qt.size(64, 64)
                        fillMode: Image.PreserveAspectFit
                        asynchronous: true
                    }
                }
                Glyph {
                    anchors.centerIn: parent
                    visible: icon.status !== Image.Ready
                    text: card.place === "call" ? "\uf095" : card.place === "security" ? "\uf084" : card.place === "reminder" ? "\uf073" : "\uf0f3"
                    color: card.critical ? card.critMark : Theme.fgDim
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Label {
                    Layout.fillWidth: true
                    // App (Notifications tab) and/or context (the email account)
                    visible: (card.showApp && !!card.notif) || Notifs.contextOf(card.notif) !== ""
                    text: [card.showApp ? Notifs.appLabel(card.notif) : "", Notifs.contextOf(card.notif)]
                          .filter(t => t).join(" · ").toUpperCase()
                    elide: Text.ElideRight
                    color: card.critical ? card.critDim : Theme.fgDim
                    font.pixelSize: 9
                    font.weight: Font.DemiBold
                    font.letterSpacing: 1
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    Label {
                        Layout.fillWidth: true
                        text: Notifs.titleOf(card.notif)
                        elide: Text.ElideRight
                        color: card.critical ? card.critMark : Theme.fg
                        font.pixelSize: card.critical ? 12 : (card.compact ? 13 : 15)
                        font.weight: card.critical ? Font.Bold : Font.DemiBold
                    }
                    // Grouped messages: how many this card stands for
                    Rectangle {
                        visible: card.grouped > 1
                        implicitHeight: 18
                        implicitWidth: Math.max(18, groupLabel.implicitWidth + 12)
                        radius: 9
                        color: Theme.accent
                        Label { id: groupLabel; anchors.centerIn: parent; text: card.grouped + (card.isMail ? " new" : " messages"); color: Theme.accentText; font.pixelSize: 10; font.weight: Font.DemiBold }
                    }
                    Label {
                        text: Notifs.timeAgo(card.notif)
                        color: card.critical ? card.critDim : Theme.fgDim
                        font.pixelSize: 11
                    }
                    // Close (×)
                    Rectangle {
                        Layout.preferredWidth: 22
                        Layout.preferredHeight: 22
                        radius: 11
                        color: closeMouse.containsMouse ? (card.critical ? Qt.rgba(1, 1, 1, 0.12) : Theme.bgHover)
                                                       : (card.critical ? Qt.rgba(1, 1, 1, 0.08) : "transparent")
                        Glyph { anchors.centerIn: parent; text: "\uf00d"; font.pixelSize: 11; color: card.critical ? card.critDim : Theme.fgDim }
                        MouseArea { id: closeMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: card.notif.dismiss() }
                    }
                }

                Label {
                    Layout.fillWidth: true
                    visible: text !== ""
                    text: card.toStyled(Notifs.bodyOf(card.notif))
                    textFormat: Text.StyledText
                    wrapMode: Text.Wrap
                    elide: Text.ElideRight
                    maximumLineCount: card.compact ? 1 : (card.popup ? 3 : 8)
                    color: card.critical ? card.critFg : Theme.fgDim
                    font.pixelSize: card.compact ? 12 : 14
                    onLinkActivated: link => Qt.openUrlExternally(link)
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
                    Label { text: Math.round(card.level) + "%"; font.pixelSize: 12; font.weight: Font.DemiBold; font.features: { "tnum": 1 } }
                }
            }
        }

        // Actions (except "default", which is the card click)
        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            visible: (actionsRepeater.count > 0 || card.code !== "") && !card.compact

            // Security code: copy it (wl-copy) without opening anything
            Rectangle {
                visible: card.code !== ""
                Layout.fillWidth: true
                implicitHeight: 30
                radius: 10
                color: card.copied ? Theme.withAlpha(Theme.good, 0.25) : (codeMouse.containsMouse ? Theme.bgHover : Theme.withAlpha(Theme.accent, 0.16))
                Row {
                    anchors.centerIn: parent
                    spacing: 8
                    Glyph { text: card.copied ? "\uf00c" : "\uf0c5"; font.pixelSize: 11; color: card.critical ? card.critFg : Theme.fg; anchors.verticalCenter: parent.verticalCenter }
                    Label {
                        text: card.copied ? "Copied" : "Copy code  " + card.code
                        color: card.critical ? card.critFg : Theme.fg
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
                        : /answer|accept|contestar|aceptar|responder|join|unirse/i.test(modelData.text) ? Theme.good
                        // Fixed red: Theme.bad shifts hue when the wallpaper is red
                        : /decline|reject|rechazar|colgar|hang ?up|ignore|ignorar/i.test(modelData.text) ? Theme.critical
                        : "transparent"
                    readonly property bool toned: tone.a > 0
                    Layout.fillWidth: true
                    implicitHeight: card.place === "call" ? 36 : 30
                    radius: card.place === "call" ? 18 : 10
                    color: toned ? (actMouse.containsMouse ? Qt.lighter(tone, 1.1) : tone)
                         : actMouse.containsMouse ? (card.critical ? Qt.rgba(1, 1, 1, 0.12) : Theme.bgHover)
                                                  : (card.critical ? Qt.rgba(1, 1, 1, 0.06) : Theme.withAlpha(Theme.fg, 0.06))
                    Label {
                        anchors.centerIn: parent
                        width: parent.width - 12
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData.text
                        font.weight: act.toned ? Font.DemiBold : Font.Normal
                        color: act.toned ? Theme.onColor(act.tone) : card.critical ? card.critFg : Theme.fg
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
