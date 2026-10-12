import QtQuick
import QtQuick.Layouts

// Rounded single-line text input with placeholder.
//   TextField { placeholder: "Title"; onAccepted: … }
// Esc clears the text (a second Esc reaches the panel and closes it).
Rectangle {
    id: root
    property alias text: input.text
    property alias input: input
    property string placeholder: ""
    property string icon: ""
    property bool invalid: false
    signal accepted()

    implicitHeight: 30
    implicitWidth: 120
    radius: 10
    property var pal: Theme.panel              // colors from another palette (notification popups)
    color: Theme.withAlpha(pal.base, 0.35)
    border.color: invalid ? pal.bad : (input.activeFocus ? pal.accent : pal.border)

    function focusInput() { input.forceActiveFocus(); }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 8
        spacing: 6

        Glyph { visible: root.icon !== ""; text: root.icon; font.pixelSize: 11; color: root.pal.fgDim }

        TextInput {
            id: input
            Layout.fillWidth: true
            color: root.pal.fg
            font.family: Theme.font
            font.pixelSize: 12
            clip: true
            selectByMouse: true
            onAccepted: root.accepted()
            Keys.onEscapePressed: event => {
                if (text !== "") { text = ""; event.accepted = true; }
                else event.accepted = false;
            }
            Label {
                anchors.verticalCenter: parent.verticalCenter
                visible: !input.text && !input.activeFocus
                text: root.placeholder
                pal: root.pal
                dim: true
                font.pixelSize: 12
            }
        }
    }
}
