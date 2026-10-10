import QtQuick
import QtQuick.Layouts
import "./common"
import "./services"

// One cell of a tab's grid (see Config.tabs). A cell either
//   - stacks zones top → bottom:   { zones: ["AZone", "BZone"] }  (last fills)
//                                  { zones: [{ zone: "AZone", height: 0.6 }, …] }
//                                  { zones: [{ zone: "AZone", props: { foo: 1 } }] }
//                                  { zones: [{ zone: "AZone", link: "Controls" }] }  (click → that tab, zone highlighted)
//   - or splits into a row:        { cells: [{ width: 0.5, ... }, ...] }
// Cells nest, so any grid can be described.
Item {
    id: cell
    property var spec: ({})

    // --- Stacked zones ---
    ColumnLayout {
        anchors.fill: parent
        spacing: Config.spacing
        visible: !!cell.spec.zones

        // An entry is a zone name, or { zone: "Name", height: fraction } to give
        // it a fixed share of the cell's height
        readonly property int count: (cell.spec.zones ?? []).length
        readonly property real avail: height - spacing * Math.max(0, count - 1)

        Repeater {
            id: stackRepeater
            model: cell.spec.zones ?? []
            delegate: Loader {
                id: zoneLoader
                required property var modelData
                required property int index
                readonly property string zoneName: typeof modelData === "string" ? modelData : modelData.zone
                readonly property string link: typeof modelData === "string" ? "" : (modelData.link ?? "")
                readonly property real fraction: typeof modelData === "string" ? 0 : (modelData.height ?? 0)
                Layout.fillWidth: true
                Layout.fillHeight: fraction === 0 && index === cell.spec.zones.length - 1
                Layout.preferredHeight: fraction > 0 ? Math.round(parent.avail * fraction)
                                                     : (item ? item.implicitHeight : 0)
                source: Qt.resolvedUrl("zones/" + zoneName + ".qml")
                onStatusChanged: if (status === Loader.Error)
                    console.warn("panel: failed to load zone", zoneName)
                // { zone: "X", props: { … } } sets properties on the zone
                onLoaded: {
                    const props = typeof modelData === "string" ? null : modelData.props;
                    if (props) for (const k in props) item[k] = props[k];
                    if (link) {
                        item.clickable = true;
                        item.clicked.connect(() => PanelState.goTo(link, zoneName));
                    }
                }

                // Highlight this zone when a link elsewhere points at it
                Connections {
                    target: PanelState
                    function onFocusSerialChanged() {
                        if (zoneLoader.link || PanelState.focusZone !== zoneLoader.zoneName) return;
                        // visible is updated once the tab switch settles
                        Qt.callLater(() => { if (zoneLoader.item && zoneLoader.visible) zoneLoader.item.flash(); });
                    }
                }
            }
        }
    }

    // --- Nested row of cells ---
    Row {
        id: row
        anchors.fill: parent
        spacing: Config.spacing
        visible: !!cell.spec.cells
        readonly property var cells: cell.spec.cells ?? []
        readonly property real avail: width - spacing * Math.max(0, cells.length - 1)

        Repeater {
            model: row.cells
            delegate: Loader {
                required property var modelData
                width: Math.round(row.avail * modelData.width)
                height: row.height
                Component.onCompleted: setSource(Qt.resolvedUrl("Cell.qml"), { spec: modelData })
            }
        }
    }
}
