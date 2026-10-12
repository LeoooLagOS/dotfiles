import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "./common"
import "./services"

// Notification popups, on the focused monitor, in up to four places chosen per
// type (Settings → Notifications → Where popups appear; Notifs.placeOf):
//   top           top center, below the bar — system, levels, critical
//   top-left      top left corner — calls
//   top-right     top right corner — now playing, other apps, reminders
//   bottom-right  bottom right corner — messages
//   bottom        bottom center
//   under-panel   while the panel is open, right below it: only the important
//                 ones (critical, calls, security codes, reminders, Notifs.important);
//                 the other places wait until it closes
// The newest card sits nearest the screen edge: first at the top places, last
// at the bottom ones. Each popup hides after its timeout (paused while hovered)
// but stays in the history (Notifications tab); levels and transient ones don't.
Scope {
    Variants {
        model: Quickshell.screens

        Scope {
            id: perScreen
            required property var modelData

            Variants {
                model: ["top", "top-left", "top-right", "bottom-right", "bottom", "under-panel"]

                PanelWindow {
                    id: win
                    required property string modelData
                    readonly property string place: modelData
                    readonly property bool underPanel: place === "under-panel"
                    readonly property bool atTop: place.startsWith("top") || underPanel
                    readonly property bool atRight: place.endsWith("right")
                    readonly property bool atLeft: place.endsWith("left")
                    readonly property var items: Notifs.popupsAt(place)
                    screen: perScreen.modelData

                    visible: items.length > 0 && Hyprland.focusedMonitor?.name === perScreen.modelData.name
                             && PanelState.open === underPanel
                    color: "transparent"
                    exclusionMode: ExclusionMode.Normal

                    anchors.top: atTop
                    anchors.bottom: !atTop
                    anchors.right: atRight
                    anchors.left: atLeft
                    margins.left: atLeft ? 10 : 0
                    margins.top: underPanel ? PanelState.cardBottom + 12 : atTop ? 6 : 0
                    margins.bottom: atTop ? 0 : 10
                    margins.right: atRight ? 10 : 0
                    implicitWidth: 380
                    implicitHeight: Math.max(1, stack.implicitHeight)

                    WlrLayershell.namespace: "quickshell:notifications"
                    WlrLayershell.layer: WlrLayer.Overlay
                    // Typing a quick reply needs the keyboard
                    WlrLayershell.keyboardFocus: Notifs.replying > 0 ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

                    Column {
                        id: stack
                        width: parent.width
                        spacing: 8

                        Repeater {
                            // Newest nearest the edge
                            model: win.atTop ? win.items.slice().reverse() : win.items
                            delegate: NotificationCard {
                                id: popupCard
                                required property var modelData
                                notif: modelData
                                popup: true
                                width: stack.width

                                Timer {
                                    interval: Notifs.timeoutFor(popupCard.modelData)
                                    running: !popupCard.hovered && !popupCard.replying && interval > 0     // 0 = until dismissed
                                    onTriggered: Notifs.removePopup(popupCard.modelData)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
