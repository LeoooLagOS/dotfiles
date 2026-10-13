import QtQuick
import "../common"
import "../services"

// The microphone and camera of the call going on (services/Call.qml), red
// while off. In whichever twin shows the call (bar/Agenda.qml or bar/Glance.qml).
Row {
    spacing: 4

    CallButton {
        off: Call.micMuted
        enabled: Call.micKnown
        icon: off ? "\u{f036d}" : "\u{f036c}"
        onToggle: Call.toggleMic()
    }
    CallButton {
        off: !Call.camOn
        icon: off ? "\u{f0568}" : "\u{f0567}"
        onToggle: Call.toggleCam()
    }

    component CallButton: Rectangle {
        property bool off: false
        property string icon: ""
        signal toggle()
        implicitWidth: 24
        implicitHeight: 22
        radius: 11
        opacity: enabled ? 1 : 0.4
        color: off ? Theme.bad : btnMouse.containsMouse ? Theme.withAlpha(Theme.fg, 0.16) : Theme.withAlpha(Theme.fg, 0.08)
        Glyph { anchors.centerIn: parent; text: parent.icon; font.pixelSize: 13; color: parent.off ? Theme.onColor(Theme.bad) : Theme.fg }
        MouseArea { id: btnMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: parent.toggle() }
    }
}
