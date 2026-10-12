import QtQuick

// Text in the panel's font and colors. `dim` = secondary text.
Text {
    property bool dim: false
    property var pal: Theme.panel              // colors from another palette (notification popups)
    color: dim ? pal.fgDim : pal.fg
    font.family: Theme.font
    font.pixelSize: 14
    elide: Text.ElideRight
    verticalAlignment: Text.AlignVCenter
}
