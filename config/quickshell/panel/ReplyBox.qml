import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Widgets
import "./common"
import "./services"

// Quick reply box (Comms.session): opened by a notification's Reply button
// and independent of it, since the app may close its notification any moment
// (WhatsApp closes its own when clicked, and after a few seconds anyway).
// Where messages pop up (Settings → Notifications → Messages), on the focused
// monitor, in the notifications' colors. It takes the keyboard: Enter sends,
// Esc cancels. Then "Sent" (or what went wrong) for a moment.
Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property var modelData
            screen: modelData
            readonly property var s: Comms.session
            readonly property string place: { const p = Settings.v.posMessage; return p === "off" || p === "under-panel" ? "bottom-right" : p; }
            readonly property bool atTop: place.startsWith("top")
            readonly property var pal: Theme.notifications

            visible: !!s && Hyprland.focusedMonitor?.name === modelData.name
            color: "transparent"
            exclusionMode: ExclusionMode.Normal
            anchors.top: atTop
            anchors.bottom: !atTop
            anchors.right: place.endsWith("right")
            anchors.left: place.endsWith("left")
            margins.top: atTop ? 6 : 0
            margins.bottom: atTop ? 0 : 10
            margins.right: place.endsWith("right") ? 10 : 0
            margins.left: place.endsWith("left") ? 10 : 0
            implicitWidth: 380
            implicitHeight: box.implicitHeight

            WlrLayershell.namespace: "quickshell:notifications"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: visible && Comms.sessionState !== "sent" ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

            onVisibleChanged: if (visible) { field.text = ""; focusTimer.restart(); }
            Timer { id: focusTimer; interval: 50; onTriggered: field.input.forceActiveFocus() }

            Rectangle {
                id: box
                width: parent.width
                implicitHeight: col.implicitHeight + 24
                radius: 18
                color: win.pal.bg
                border.color: win.pal.border

                ColumnLayout {
                    id: col
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.margins: 12
                    spacing: 8

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        // The chat's photo (round) if it came with one, else the app's icon
                        ClippingRectangle {
                            id: pic
                            property bool photoOk: !!win.s?.photo && photoImg.status !== Image.Error
                            visible: (photoOk ? photoImg : appImg).status === Image.Ready
                            Layout.preferredWidth: 26
                            Layout.preferredHeight: 26
                            radius: photoOk ? 13 : 0
                            color: "transparent"
                            Image {
                                id: photoImg
                                anchors.fill: parent
                                visible: pic.photoOk
                                source: win.s?.photo ?? ""
                                sourceSize: Qt.size(52, 52)
                                fillMode: Image.PreserveAspectCrop
                            }
                            Image {
                                id: appImg
                                anchors.fill: parent
                                visible: !pic.photoOk
                                source: pic.photoOk ? "" : (win.s?.icon ?? "")
                                sourceSize: Qt.size(48, 48)
                            }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Label { pal: win.pal; text: (win.s?.app ?? "").toUpperCase(); dim: true; font.pixelSize: 9; font.weight: Font.DemiBold; font.letterSpacing: 1 }
                            Label { pal: win.pal; Layout.fillWidth: true; text: Tr.t("Reply to %1", win.s?.who ?? ""); font.pixelSize: 14; font.weight: Font.DemiBold; elide: Text.ElideRight }
                        }
                        IconButton {
                            pal: win.pal
                            icon: ""; iconSize: 11
                            implicitWidth: 26; implicitHeight: 26; border.width: 0
                            onClicked: Comms.cancelReply()
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        TextField {
                            id: field
                            pal: win.pal
                            Layout.fillWidth: true
                            enabled: Comms.sessionState === "" || Comms.sessionState === "failed"
                            placeholder: Tr.t("Message")
                            onAccepted: Comms.sendReply(text)
                            Keys.onEscapePressed: Comms.cancelReply()
                        }
                        IconButton {
                            pal: win.pal
                            icon: ""           // paper plane
                            iconSize: 13
                            implicitWidth: 36; implicitHeight: 32
                            active: field.text.trim() !== ""
                            enabled: active && field.enabled
                            onClicked: Comms.sendReply(field.text)
                        }
                    }

                    Label {
                        pal: win.pal
                        Layout.fillWidth: true
                        dim: Comms.sessionState !== "failed"
                        color: Comms.sessionState === "failed" ? win.pal.bad : Comms.sessionState === "sent" ? win.pal.good : win.pal.fgDim
                        font.pixelSize: 11
                        wrapMode: Text.Wrap
                        text: Comms.sessionState === "sending" ? Tr.t("Sending…")
                            : Comms.sessionState === "sent" ? "  " + Tr.t("Sent")
                            : Comms.sessionState === "failed" ? Tr.t("Couldn't send it: open the app to answer (Super Y)")
                            : Tr.t("Enter to send · Esc to cancel")
                    }
                }
            }
        }
    }
}
