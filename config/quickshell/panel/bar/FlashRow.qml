import QtQuick
import "../common"
import "../services"

// A short message (BarState.flash: Do Not Disturb, caffeine, a to-do done…):
// icon · text · Undo when it has one. Shown by the island (bar/Island.qml) and,
// over a fullscreen window that covers the bar, by LevelOsd.qml; a click on
// either runs the Undo (BarState.undoFlash).
Row {
    id: row

    property color accent: Theme.accent
    property color ink: "#f1f3f5"
    property var flash: BarState.flash         // { icon, text, undo }

    spacing: 9
    Glyph { optical: true; text: row.flash?.icon ?? ""; color: row.accent; font.pixelSize: 14; anchors.verticalCenter: parent.verticalCenter }
    Label { text: row.flash?.text ?? ""; color: row.ink; font.pixelSize: 13; font.weight: Font.DemiBold; anchors.verticalCenter: parent.verticalCenter
            elide: Text.ElideRight; width: Math.min(implicitWidth, 360) }
    // Undo (click anywhere on the island)
    Rectangle {
        visible: !!row.flash?.undo
        implicitWidth: undoText.implicitWidth + 16
        implicitHeight: 20
        radius: 10
        color: row.accent
        anchors.verticalCenter: parent.verticalCenter
        Label { id: undoText; anchors.centerIn: parent; text: Tr.t("Undo"); color: Theme.onColor(row.accent); font.pixelSize: 11; font.weight: Font.Bold }
    }
}
