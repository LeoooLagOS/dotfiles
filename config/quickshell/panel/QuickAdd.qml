import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "./common"
import "./services"

// Quick capture box (services/Capture.qml): top center of the focused
// monitor, under the bar. Type in plain words ("entregar reporte viernes
// 18:00", "clase mañana de 10 a 12 @ CCO3 310"); the chips below show what
// it understood, live. Enter saves · Tab task ↔ event · Esc closes.
Scope {
    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: win
            required property var modelData
            screen: modelData

            visible: Capture.shown && Hyprland.focusedMonitor?.name === modelData.name
            color: "transparent"
            exclusionMode: ExclusionMode.Ignore
            anchors.top: true
            margins.top: Settings.v.barHeight + 14
            implicitWidth: 620
            implicitHeight: card.implicitHeight + 20

            WlrLayershell.namespace: "quickshell:capture"
            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: visible ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

            // Every open (also while shown): its text, the cursor at the end
            Connections {
                target: Capture
                function onOpened() { input.text = Capture.text; input.cursorPosition = input.text.length; focusTimer.restart(); }
            }
            Timer { id: focusTimer; interval: 40; onTriggered: input.forceActiveFocus() }

            Rectangle {
                id: card
                x: 10
                width: parent.width - 20
                implicitHeight: col.implicitHeight + 28
                radius: 20
                color: Theme.mix(Theme.panel.base, Theme.light ? "#ffffff" : "#000000", 0.25)
                border.color: Theme.border

                ColumnLayout {
                    id: col
                    x: 16; y: 14
                    width: parent.width - 32
                    spacing: 10

                    // Where it came from (a notification)
                    Label {
                        visible: Capture.source !== ""
                        Layout.fillWidth: true
                        text: Tr.t("From %1", Capture.source)
                        dim: true
                        font.pixelSize: 11
                        elide: Text.ElideRight
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        Glyph { text: Capture.result.kind === "event" ? "" : ""; font.pixelSize: 17; color: Theme.accent }
                        TextInput {
                            id: input
                            Layout.fillWidth: true
                            color: Theme.fg
                            font.family: Theme.font
                            font.pixelSize: 17
                            clip: true
                            selectByMouse: true
                            onTextChanged: Capture.text = text
                            onAccepted: Capture.save()
                            Keys.onEscapePressed: Capture.close()
                            Keys.onTabPressed: Capture.toggleKind()
                            Keys.onBacktabPressed: Capture.toggleKind()
                            Label {
                                anchors.verticalCenter: parent.verticalCenter
                                visible: !input.text
                                text: Tr.t("Add anything… “entregar reporte viernes 18:00”, “clase mañana de 10 a 12 @ CCO3 310”")
                                dim: true
                                font.pixelSize: 15
                                elide: Text.ElideRight
                                width: input.width
                            }
                        }
                    }

                    // What it understood
                    Flow {
                        Layout.fillWidth: true
                        spacing: 6
                        visible: Capture.chips.length > 0
                        Repeater {
                            model: Capture.chips
                            delegate: Rectangle {
                                required property var modelData
                                required property int index
                                implicitWidth: chipRow.implicitWidth + 16
                                implicitHeight: 24
                                radius: 12
                                color: index === 0 ? Theme.accent : Theme.withAlpha(Theme.accent2, 0.16)
                                Row {
                                    id: chipRow
                                    anchors.centerIn: parent
                                    spacing: 5
                                    Glyph { text: modelData.icon; font.pixelSize: 10; color: index === 0 ? Theme.accentText : Theme.accent2; anchors.verticalCenter: parent.verticalCenter }
                                    Label { text: modelData.text; font.pixelSize: 11; font.weight: Font.DemiBold; color: index === 0 ? Theme.accentText : Theme.fg; anchors.verticalCenter: parent.verticalCenter }
                                }
                                // The kind chip switches task ↔ event
                                MouseArea { anchors.fill: parent; enabled: index === 0; cursorShape: Qt.PointingHandCursor; onClicked: Capture.toggleKind() }
                            }
                        }
                        Label {
                            visible: Capture.result.title !== ""
                            height: 24
                            verticalAlignment: Text.AlignVCenter
                            leftPadding: 4
                            text: "“" + Capture.result.title + "”"
                            dim: true
                            font.pixelSize: 11
                            font.italic: true
                        }
                    }

                    Label {
                        Layout.fillWidth: true
                        text: Tr.t("Enter save  ·  Tab task ↔ event  ·  Esc close")
                        dim: true
                        font.pixelSize: 10
                        horizontalAlignment: Text.AlignRight
                    }
                }
            }
        }
    }
}
