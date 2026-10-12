import QtQuick

// A Nerd Font icon, e.g. Glyph { text: "\uf011" }
// Codepoints: https://www.nerdfonts.com/cheat-sheet
Text {
    property var pal: Theme.panel              // colors from another palette (notification popups)
    color: pal.fg
    font.family: Theme.iconFont
    font.pixelSize: 16
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
}
