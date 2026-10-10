import QtQuick
import "./common"

// Builds one tab from its Config.tabs entry: rows (fractions of the height),
// each row being a Cell that splits into cells (fractions of the width).
Item {
    id: page
    required property var rows

    readonly property real avail: height - Config.spacing * Math.max(0, rows.length - 1)

    Column {
        anchors.fill: parent
        spacing: Config.spacing

        Repeater {
            model: page.rows
            delegate: Cell {
                required property var modelData
                width: page.width
                height: Math.round(page.avail * modelData.height)
                spec: ({ cells: modelData.cells })
            }
        }
    }
}
