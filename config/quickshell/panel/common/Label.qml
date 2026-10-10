import QtQuick

// Text in the panel's font and colors. `dim` = secondary text.
Text {
    property bool dim: false
    color: dim ? Theme.fgDim : Theme.fg
    font.family: Theme.font
    font.pixelSize: 14
    elide: Text.ElideRight
    verticalAlignment: Text.AlignVCenter
}
