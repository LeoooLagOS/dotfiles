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

    implicitHeight: content.implicitHeight + (compact ? 16 : 24)
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

    ColumnLayout {
        id: content
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
                    text: "\uf0f3"
                    color: card.critical ? card.critMark : Theme.fgDim
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Label {
                    Layout.fillWidth: true
                    visible: card.showApp && !!card.notif?.appName
                    text: (card.notif?.appName ?? "").toUpperCase()
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
                        text: card.notif?.summary || card.notif?.appName || ""
                        color: card.critical ? card.critMark : Theme.fg
                        font.pixelSize: card.critical ? 12 : (card.compact ? 13 : 15)
                        font.weight: card.critical ? Font.Bold : Font.DemiBold
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
                    text: card.toStyled(card.notif?.body)
                    textFormat: Text.StyledText
                    wrapMode: Text.Wrap
                    elide: Text.ElideRight
                    maximumLineCount: card.compact ? 1 : (card.popup ? 3 : 8)
                    color: card.critical ? card.critFg : Theme.fgDim
                    font.pixelSize: card.compact ? 12 : 14
                    onLinkActivated: link => Qt.openUrlExternally(link)
                }
            }
        }

        // Actions (except "default", which is the card click)
        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            visible: actionsRepeater.count > 0 && !card.compact

            Repeater {
                id: actionsRepeater
                model: (card.notif?.actions ?? []).filter(a => a.identifier !== "default")
                delegate: Rectangle {
                    required property var modelData
                    Layout.fillWidth: true
                    implicitHeight: 30
                    radius: 10
                    color: actMouse.containsMouse ? (card.critical ? Qt.rgba(1, 1, 1, 0.12) : Theme.bgHover)
                                                  : (card.critical ? Qt.rgba(1, 1, 1, 0.06) : Theme.withAlpha(Theme.fg, 0.06))
                    Label {
                        anchors.centerIn: parent
                        width: parent.width - 12
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData.text
                        color: card.critical ? card.critFg : Theme.fg
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
