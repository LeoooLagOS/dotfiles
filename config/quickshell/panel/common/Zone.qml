import QtQuick

// Container for one panel zone: rounded card with optional header.
// Put the zone's content inside; it is laid out below the header.
Rectangle {
    id: root
    property string title: ""
    property string icon: ""
    property string badge: ""         // small accent pill shown before the title (instead of the icon)
    property bool accentHeader: false // header icon + title in the accent color
    property bool centered: false     // center the content vertically (no header)
    property bool clickable: false    // whole card clickable → clicked()
    signal clicked()
    default property alias content: body.data
    property alias actions: actionsRow.data    // buttons shown at the right of the header
    property bool closable: false              // × at the end of the header → closeRequested()
    signal closeRequested()

    // Clickable zones can be focused with Tab and pressed with Enter/Space
    activeFocusOnTab: clickable
    Keys.onReturnPressed: if (clickable) clicked()
    Keys.onEnterPressed: if (clickable) clicked()
    Keys.onSpacePressed: if (clickable) clicked()

    readonly property real headerHeight: header.visible ? header.y + header.height + 10 : Theme.zonePadding
    implicitHeight: headerHeight + body.implicitHeight + Theme.zonePadding
    color: Theme.bgAlt
    Behavior on color { ColorAnimation { duration: Theme.anim } }
    radius: Theme.zoneRadius
    border.color: Theme.border
    border.width: 1

    // Below the content, so buttons inside the zone still get their clicks
    MouseArea {
        anchors.fill: parent
        enabled: root.clickable
        cursorShape: root.clickable ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.clicked()
    }

    Row {
        id: header
        visible: root.title !== ""
        x: Theme.zonePadding
        y: Theme.zonePadding - 2
        spacing: 8
        Glyph { text: root.icon; font.pixelSize: 13; color: root.accentHeader ? Theme.accent : Theme.fgDim; visible: root.icon !== "" && root.badge === "" }
        Rectangle {
            visible: root.badge !== ""
            anchors.verticalCenter: parent.verticalCenter
            width: Math.max(height, badgeLabel.implicitWidth + 12)
            height: 18
            radius: 9
            color: Theme.accent
            Label { id: badgeLabel; anchors.centerIn: parent; text: root.badge; color: Theme.onAccent; font.pixelSize: 11; font.weight: Font.Bold }
        }
        Label { text: root.title.toUpperCase(); color: root.accentHeader ? Theme.accent : Theme.fgDim; font.pixelSize: 11; font.weight: Font.DemiBold; font.letterSpacing: 1 }
    }

    // Header actions (right side, vertically centered on the header)
    Row {
        visible: header.visible
        anchors.right: parent.right
        anchors.rightMargin: Theme.zonePadding - 4
        anchors.verticalCenter: header.verticalCenter
        spacing: 4
        z: 2
        Row { id: actionsRow; spacing: 4 }
        IconButton {
            visible: root.closable
            icon: "\uf00d"
            iconSize: 11; implicitWidth: 28; implicitHeight: 24
            onClicked: root.closeRequested()
        }
    }

    // Column so hidden children (visible: false) take no space
    Column {
        id: body
        x: Theme.zonePadding
        y: !header.visible && root.centered
           ? Math.max(Theme.zonePadding, Math.round((root.height - body.implicitHeight) / 2))
           : root.headerHeight
        width: root.width - 2 * Theme.zonePadding
    }

    FocusRing { visible: root.clickable && root.activeFocus }

    // Pulse of the accent around the zone and keyboard focus on it (Tab then
    // moves to its controls). Called when a link from another tab points here.
    function flash() {
        root.forceActiveFocus();
        flashAnim.restart();
    }
    Rectangle {
        id: flashRing
        anchors.fill: parent
        radius: root.radius
        color: Theme.withAlpha(Theme.accent, 0.08)
        border.color: Theme.accent
        border.width: 2
        opacity: 0
        z: 9
    }
    SequentialAnimation {
        id: flashAnim
        NumberAnimation { target: flashRing; property: "opacity"; from: 0; to: 1; duration: 160; easing.type: Easing.OutCubic }
        PauseAnimation { duration: 700 }
        NumberAnimation { target: flashRing; property: "opacity"; to: 0; duration: 700; easing.type: Easing.InOutCubic }
    }
}
