import QtQuick

// A Nerd Font icon, e.g. Glyph { text: "" }
// Codepoints: https://www.nerdfonts.com/cheat-sheet
// `optical`: centered by its ink, not by the font's box (Nerd Font glyphs sit
// off-center in their box, some by a pixel or two): for icons alone in a button.
Text {
    id: glyph
    property var pal: Theme.panel              // colors from another palette (notification popups)
    property bool optical: false
    color: pal.fg
    font.family: Theme.iconFont
    font.pixelSize: 16
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    TextMetrics { id: ink; font: glyph.font; text: glyph.optical ? glyph.text : "" }
    transform: Translate {
        x: glyph.optical && glyph.text ? Math.round(ink.advanceWidth / 2 - ink.tightBoundingRect.x - ink.tightBoundingRect.width / 2) : 0
        y: glyph.optical && glyph.text ? Math.round(glyph.height / 2 - glyph.baselineOffset - ink.tightBoundingRect.y - ink.tightBoundingRect.height / 2) : 0
    }
}
