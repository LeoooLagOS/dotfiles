import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "./common"
import "./services"

// Notification popups: a column of cards at the top center of the focused
// monitor, below the bar. Each popup hides after its timeout (paused while
// hovered) but stays in the history (Notifications tab).
Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property var modelData
            screen: modelData

            visible: Notifs.popups.length > 0 && Hyprland.focusedMonitor?.name === modelData.name
                     && !PanelState.open
            color: "transparent"
            exclusionMode: ExclusionMode.Normal

            anchors.top: true
            margins.top: 6
            implicitWidth: 380
            implicitHeight: Math.max(1, stack.implicitHeight)

            WlrLayershell.namespace: "quickshell:notifications"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

            Column {
                id: stack
                width: parent.width
                spacing: 8

                Repeater {
                    model: Notifs.popups
                    delegate: NotificationCard {
                        id: popupCard
                        required property var modelData
                        notif: modelData
                        popup: true
                        width: stack.width

                        Timer {
                            interval: Notifs.timeoutFor(popupCard.modelData)
                            running: !popupCard.hovered && interval > 0     // 0 = until dismissed
                            onTriggered: Notifs.removePopup(popupCard.modelData)
                        }
                    }
                }
            }
        }
    }
}
