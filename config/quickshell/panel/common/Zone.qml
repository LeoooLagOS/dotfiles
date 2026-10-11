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
    property alias titleActions: titleRow.data // small controls right after the title (view switch…)
    property bool closable: false              // × at the end of the header → closeRequested()
    // Fixed height with more content: the content scrolls under the header
    // (wheel, ↑/↓, PgUp/PgDn, Home/End) with a thin scrollbar on the right
    property bool scrollable: false
    signal closeRequested()

    // Clickable zones can be focused with Tab and pressed with Enter/Space
    activeFocusOnTab: clickable
    Keys.onReturnPressed: if (clickable) clicked()
    Keys.onEnterPressed: if (clickable) clicked()
    Keys.onSpacePressed: if (clickable) clicked()
    // Scrolling from the keyboard (keys that the focused control didn't use)
    function scrollBy(dy) {
        scroller.contentY = Math.max(0, Math.min(scroller.contentHeight - scroller.height, scroller.contentY + dy));
    }
    Keys.onUpPressed: event => { if (scrollable) scrollBy(-40); else event.accepted = false; }
    Keys.onDownPressed: event => { if (scrollable) scrollBy(40); else event.accepted = false; }
    Keys.onPressed: event => {
        if (!scrollable) { event.accepted = false; return; }
        if (event.key === Qt.Key_PageDown) scrollBy(scroller.height * 0.9);
        else if (event.key === Qt.Key_PageUp) scrollBy(-scroller.height * 0.9);
        else if (event.key === Qt.Key_Home) scroller.contentY = 0;
        else if (event.key === Qt.Key_End) scrollBy(scroller.contentHeight);
        else event.accepted = false;
    }

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
            Label { id: badgeLabel; anchors.centerIn: parent; text: root.badge; color: Theme.accentText; font.pixelSize: 11; font.weight: Font.Bold }
        }
        Label { text: root.title.toUpperCase(); color: root.accentHeader ? Theme.accent : Theme.fgDim; font.pixelSize: 11; font.weight: Font.DemiBold; font.letterSpacing: 1 }
        Row { id: titleRow; spacing: 4; anchors.verticalCenter: parent.verticalCenter; leftPadding: 6 }
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

    // Column so hidden children (visible: false) take no space. When
    // scrollable it lives in the Flickable below instead of the card.
    Column {
        id: body
        parent: root.scrollable ? scroller.contentItem : root
        x: root.scrollable ? 0 : Theme.zonePadding
        y: root.scrollable ? 0
           : !header.visible && root.centered
           ? Math.max(Theme.zonePadding, Math.round((root.height - body.implicitHeight) / 2))
           : root.headerHeight
        width: root.width - 2 * Theme.zonePadding
    }
    Flickable {
        id: scroller
        visible: root.scrollable
        x: Theme.zonePadding
        y: root.headerHeight
        width: root.width - 2 * Theme.zonePadding
        height: root.height - y - 2           // down to the card's bottom edge
        contentHeight: body.implicitHeight + Theme.zonePadding
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        interactive: contentHeight > height
    }
    // Scrollbar: where you are, and that there is more below
    Rectangle {
        visible: root.scrollable && scroller.interactive
        x: root.width - 6
        y: scroller.y + scroller.visibleArea.yPosition * scroller.height
        width: 3
        height: Math.max(20, scroller.visibleArea.heightRatio * scroller.height)
        radius: 1.5
        color: Theme.withAlpha(Theme.fg, scroller.moving ? 0.45 : 0.25)
        Behavior on color { ColorAnimation { duration: 150 } }
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
