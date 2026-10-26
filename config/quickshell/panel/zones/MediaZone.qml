import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire
import Quickshell.Widgets
import "../common"
import "../services"

// ZONE: Media (full tab) — large album art; track info with two side buttons
// (system volume as a vertical slider, audio output picker); transport
// controls; and at the bottom a cava visualizer that doubles as the seekable
// progress bar, with elapsed / total time.
// Three views, switched by the buttons in the top-right corner (saved,
// Settings.v.mediaMode): the music library (services/Library.qml), internet
// radio (services/Radio.qml) or the MPRIS player, all with the same layout.
// Lyrics (microphone button, player and library): the song's lyrics where the
// big title was, the line being sung highlighted; the title moves up, small.
// Volume popover: the app's own volume (its PipeWire stream) and the system's.
// Keyboard: Space play/pause, ←/→ previous/next (when no control has focus);
// Tab to the side buttons, Enter opens their popover (↑/↓ inside, Esc closes).
Zone {
    id: root
    readonly property var player: Media.player
    readonly property bool radio: Settings.v.mediaMode === "radio"
    readonly property bool library: Settings.v.mediaMode === "library"
    readonly property var lib: Library.now
    // Library: quality chips — format, Hi-Res, and whether the sound card runs
    // at the music's own rate (bit-perfect) or PipeWire resamples it
    readonly property var qualityChips: !library || !Library.active ? [] : [
        { t: lib.quality, on: false },
    ].concat(lib.hires ? [{ t: "Hi-Res", on: true }] : [],
             lib.cardRate ? [lib.bitperfect ? { t: Tr.t("Bit-perfect"), on: true }
                                           : { t: Tr.t("Resampled %1 → %2 kHz", lib.rate / 1000, lib.cardRate / 1000), on: false }] : [])
    readonly property var station: Radio.current
    readonly property var sinkAudio: Media.sink?.audio ?? null

    // What this view plays, as PipeWire streams: its own volume in the popover
    readonly property var appStreams: Media.streamsFor(radio ? ["mpv"] : library ? ["mpd"] : Media.playerKeys(player))
    readonly property var appAudio: appStreams[0]?.audio ?? null
    readonly property string appName: radio ? Tr.t("Radio") : library ? Tr.t("Library") : (player?.identity ?? "App")
    // The art or the title clicked: to the player's app (Media.goTo), as the
    // chosen player's chip clicked again
    component ToApp: MouseArea {
        enabled: !root.radio && !root.library && !!root.player
        hoverEnabled: enabled
        cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: Media.goTo(root.player)
    }
    function setAppVolume(v) { for (const n of appStreams) if (n.audio) n.audio.volume = v; }
    function setAppMuted(m) { for (const n of appStreams) if (n.audio) n.audio.muted = m; }

    // Lyrics (services/Lyrics.qml): fetched while shown; the position read 5×/s
    readonly property bool lyrics: Settings.v.mediaLyrics && !radio && (library ? Library.active : !!player)
    readonly property string titleText: radio ? (station?.name ?? Tr.t("No stations"))
        : library ? (Library.active ? (lib.title ?? "") : Tr.t("Choose an album"))
        : (player?.trackTitle || Tr.t("Unknown title"))
    readonly property string artistText: library ? (Library.active ? (lib.artist ?? "") : "") : (player?.trackArtist ?? "")
    readonly property string albumText: library ? (Library.active ? (lib.album ?? "") : "") : (player?.trackAlbum ?? "")
    Binding { target: Lyrics; property: "wanted"; value: root.visualize && root.lyrics }
    Binding {
        target: Lyrics; property: "track"
        value: root.library ? { artist: root.lib.artist ?? "", title: root.lib.title ?? "", album: root.lib.album ?? "",
                                duration: root.lib.duration ?? 0, file: root.lib.file ?? "" }
                            : { artist: root.player?.trackArtist ?? "", title: root.player?.trackTitle ?? "",
                                album: root.player?.trackAlbum ?? "", duration: root.player?.length ?? 0, file: "" }
    }
    Timer {
        interval: 200; repeat: true; triggeredOnStart: true
        running: Lyrics.wanted
        onTriggered: Lyrics.position = root.library ? (root.lib.elapsed ?? 0) : (root.player?.position ?? 0)
    }
    function seekTo(t) {
        if (t < 0) return;
        if (root.library) Library.seek(t);
        else if (root.player?.canSeek) root.player.position = t;
    }

    // Which popover is open: "", "volume" or "output"
    property string popover: ""

    // Run cava only while this tab is on screen
    readonly property bool visualize: PanelState.open && Config.tabs[PanelState.tab]?.name === "Media"
    onVisualizeChanged: {
        Cava.users += visualize ? 1 : -1;
        if (!visualize) popover = "";        // close popovers when leaving the tab
    }
    Component.onDestruction: if (visualize) Cava.users -= 1

    // Radio: find stations (opens the search over the right column)
    property bool searching: false
    readonly property string mode: Settings.v.mediaMode
    onModeChanged: searching = false
    IconButton {
        id: searchButton
        parent: root
        visible: root.radio || root.library
        z: 5
        anchors.top: parent.top
        anchors.right: modeButton.left
        anchors.topMargin: Theme.zonePadding
        anchors.rightMargin: 6
        icon: "\uf002"
        iconSize: 13
        implicitWidth: 34; implicitHeight: 30
        active: root.searching
        onClicked: {
            root.searching = !root.searching;
            if (root.searching) (root.library ? libField : searchField).input.forceActiveFocus();
        }
    }

    // Player · radio · library
    Row {
        id: modeButton
        parent: root
        z: 5
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.margins: Theme.zonePadding
        spacing: 4
        Repeater {
            model: [{ mode: "library", icon: "\u{f0025}" }, { mode: "radio", icon: "\u{f0439}" }, { mode: "player", icon: "\uf001" }]
            delegate: IconButton {
                required property var modelData
                icon: modelData.icon
                iconSize: 13
                implicitWidth: 34; implicitHeight: 30
                active: Settings.v.mediaMode === modelData.mode
                onClicked: Settings.set("mediaMode", modelData.mode)
            }
        }
    }
    Binding { target: Library; property: "watching"; value: root.visualize && root.library }

    // Empty state
    Item {
        visible: !root.player && !root.radio && !root.library
        width: parent.width
        height: root.height - 2 * Theme.zonePadding
        Column {
            anchors.centerIn: parent
            spacing: 10
            Glyph { anchors.horizontalCenter: parent.horizontalCenter; text: "\uf001"; font.pixelSize: 48; color: Theme.fgDim }
            Label { anchors.horizontalCenter: parent.horizontalCenter; text: Tr.t("Nothing playing"); dim: true; font.pixelSize: 15 }
            Label { anchors.horizontalCenter: parent.horizontalCenter; text: Tr.t("Play something in Spotify, Firefox, mpv…"); dim: true; font.pixelSize: 12 }
        }
    }

    RowLayout {
        visible: root.library ? Library.available : (!!root.player || root.radio)
        width: parent.width
        height: root.height - 2 * Theme.zonePadding
        spacing: 24

        // --- Album art ---
        ClippingRectangle {
            Layout.preferredWidth: parent.height
            Layout.preferredHeight: parent.height
            radius: Theme.zoneRadius
            color: Theme.bgHover

            Glyph { anchors.centerIn: parent; text: root.radio ? "\u{f0439}" : root.library ? "\u{f0025}" : "\uf001"; font.pixelSize: 64; color: Theme.fgDim
                    visible: art.status !== Image.Ready && !root.preview }
            Image {
                id: art
                anchors.fill: parent
                source: root.radio ? (root.station?.logo ?? "")
                      : root.library ? (root.lib.cover ? "file://" + root.lib.cover : "")
                      : (root.player?.trackArtUrl ?? "")
                fillMode: Image.PreserveAspectCrop
                sourceSize: Qt.size(600, 600)
                asynchronous: true
                opacity: root.preview ? 0 : 1
                Behavior on opacity { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
            }
            ToApp { anchors.fill: parent; visible: !root.preview }

            // Booklet page (root.preview): two images take turns, the next page
            // loads in the hidden one and fades in over the other
            Item {
                id: pages
                anchors.fill: parent
                property bool flip: false
                readonly property string src: root.preview
                onSrcChanged: if (src) { (flip ? pageB : pageA).source = "file://" + src; flip = !flip; }
                Rectangle {
                    anchors.fill: parent
                    color: Theme.bgAlt                 // behind pages that aren't square
                    opacity: root.preview ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
                }
                Image {
                    id: pageA
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    sourceSize: Qt.size(900, 900)
                    asynchronous: true
                    opacity: root.preview && pages.flip && status === Image.Ready ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
                }
                Image {
                    id: pageB
                    anchors.fill: parent
                    fillMode: Image.PreserveAspectFit
                    sourceSize: Qt.size(900, 900)
                    asynchronous: true
                    opacity: root.preview && !pages.flip && status === Image.Ready ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }
                }
            }

            // Over a page: \u2039 \u203a through the booklet (on hover), the page number,
            // \u2922 full size in the image viewer, \u21ba back to what's playing
            HoverHandler { id: artHover }
            Item {
                anchors.fill: parent
                opacity: root.preview ? 1 : 0
                visible: opacity > 0
                Behavior on opacity { NumberAnimation { duration: 260; easing.type: Easing.OutCubic } }

                Repeater {
                    model: [{ step: -1, icon: "\uf053" }, { step: 1, icon: "\uf054" }]
                    delegate: Rectangle {
                        required property var modelData
                        anchors.verticalCenter: parent.verticalCenter
                        x: modelData.step < 0 ? 10 : parent.width - width - 10
                        width: 34; height: 34; radius: 17
                        color: Theme.withAlpha(Theme.bg, arrowMouse.containsMouse ? 0.9 : 0.7)
                        border.color: Theme.border
                        readonly property bool can: modelData.step < 0 ? root.previewIndex > 0 : root.previewIndex < root.previewPages.length - 1
                        opacity: artHover.hovered && can ? 1 : 0
                        visible: opacity > 0
                        Behavior on opacity { NumberAnimation { duration: 180 } }
                        Glyph { anchors.centerIn: parent; text: parent.modelData.icon; font.pixelSize: 12; color: Theme.fg }
                        MouseArea { id: arrowMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: root.showPage(root.previewIndex + parent.modelData.step) }
                    }
                }
                Rectangle {
                    visible: root.previewPages.length > 1 && root.previewIndex >= 0
                    anchors.left: parent.left; anchors.bottom: parent.bottom; anchors.margins: 10
                    implicitWidth: pageNo.implicitWidth + 16; implicitHeight: 26; radius: 13
                    color: Theme.withAlpha(Theme.bg, 0.75)
                    Label { id: pageNo; anchors.centerIn: parent; font.pixelSize: 11; font.features: { "tnum": 1 }
                            text: (root.previewIndex + 1) + " / " + root.previewPages.length }
                }
                Rectangle {
                    anchors.right: parent.right; anchors.bottom: parent.bottom; anchors.margins: 10
                    implicitWidth: pageButtons.implicitWidth + 8; implicitHeight: pageButtons.implicitHeight + 8; radius: Theme.buttonRadius + 4
                    color: Theme.withAlpha(Theme.bg, 0.75)
                    Row {
                        id: pageButtons
                        anchors.centerIn: parent
                        spacing: 4
                        IconButton { icon: "\uf065"; iconSize: 12; implicitWidth: 32; implicitHeight: 28   // full size
                                     onClicked: { Library.openImage(root.preview); PanelState.open = false; } }
                        IconButton { icon: "\uf0e2"; iconSize: 12; implicitWidth: 32; implicitHeight: 28   // back to the playing art
                                     onClicked: root.preview = "" }
                    }
                }
            }
        }

        // --- Info, controls, visualizer ---
        // About a quarter for the chips and the title, half for the lyrics (or
        // the info), a quarter for the controls and the visualizer
        ColumnLayout {
            id: infoColumn
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            // Player picker (only when there is more than one) / station picker.
            // Chips that don't fit beside the search/mode buttons go to the next
            // line; one longer than the whole row is elided.
            Flow {
                id: chipFlow
                Layout.fillWidth: true
                Layout.rightMargin: modeButton.width + (searchButton.visible ? searchButton.width + 6 : 0) + 8
                spacing: 6
                visible: root.radio || (root.library ? root.qualityChips.length > 0 : Media.players.length > 1)
                Repeater {
                    model: root.radio ? Radio.stations : root.library ? root.qualityChips : Media.players
                    delegate: Chip {
                        required property var modelData
                        implicitHeight: 26
                        maxWidth: chipFlow.width
                        // Identity alone is ambiguous (e.g. two Firefox tabs): add the track
                        text: root.radio ? (modelData.name ?? "") : root.library ? (modelData.t ?? "")
                            : String(modelData.identity ?? "").split(" ")[0] + (modelData.trackTitle ? " · " + modelData.trackTitle : "")
                        active: root.radio ? modelData.name === root.station?.name : root.library ? modelData.on : modelData === root.player
                        // The chosen one clicked again: to its app (Media.goTo)
                        onClicked: root.radio ? Radio.play(modelData) : root.library ? {}
                            : modelData === root.player ? Media.goTo(modelData) : Media.pick(modelData)
                    }
                }
            }

            // The chips' row keeps its height without chips, so everything below
            // is always at the same height
            Item { visible: !chipFlow.visible; implicitHeight: 26 }

            // What changes with the view: the info, or the small title and the
            // lyrics; and the side buttons, which stay put
            Item {
                id: middle
                Layout.fillWidth: true
                Layout.fillHeight: true
                readonly property real textWidth: width - sideButtons.width - 16

                // Side buttons, top to bottom: lyrics (the radio: record), audio
                // output, volume; at the same place in every view: centered in the
                // column's middle half, like the lyrics (the chips' quarter above)
                Column {
                    id: sideButtons
                    z: 5
                    anchors.right: parent.right
                    readonly property real bandTop: Math.max(0, middle.height - infoColumn.height * 0.5)
                    y: Math.round(bandTop + (middle.height - bandTop - height) / 2)
                    spacing: 8

                    // Lyrics on / off (player and library)
                    IconButton {
                        visible: !root.radio
                        icon: "\u{f0cb8}"     // lines + a note: lyrics
                        iconSize: 17
                        active: Settings.v.mediaLyrics
                        onClicked: Settings.set("mediaLyrics", !Settings.v.mediaLyrics)
                    }
                    // Radio: record the stream (Radio.toggleRecord → ~/Recordings)
                    IconButton {
                        visible: root.radio
                        enabled: Radio.active && !Radio.loading
                        opacity: enabled ? 1 : 0.4
                        icon: Radio.recording ? "\uf04d" : "\uf111"
                        iconSize: Radio.recording ? 11 : 12
                        active: Radio.recording
                        iconColor: Radio.recording ? Theme.accentText : Theme.critical
                        onClicked: Radio.toggleRecord()
                    }
                    IconButton {
                        id: outputButton
                        icon: "\u{f04c3}"     // speaker / audio output
                        active: root.popover === "output"
                        onClicked: { root.popover = root.popover === "output" ? "" : "output"; if (root.popover) outputFocus.start(); }
                    }
                    IconButton {
                        id: volumeButton
                        icon: (root.sinkAudio?.muted ?? false) ? "\uf026" : "\uf028"
                        active: root.popover === "volume"
                        onClicked: { root.popover = root.popover === "volume" ? "" : "volume"; if (root.popover) volumeFocus.start(); }
                    }
                }

                // Lyrics on: the title, small, at the top of the lyrics' half of the
                // column (the chips keep the quarter above)
                Column {
                    id: smallTitle
                    visible: root.lyrics
                    y: Math.max(0, middle.height - infoColumn.height * 0.5)
                    width: middle.textWidth
                    spacing: 2
                    Label {
                        width: parent.width; text: root.titleText; color: Theme.accent; font.pixelSize: 17; font.weight: Font.DemiBold; elide: Text.ElideRight
                        font.underline: smallTitleApp.containsMouse
                        ToApp { id: smallTitleApp; width: Math.min(parent.width, parent.contentWidth); height: parent.height }
                    }
                    Label { width: parent.width; text: [root.artistText, root.albumText].filter(x => x).join("  ·  "); dim: true; font.pixelSize: 12; elide: Text.ElideRight; visible: text !== "" }
                }

                // No lyrics: the track info, centered on the side buttons
                ColumnLayout {
                    visible: !root.lyrics
                    width: middle.textWidth
                    y: Math.max(0, sideButtons.y + sideButtons.height / 2 - height / 2)
                    spacing: 4
                    Label {
                        text: root.radio ? (Radio.loading ? Tr.t("RADIO · CONNECTING…") : Radio.recording ? Tr.t("RADIO · LIVE") + " · ● REC " + Radio.recordElapsed
                                            : Radio.active ? Tr.t("RADIO · LIVE") : Tr.t("RADIO"))
                            : root.library ? Tr.t("LIBRARY") + " · " + (Library.playing ? Tr.t("PLAYING") : Library.active ? Tr.t("PAUSED") : Tr.t("%1 ALBUMS", Library.albums.length))
                                         : (root.player?.identity ?? "")
                        dim: true
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        font.letterSpacing: 1
                        Layout.fillWidth: true
                    }
                    Label {
                        text: root.titleText
                        color: Theme.accent
                        font.pixelSize: 24
                        font.weight: Font.DemiBold
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        Layout.fillWidth: true
                        font.underline: titleApp.containsMouse
                        ToApp { id: titleApp; width: Math.min(parent.width, parent.contentWidth); height: parent.contentHeight }
                    }
                    // Radio: what's on air (the stream's title), then frequency / city
                    Label { text: root.radio ? Radio.onAir : root.library ? (Library.active ? (root.lib.artist ?? "") : Tr.t("Browse your albums with the search button")) : (root.player?.trackArtist ?? ""); font.pixelSize: 15; visible: text !== ""; Layout.fillWidth: true; elide: Text.ElideRight }
                    Label { text: root.radio ? (root.station?.subtitle ?? "") : root.library ? (Library.active ? (root.lib.album ?? "") : "") : (root.player?.trackAlbum ?? ""); dim: true; font.pixelSize: 13; visible: text !== ""; Layout.fillWidth: true }
                }

                // Lyrics: under the title, down to the controls (the rest of that
                // half): about three lines, the one being sung in the accent color in
                // the middle (the first one starts there too, the intro above it);
                // lines fade out at both edges instead of being cut; a click on a
                // line jumps there
                Item {
                    id: lyricsBox
                    visible: root.lyrics
                    y: smallTitle.y + smallTitle.height + 6
                    height: middle.height - y
                    width: middle.textWidth
                    clip: true

                    Label {
                        anchors.centerIn: parent
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.Wrap
                        visible: Lyrics.status !== "found"
                        dim: true
                        font.pixelSize: 14
                        text: Lyrics.status === "loading" ? Tr.t("Looking for the lyrics…")
                            : Lyrics.status === "instrumental" ? "\u266A  Instrumental"
                            : Lyrics.status === "offline" ? Tr.t("Couldn't reach LRCLIB, the lyrics site. Try again later.")
                            : Lyrics.status === "none" ? Tr.t("No lyrics found for this song") : ""
                    }

                    ListView {
                        id: lyricsView
                        anchors.fill: parent
                        visible: Lyrics.status === "found"
                        model: Lyrics.lines
                        spacing: 8
                        boundsBehavior: Flickable.StopAtBounds
                        // Synced: the line being sung, else (before it starts) the first
                        // one, shown as if it were: the look doesn't change when it starts
                        readonly property int shown: Lyrics.synced && Lyrics.lines.length ? Math.max(0, Lyrics.index) : -1
                        currentIndex: shown
                        highlightRangeMode: Lyrics.synced ? ListView.ApplyRange : ListView.NoHighlightRange
                        preferredHighlightBegin: height / 2 - 22
                        preferredHighlightEnd: height / 2 + 22
                        highlightMoveDuration: 450
                        // Synced: room before the first line and after the last, so
                        // they sit in the middle too (a song starts with its first
                        // line there, not at the top)
                        // Before the first line, the intro, in the middle of the room above
                        // it (between the title and the first line): dots lighting up as it
                        // nears (gently pulsing) and the time left; it fades out when the
                        // singing starts and goes up with the lines
                        header: Item {
                            id: intro
                            width: lyricsView.width
                            height: Lyrics.synced ? lyricsView.height / 2 - 16 : 0
                            readonly property real first: Lyrics.lines[0]?.t ?? 0
                            readonly property real progress: first > 0 ? Math.max(0, Math.min(1, Lyrics.position / first)) : 1
                            Row {
                                anchors.verticalCenter: parent.verticalCenter
                                spacing: 12
                                opacity: Lyrics.synced && Lyrics.index < 0 && intro.first >= 3 ? 1 : 0
                                visible: opacity > 0
                                Behavior on opacity { NumberAnimation { duration: 400; easing.type: Easing.OutCubic } }
                                Repeater {
                                    model: 3
                                    delegate: Rectangle {
                                        required property int index
                                        anchors.verticalCenter: parent.verticalCenter
                                        width: 12; height: 12; radius: 6
                                        color: Theme.accent
                                        opacity: 0.25 + 0.75 * Math.max(0, Math.min(1, intro.progress * 3 - index))
                                        SequentialAnimation on scale {
                                            running: parent.visible
                                            loops: Animation.Infinite
                                            NumberAnimation { to: 1.2; duration: 900; easing.type: Easing.InOutSine }
                                            NumberAnimation { to: 1; duration: 900; easing.type: Easing.InOutSine }
                                        }
                                    }
                                }
                                Label {
                                    anchors.verticalCenter: parent.verticalCenter
                                    leftPadding: 4
                                    text: Media.fmt(Math.ceil(intro.first - Lyrics.position))
                                    dim: true
                                    font.pixelSize: 14
                                    font.features: { "tnum": 1 }
                                }
                            }
                        }
                        footer: Item { width: 1; height: Lyrics.synced ? lyricsView.height / 2 - 16 : 0 }
                        // That line in the middle again whenever the room around it changes
                        // (Lyrics sets the lines first, then `synced`: the header grows after
                        // the view was placed, and it doesn't move by itself); unsynced, the top
                        function recenter() { if (shown >= 0) positionViewAtIndex(shown, ListView.Center); else positionViewAtBeginning(); }
                        onModelChanged: Qt.callLater(recenter)
                        onHeightChanged: Qt.callLater(recenter)
                        onVisibleChanged: if (visible) Qt.callLater(recenter)
                        Connections {
                            target: Lyrics
                            function onSyncedChanged() { Qt.callLater(lyricsView.recenter); }
                        }

                        delegate: Label {
                            required property var modelData
                            required property int index
                            readonly property bool current: index === lyricsView.shown
                            readonly property bool past: Lyrics.synced && index < lyricsView.shown
                            width: lyricsView.width
                            text: modelData.text || "\u266A"
                            wrapMode: Text.Wrap
                            color: current ? Theme.accent : Theme.fg
                            // Fades out near the box's top and bottom edges instead of being cut
                            readonly property real mid: y - lyricsView.contentY + height / 2
                            readonly property real edge: Math.max(0, Math.min(1, Math.min(mid, lyricsView.height - mid) / 34))
                            opacity: (!Lyrics.synced ? 0.85 : current ? 1 : past ? 0.35 : 0.6) * edge
                            font.pixelSize: current ? 23 : 19
                            font.weight: current ? Font.Bold : Font.DemiBold
                            Behavior on opacity { enabled: !lyricsView.moving; NumberAnimation { duration: 250 } }
                            MouseArea {
                                anchors.fill: parent
                                enabled: Lyrics.synced
                                cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                                onClicked: root.seekTo(parent.modelData.t)
                            }
                        }
                    }
                }
            }

            // The bottom quarter: the controls right above the visualizer
            ColumnLayout {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.max(infoColumn.height * 0.25, 48 + 6 + 40)
                Layout.maximumHeight: Layout.preferredHeight
                spacing: 6

                // Transport controls
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 12

                    IconButton {
                        visible: !root.radio
                        icon: "\uf074"; iconSize: 13; border.width: 0
                        enabled: root.library || (root.player?.shuffleSupported ?? false)
                        opacity: enabled ? 1 : 0.35
                        active: root.library ? !!root.lib.random : (root.player?.shuffle ?? false)
                        onClicked: root.library ? Library.setRandom(!root.lib.random) : (root.player.shuffle = !root.player.shuffle)
                    }
                    // Radio: previous / next station, and play-stop (a live stream isn't paused)
                    IconButton { icon: "\uf048"; iconSize: 15; implicitWidth: 44; implicitHeight: 40; border.width: 0
                                 onClicked: root.radio ? Radio.previous() : root.library ? Library.prev() : root.player.previous() }
                    IconButton { icon: root.radio ? (Radio.active ? "\uf04d" : "\uf04b")
                                     : root.library ? (Library.playing ? "\uf04c" : "\uf04b")
                                     : (root.player?.isPlaying ? "\uf04c" : "\uf04b")
                                 iconSize: 18; implicitWidth: 56; implicitHeight: 48
                                 radius: 24; active: true; onClicked: root.radio ? Radio.toggle() : root.library ? Library.toggle() : root.player.togglePlaying() }
                    IconButton { icon: "\uf051"; iconSize: 15; implicitWidth: 44; implicitHeight: 40; border.width: 0
                                 onClicked: root.radio ? Radio.next() : root.library ? Library.next() : root.player.next() }
                    IconButton {
                        visible: !root.radio
                        icon: !root.library && (root.player?.loopState ?? MprisLoopState.None) === MprisLoopState.Track ? "\u{f0458}" : "\uf01e"
                        iconSize: 13; border.width: 0
                        enabled: root.library || (root.player?.loopSupported ?? false)
                        opacity: enabled ? 1 : 0.35
                        active: root.library ? !!root.lib.repeat : (root.player?.loopState ?? MprisLoopState.None) !== MprisLoopState.None
                        onClicked: root.library ? Library.setRepeat(!root.lib.repeat) : Media.cycleLoop()
                    }
                }

                // Cava visualizer as progress bar: elapsed | bars (played part in accent) | total
                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 10

                    Label { Layout.alignment: Qt.AlignBottom; text: root.radio ? Radio.elapsed : root.library ? Media.fmt(root.lib.elapsed) : Media.fmt(root.player?.position); dim: true; font.pixelSize: 11; font.features: { "tnum": 1 } }

                    Item {
                        id: viz
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        readonly property int count: 64
                        readonly property real slot: width / count

                        Row {
                            anchors.fill: parent
                            Repeater {
                                model: viz.count
                                delegate: Item {
                                    required property int index
                                    width: viz.slot
                                    height: viz.height
                                    readonly property real level: Cava.bars[index] ?? 0
                                    readonly property bool played: root.radio ? Radio.active
                                                                          : (index + 0.5) / viz.count <= (root.library ? Library.progress : Media.progress)
                                    Rectangle {
                                        anchors.bottom: parent.bottom
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        width: Math.max(2, viz.slot * 0.6)
                                        height: Math.max(3, parent.height * parent.level)
                                        radius: width / 2
                                        color: parent.played ? Theme.vivid : Theme.withAlpha(Theme.fg, 0.25)
                                        Behavior on height { NumberAnimation { duration: 60 } }
                                    }
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: root.library ? root.lib.duration > 0
                                   : !root.radio && (root.player?.canSeek ?? false) && root.player.length > 0
                            cursorShape: enabled ? Qt.PointingHandCursor : Qt.ArrowCursor
                            onClicked: mouse => root.library ? Library.seek(root.lib.duration * mouse.x / width)
                                                             : root.player.position = root.player.length * mouse.x / width
                        }
                    }

                    Label { Layout.alignment: Qt.AlignBottom; text: root.radio ? Tr.t("LIVE") : root.library ? Media.fmt(root.lib.duration) : Media.fmt(root.player?.length)
                            color: root.radio && Radio.active ? Theme.accent : Theme.fgDim
                            font.pixelSize: 11; font.weight: root.radio ? Font.DemiBold : Font.Normal; font.features: { "tnum": 1 } }
                }
            }
        }
    }

    // ---------------- Library: MPD missing / empty ----------------
    Item {
        visible: root.library && !Library.available
        width: parent.width
        height: root.height - 2 * Theme.zonePadding
        Column {
            anchors.centerIn: parent
            width: Math.min(parent.width - 80, 520)
            spacing: 10
            Glyph { anchors.horizontalCenter: parent.horizontalCenter; text: "\u{f0025}"; font.pixelSize: 48; color: Theme.fgDim }
            Label {
                anchors.horizontalCenter: parent.horizontalCenter
                text: Library.problem === "mpd" ? Tr.t("The music library needs MPD") : Library.problem ? Tr.t("The music library isn't answering") : Tr.t("Connecting to the library…")
                font.pixelSize: 15
                font.weight: Font.DemiBold
            }
            Label {
                width: parent.width
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.Wrap
                dim: true
                font.pixelSize: 12
                text: Library.problem === "mpd"
                    ? Tr.t("MPD plays ~/Music in full quality. Install it and start it once:") + "\nsudo dnf install mpd mpc  ·  systemctl --user enable --now mpd"
                    : Library.problem
            }
        }
    }

    // ---------------- Library: browse albums ----------------
    // Over the right column, like the radio search: albums as a grid of covers
    // or a list (Settings.v.libraryView), sorted like Spotify's library
    // (Settings.v.librarySort), filtered by album or artist; an album opens its
    // tracks — Play, Queue, a track, or find one by name.
    property var openAlbum: null
    onSearchingChanged: if (!searching) openAlbum = null
    // The open album's booklet, shown in the big art (root.preview): its pages
    // are the images of its folder (scripts/library.py artwork)
    property string preview: ""
    readonly property var previewPages: openAlbum?.artwork ?? []
    readonly property int previewIndex: previewPages.indexOf(preview)
    function showPage(i) { if (i >= 0 && i < previewPages.length) preview = previewPages[i]; }
    onOpenAlbumChanged: preview = ""
    // Search text without case or accents: "dia" finds "Día"
    function fold(s) { return String(s ?? "").normalize("NFD").replace(/[̀-ͯ]/g, "").toLowerCase(); }
    readonly property var sorts: [
        { value: "recent", label: Tr.t("Recents") },
        { value: "added", label: Tr.t("Recently added") },
        { value: "alpha", label: Tr.t("Alphabetical") },
        { value: "artist", label: Tr.t("Artist") },
        { value: "year", label: Tr.t("Year") },
    ]
    function sortAlbums(list, by) {
        const text = (x, y) => fold(x).localeCompare(fold(y));
        const newer = (x, y) => (y.added ?? "").localeCompare(x.added ?? "");
        const a = list.slice();
        if (by === "recent") a.sort((x, y) => (y.played ?? 0) - (x.played ?? 0) || newer(x, y));   // never played: newest first
        else if (by === "added") a.sort(newer);
        else if (by === "alpha") a.sort((x, y) => text(x.album, y.album));
        else if (by === "artist") a.sort((x, y) => text(x.artistSort ?? x.artist, y.artistSort ?? y.artist) || (x.year ?? "").localeCompare(y.year ?? ""));
        else if (by === "year") a.sort((x, y) => (y.year ?? "").localeCompare(x.year ?? "") || text(x.album, y.album));
        return a;
    }
    Rectangle {
        id: libPane
        parent: root
        z: 8
        visible: root.library && root.searching
        readonly property real side: root.height - 2 * Theme.zonePadding
        readonly property string q: root.fold(libField.text.trim())
        readonly property var shown: root.sortAlbums(q ? Library.albums.filter(a => root.fold(a.album + " " + a.artist).includes(q)) : Library.albums,
                                                     Settings.v.librarySort)
        readonly property bool grid: Settings.v.libraryView !== "list"
        x: Theme.zonePadding + side + 24
        y: Theme.zonePadding + 38
        width: root.width - x - Theme.zonePadding
        height: root.height - y - Theme.zonePadding
        radius: Theme.zoneRadius
        color: Theme.bgAlt
        border.color: Theme.border

        MouseArea { anchors.fill: parent }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8
            visible: !root.openAlbum

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                TextField { id: libField; Layout.fillWidth: true; icon: "\uf002"; placeholder: Tr.t("Album or artist") }
                IconButton {
                    icon: "\uf021"                 // rescan ~/Music
                    iconSize: 12; implicitWidth: 34; implicitHeight: 30
                    active: Library.now.updating ?? false
                    onClicked: Library.rescan()
                }
            }
            // Count · sort · grid / list
            RowLayout {
                Layout.fillWidth: true
                spacing: 6
                z: 2                                   // the sort list opens over the albums
                Label {
                    Layout.fillWidth: true
                    text: Library.loadingAlbums ? Tr.t("READING ~/Music…")
                        : Tr.n(libPane.shown.length, "%1 ALBUM", "%1 ALBUMS")
                          + (Library.albums.filter(a => a.hires).length ? " · " + Library.albums.filter(a => a.hires).length + " HI-RES" : "")
                    dim: true; font.pixelSize: 10; font.weight: Font.DemiBold; font.letterSpacing: 1
                }
                Dropdown {
                    icon: "\uf0dc"
                    options: root.sorts
                    value: Settings.v.librarySort
                    listWidth: 170
                    onSelected: v => Settings.set("librarySort", v)
                }
                IconButton {
                    icon: libPane.grid ? "\uf03a" : "\uf00a"     // shows the view it switches to
                    iconSize: 12; implicitWidth: 30; implicitHeight: 28
                    onClicked: Settings.set("libraryView", libPane.grid ? "list" : "grid")
                }
            }
            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                GridView {
                    id: albumGrid
                    anchors.fill: parent
                    visible: libPane.grid
                    opacity: visible ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds
                    readonly property int cols: Math.max(2, Math.floor(width / 130))
                    cellWidth: width / cols
                    cellHeight: cellWidth + 44
                    model: libPane.shown
                    delegate: Item {
                        id: cell
                        required property var modelData
                        width: albumGrid.cellWidth
                        height: albumGrid.cellHeight
                        Column {
                            anchors.fill: parent
                            anchors.margins: 5
                            spacing: 4
                            ClippingRectangle {
                                width: parent.width; height: parent.width; radius: 10
                                color: Theme.bgHover
                                Glyph { anchors.centerIn: parent; text: "\u{f0025}"; font.pixelSize: 26; color: Theme.fgDim; visible: cover.status !== Image.Ready }
                                Image { id: cover; anchors.fill: parent; source: cell.modelData.cover ? "file://" + cell.modelData.cover : ""
                                        sourceSize: Qt.size(260, 260); fillMode: Image.PreserveAspectCrop; asynchronous: true }
                                // Hi-Res badge
                                Rectangle {
                                    visible: cell.modelData.hires
                                    anchors.right: parent.right; anchors.bottom: parent.bottom; anchors.margins: 6
                                    implicitWidth: hr.implicitWidth + 10; implicitHeight: 16; radius: 8
                                    color: Theme.accent
                                    Label { id: hr; anchors.centerIn: parent; text: "HI-RES"; color: Theme.accentText; font.pixelSize: 8; font.weight: Font.Bold; font.letterSpacing: 0.5 }
                                }
                            }
                            Label { width: parent.width; text: cell.modelData.album; font.pixelSize: 12; font.weight: Font.DemiBold; elide: Text.ElideRight }
                            Label { width: parent.width; text: cell.modelData.artist + (cell.modelData.year ? " · " + cell.modelData.year : ""); dim: true; font.pixelSize: 11; elide: Text.ElideRight }
                        }
                        MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: root.openAlbum = cell.modelData }
                    }
                }
                // List: small cover, album, artist · year · format
                ListView {
                    id: albumList
                    anchors.fill: parent
                    visible: !libPane.grid
                    opacity: visible ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 200 } }
                    clip: true
                    spacing: 2
                    boundsBehavior: Flickable.StopAtBounds
                    model: libPane.shown
                    delegate: Rectangle {
                        id: albumRow
                        required property var modelData
                        readonly property bool playing: Library.active && Library.now.album === modelData.album
                                                        && (Library.now.albumArtist ?? "") === modelData.artist
                        width: ListView.view.width
                        height: 56
                        radius: 8
                        color: rowHover.containsMouse ? Theme.bgHover : "transparent"
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 6
                            anchors.rightMargin: 10
                            spacing: 10
                            ClippingRectangle {
                                implicitWidth: 46; implicitHeight: 46; radius: 6
                                color: Theme.bgHover
                                Glyph { anchors.centerIn: parent; text: "\u{f0025}"; font.pixelSize: 16; color: Theme.fgDim; visible: rowCover.status !== Image.Ready }
                                Image { id: rowCover; anchors.fill: parent; source: albumRow.modelData.cover ? "file://" + albumRow.modelData.cover : ""
                                        sourceSize: Qt.size(92, 92); fillMode: Image.PreserveAspectCrop; asynchronous: true }
                            }
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 1
                                Label { Layout.fillWidth: true; text: albumRow.modelData.album; font.pixelSize: 13; font.weight: Font.DemiBold
                                        color: albumRow.playing ? Theme.accent : Theme.fg; elide: Text.ElideRight }
                                Label { Layout.fillWidth: true; dim: true; font.pixelSize: 11; elide: Text.ElideRight
                                        text: [albumRow.modelData.artist, albumRow.modelData.year, Tr.t("%1 tracks", albumRow.modelData.tracks.length)].filter(x => x).join(" · ") }
                            }
                            Rectangle {
                                visible: albumRow.modelData.hires
                                implicitWidth: rowHr.implicitWidth + 10; implicitHeight: 16; radius: 8
                                color: Theme.accent
                                Label { id: rowHr; anchors.centerIn: parent; text: "HI-RES"; color: Theme.accentText; font.pixelSize: 8; font.weight: Font.Bold; font.letterSpacing: 0.5 }
                            }
                            Label { text: albumRow.modelData.quality ?? ""; dim: true; font.pixelSize: 10 }
                        }
                        MouseArea { id: rowHover; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                    onClicked: root.openAlbum = albumRow.modelData }
                    }
                }
                Label {
                    anchors.centerIn: parent
                    width: parent.width - 40
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    visible: libPane.shown.length === 0 && !Library.loadingAlbums
                    text: libPane.q ? Tr.t("No albums match") : Tr.t("No albums yet. Put them in ~/Music as Artist/Album (Year)/, or import with: beet import <folder>")
                    dim: true
                    font.pixelSize: 12
                }
            }
        }

        // An album: header with Play / Queue, its booklet, the quality check, then its tracks
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8
            id: albumView
            visible: !!root.openAlbum
            readonly property var a: root.openAlbum ?? ({ tracks: [] })
            // The tracks shown: all, or those matching the search (title, number or "3-07")
            readonly property string tq: root.fold(trackField.text.trim())
            readonly property var rows: a.tracks.map((t, i) => Object.assign({ index: i }, t))
                .filter(t => !tq || root.fold(t.title).includes(tq) || String(t.track) === tq
                             || t.disc + "-" + String(t.track).padStart(2, "0") === tq)
            // Box sets restart the numbers on each disc: show "3-07"
            readonly property bool discs: a.tracks.some(t => t.disc && t.disc !== "1")
            // Quality check: the tracks' verdicts, once checked (services/Library.qml)
            readonly property var checked: a.tracks.map(t => Library.verdicts[t.file]).filter(v => !!v)
            readonly property int problems: checked.filter(v => v.verdict !== "ok").length
            readonly property bool checking: Library.verifying === (a.artist + "\n" + a.album)
            readonly property string summary: {
                if (checking) return Tr.t("Listening to every track… the first time takes a while");
                if (Library.verifyError === "numpy") return Tr.t("The check needs numpy: sudo dnf install python3-numpy");
                if (checked.length < a.tracks.length) return Tr.t("Is it really lossless? Checks each track's codec and spectrum");
                if (!problems) return Tr.n(checked.length, "Really lossless", "All %1 tracks are really lossless");
                const c = {};
                for (const v of checked) c[v.verdict] = (c[v.verdict] ?? 0) + 1;
                return [c.fake ? Tr.t("%1 MP3/AAC renamed", c.fake) : "",
                        c.lossy ? Tr.t("%1 transcoded from MP3/AAC", c.lossy) : "",
                        c.upsampled ? Tr.t("%1 fake Hi-Res (a resampled CD)", c.upsampled) : "",
                        c.padded ? Tr.t("%1 fake 24-bit (16 bits padded)", c.padded) : "",
                        c.error ? Tr.t("%1 unreadable", c.error) : ""].filter(x => x).join(" · ")
                       + " — " + Tr.t("click a mark to see its spectrogram");
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                IconButton { icon: "\uf053"; iconSize: 11; implicitWidth: 30; implicitHeight: 28; onClicked: root.openAlbum = null }
                ClippingRectangle {
                    implicitWidth: 56; implicitHeight: 56; radius: 8; color: Theme.bgHover
                    Image { anchors.fill: parent; source: albumView.a.cover ? "file://" + albumView.a.cover : ""
                            sourceSize: Qt.size(112, 112); fillMode: Image.PreserveAspectCrop; asynchronous: true }
                    MouseArea { anchors.fill: parent; enabled: !!albumView.a.cover; cursorShape: Qt.PointingHandCursor
                                onClicked: root.preview = root.preview === albumView.a.cover ? "" : albumView.a.cover }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1
                    Label { text: albumView.a.album ?? ""; font.pixelSize: 15; font.weight: Font.DemiBold; elide: Text.ElideRight; Layout.fillWidth: true }
                    Label { text: (albumView.a.artist ?? "") + (albumView.a.year ? " · " + albumView.a.year : ""); dim: true; font.pixelSize: 12; elide: Text.ElideRight; Layout.fillWidth: true }
                    Label { text: (albumView.a.quality ?? "") + " · " + Tr.t("%1 tracks", albumView.a.tracks.length); dim: true; font.pixelSize: 11 }
                }
                Chip { text: Tr.t("Play"); icon: "\uf04b"; filled: true; onClicked: { Library.play(root.openAlbum, 0); root.searching = false; } }
                Chip { text: Tr.t("Queue"); icon: "\uf067"; onClicked: Library.queue(root.openAlbum) }
            }
            // Booklet: every image in the album's folder (Artwork/, Scans/…); a
            // click shows it in the big art (again: back to what's playing)
            ListView {
                id: booklet
                Layout.fillWidth: true
                Layout.preferredHeight: 64
                visible: (albumView.a.artwork ?? []).length > 1
                orientation: ListView.Horizontal
                spacing: 6
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                model: albumView.a.artwork ?? []
                // Paging with ‹ › in the big art keeps the page shown in view
                Connections {
                    target: root
                    function onPreviewIndexChanged() { if (root.previewIndex >= 0) booklet.positionViewAtIndex(root.previewIndex, ListView.Contain); }
                }
                delegate: ClippingRectangle {
                    id: page
                    required property string modelData
                    readonly property bool shown: root.preview === modelData
                    width: 64; height: 64; radius: 6
                    color: Theme.bgHover
                    border.width: shown ? 2 : 0
                    border.color: Theme.accent
                    Image { anchors.fill: parent; anchors.margins: page.border.width; source: "file://" + page.modelData
                            sourceSize: Qt.size(128, 128); fillMode: Image.PreserveAspectCrop; asynchronous: true
                            opacity: root.preview && !page.shown ? 0.6 : 1
                            Behavior on opacity { NumberAnimation { duration: 200 } } }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                                onClicked: root.preview = page.shown ? "" : page.modelData }
                }
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                Chip { text: Tr.t("Check quality"); icon: "\uf058"; active: albumView.checking
                       enabled: !Library.verifying; onClicked: Library.verify(root.openAlbum) }
                Label { text: albumView.summary; Layout.fillWidth: true; font.pixelSize: 11; wrapMode: Text.Wrap; maximumLineCount: 2; elide: Text.ElideRight
                        dim: !albumView.problems; color: albumView.problems ? Theme.warn : Theme.fgDim }
            }
            // Find a track by name or number (long albums: 99 tracks in a box set)
            TextField {
                id: trackField
                Layout.fillWidth: true
                visible: albumView.a.tracks.length > 12
                icon: "\uf002"
                placeholder: Tr.t("Find a track")
                onAccepted: if (albumView.rows.length) { Library.play(root.openAlbum, albumView.rows[0].index); root.searching = false; }
                Connections { target: root; function onOpenAlbumChanged() { trackField.text = ""; } }
            }
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 2
                boundsBehavior: Flickable.StopAtBounds
                model: albumView.rows
                delegate: Rectangle {
                    id: trackRow
                    required property var modelData
                    readonly property int index: modelData.index      // place in the album, not in the filtered list
                    readonly property bool current: Library.active && Library.now.title === modelData.title && Library.now.album === root.openAlbum?.album
                    readonly property var check: Library.verdicts[modelData.file] ?? null
                    readonly property color checkColor: !check ? Theme.fgDim : check.verdict === "ok" ? Theme.good
                                                      : check.verdict === "fake" || check.verdict === "lossy" ? Theme.bad : Theme.warn
                    width: ListView.view.width
                    height: 36
                    radius: 8
                    color: current ? Theme.withAlpha(Theme.accent, 0.14) : trackMouse.containsMouse ? Theme.bgHover : "transparent"
                    RowLayout {
                        z: 1                       // the check mark's click above the row's
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 10
                        Label { text: trackRow.current && Library.playing ? "\u25b6" : (albumView.discs ? trackRow.modelData.disc + "-" + String(trackRow.modelData.track).padStart(2, "0")
                                                                                                     : (trackRow.modelData.track || trackRow.index + 1)); color: trackRow.current ? Theme.accent : Theme.fgDim
                                font.pixelSize: 12; font.features: { "tnum": 1 }; Layout.preferredWidth: albumView.discs ? 34 : 22; horizontalAlignment: Text.AlignRight }
                        Label { text: trackRow.modelData.title; font.pixelSize: 13; font.weight: trackRow.current ? Font.DemiBold : Font.Normal; elide: Text.ElideRight; Layout.fillWidth: true }
                        Label { text: Media.fmt(trackRow.modelData.duration); dim: true; font.pixelSize: 11; font.features: { "tnum": 1 } }
                        // Quality check: where the highs end, when that gave it away
                        Label { visible: !!trackRow.check && (trackRow.check.verdict === "lossy" || trackRow.check.verdict === "upsampled")
                                text: (trackRow.check?.cutoff ?? "") + " kHz"; color: trackRow.checkColor; font.pixelSize: 10 }
                        Glyph {
                            visible: !!trackRow.check
                            text: trackRow.check?.verdict === "ok" ? "\uf00c" : trackRow.check?.verdict === "fake" ? "\uf05e" : "\uf071"
                            color: trackRow.checkColor
                            font.pixelSize: 11
                            MouseArea { anchors.fill: parent; anchors.margins: -6; cursorShape: Qt.PointingHandCursor
                                        onClicked: Library.spectrum(trackRow.modelData.file) }
                        }
                    }
                    MouseArea { id: trackMouse; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                                onClicked: Library.play(root.openAlbum, trackRow.index) }
                }
            }
        }
    }

    // ---------------- Radio: find and manage stations ----------------
    // Over the right column (the logo stays). Empty field: your stations (play,
    // remove). Typing: radio-browser.info results by name or frequency
    // ("96.9"), Mexico only by default; ▶ listens without saving, + saves.
    property bool mexicoOnly: true
    Rectangle {
        id: searchPane
        parent: root
        z: 8
        visible: root.radio && root.searching
        readonly property real side: root.height - 2 * Theme.zonePadding
        readonly property bool querying: searchField.text.trim() !== ""
        x: Theme.zonePadding + side + 24
        y: Theme.zonePadding + 38                 // below the corner buttons
        width: root.width - x - Theme.zonePadding
        height: root.height - y - Theme.zonePadding
        radius: Theme.zoneRadius
        color: Theme.bgAlt
        border.color: Theme.border

        MouseArea { anchors.fill: parent }        // keep clicks inside

        // Search as you type (after a pause)
        readonly property string query: searchField.text
        onQueryChanged: searchDebounce.restart()
        Timer { id: searchDebounce; interval: 500; onTriggered: Radio.search(searchPane.query, root.mexicoOnly) }

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                TextField {
                    id: searchField
                    Layout.fillWidth: true
                    icon: "\uf002"
                    placeholder: Tr.t("Station name or frequency, e.g. 96.9")
                    onAccepted: Radio.search(text, root.mexicoOnly)
                }
                Chip {
                    text: Tr.t("Mexico only")
                    implicitHeight: 30
                    active: root.mexicoOnly
                    onClicked: { root.mexicoOnly = !root.mexicoOnly; if (searchPane.querying) Radio.search(searchField.text, root.mexicoOnly); }
                }
            }

            Label {
                text: !searchPane.querying ? Tr.t("YOUR STATIONS")
                    : Radio.searching ? Tr.t("SEARCHING…")
                    : Radio.searchError ? "" : Tr.n(Radio.results.length, "%1 STATION", "%1 STATIONS")
                visible: text !== ""
                dim: true
                font.pixelSize: 10
                font.weight: Font.DemiBold
                font.letterSpacing: 1
            }
            Label {
                visible: searchPane.querying && Radio.searchError !== ""
                text: Radio.searchError
                color: Theme.bad
                font.pixelSize: 12
                wrapMode: Text.Wrap
                Layout.fillWidth: true
            }

            ListView {
                id: stationList
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 4
                boundsBehavior: Flickable.StopAtBounds
                model: searchPane.querying ? Radio.results : Radio.stations

                delegate: Rectangle {
                    id: row
                    required property var modelData
                    readonly property bool saved: Radio.isSaved(modelData)
                    readonly property bool playingThis: Radio.active && Radio.current?.url === modelData.url
                    width: ListView.view.width
                    height: 48
                    radius: 10
                    color: playingThis ? Theme.withAlpha(Theme.accent, 0.14) : rowMouse.containsMouse ? Theme.bgHover : "transparent"

                    MouseArea { id: rowMouse; anchors.fill: parent; hoverEnabled: true; onClicked: Radio.play(row.modelData) }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 6
                        spacing: 10
                        ClippingRectangle {
                            implicitWidth: 32; implicitHeight: 32; radius: 8
                            color: Theme.bgHover
                            Glyph { anchors.centerIn: parent; text: "\u{f0439}"; color: Theme.fgDim; visible: logo.status !== Image.Ready }
                            Image { id: logo; anchors.fill: parent; source: row.modelData.logo || ""; sourceSize: Qt.size(64, 64); fillMode: Image.PreserveAspectCrop; asynchronous: true }
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Label { text: row.modelData.name; font.pixelSize: 13; font.weight: row.playingThis ? Font.DemiBold : Font.Normal; elide: Text.ElideRight; Layout.fillWidth: true }
                            Label { text: row.modelData.subtitle || ""; visible: text !== ""; dim: true; font.pixelSize: 11; elide: Text.ElideRight; Layout.fillWidth: true }
                        }
                        IconButton {
                            icon: row.playingThis ? "\uf04d" : "\uf04b"
                            iconSize: 11; implicitWidth: 30; implicitHeight: 28; border.width: 0
                            onClicked: row.playingThis ? Radio.stop() : Radio.play(row.modelData)
                        }
                        // Results: save (or ✓ when saved); your stations: remove
                        IconButton {
                            icon: searchPane.querying ? (row.saved ? "\uf00c" : "\uf067") : "\uf1f8"
                            iconSize: 11; implicitWidth: 30; implicitHeight: 28; border.width: 0
                            iconColor: !searchPane.querying ? Theme.fgDim : row.saved ? Theme.good : Theme.fg
                            enabled: !(searchPane.querying && row.saved)
                            onClicked: searchPane.querying ? Radio.add(row.modelData) : Radio.remove(row.modelData)
                        }
                    }
                }

                Label {
                    anchors.centerIn: parent
                    visible: parent.count === 0 && !Radio.searching && !Radio.searchError
                    text: searchPane.querying ? Tr.t("No stations found") : Tr.t("No stations yet: search to add some")
                    dim: true
                    font.pixelSize: 12
                }
            }
        }
    }

    // ---------------- Popovers ----------------

    // Focus the first volume slider once the popover is shown
    Timer { id: volumeFocus; interval: 30; onTriggered: (root.appAudio ? appVolume : systemVolume).focusSlider() }

    // Focus the current output (or the first) once the list is shown
    Timer {
        id: outputFocus
        interval: 30
        onTriggered: {
            const i = Math.max(0, Media.sinks.indexOf(Media.sink));
            const item = outputRepeater.itemAt(i);
            if (item) item.forceActiveFocus();
        }
    }

    // Click anywhere else to close the open popover
    MouseArea {
        parent: root
        anchors.fill: parent
        visible: root.popover !== ""
        z: 9
        onClicked: root.popover = ""
    }

    // One vertical volume control: percent, slider, mute, and what it's for.
    // Keyboard: ↑/↓ by 5%, ←/→ to the other slider, M mutes, Esc closes the popover
    component VolumeColumn: ColumnLayout {
        id: col
        property real volume: 0
        property bool muted: false
        property string caption: ""
        signal setVolume(real v)
        signal setMuted(bool m)
        function focusSlider() { slider.forceActiveFocus(); }
        spacing: 8
        Layout.fillHeight: true
        Layout.preferredWidth: 56

        Label {
            Layout.alignment: Qt.AlignHCenter
            text: col.muted ? Tr.t("Mute") : Math.round(col.volume * 100) + "%"
            font.pixelSize: 12
            font.weight: Font.DemiBold
        }

        // Track + fill + knob, drag vertically
        Item {
            id: slider
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 24
            activeFocusOnTab: true
            function nudge(d) { col.setVolume(Math.max(0, Math.min(1, col.volume + d))); }
            Keys.onUpPressed: nudge(0.05)
            Keys.onDownPressed: nudge(-0.05)
            Keys.onRightPressed: nextItemInFocusChain(true).forceActiveFocus()
            Keys.onLeftPressed: nextItemInFocusChain(false).forceActiveFocus()
            Keys.onPressed: event => {
                if (event.key === Qt.Key_M) { col.setMuted(!col.muted); event.accepted = true; }
                else if (event.key === Qt.Key_Escape) { root.popover = ""; volumeButton.forceActiveFocus(); event.accepted = true; }
            }
            readonly property real value: Math.min(1, col.volume)
            FocusRing {}

            Rectangle {
                id: track
                anchors.horizontalCenter: parent.horizontalCenter
                width: 6
                height: parent.height
                radius: 3
                color: Theme.track
                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: parent.height * slider.value
                    radius: 3
                    color: col.muted ? Theme.fgDim : Theme.accent
                }
            }
            Rectangle {
                anchors.horizontalCenter: parent.horizontalCenter
                y: track.height * (1 - slider.value) - height / 2
                width: 16; height: 16; radius: 8
                color: Theme.fg
            }
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                function set(my) { col.setVolume(Math.max(0, Math.min(1, 1 - my / height))); }
                onPressed: mouse => { slider.forceActiveFocus(); set(mouse.y); }
                onPositionChanged: mouse => { if (pressed) set(mouse.y); }
                onWheel: wheel => slider.nudge(wheel.angleDelta.y > 0 ? 0.05 : -0.05)
            }
        }

        IconButton {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: 34; implicitHeight: 28
            icon: col.muted ? "\uf026" : "\uf028"
            active: col.muted
            onClicked: col.setMuted(!col.muted)
        }
        Label {
            Layout.alignment: Qt.AlignHCenter
            Layout.maximumWidth: 60
            text: col.caption
            dim: true
            font.pixelSize: 10
            elide: Text.ElideRight
        }
    }

    // Volume popover, left of the speaker button: the app's own volume (when
    // its PipeWire stream is found) and the system's
    Rectangle {
        parent: root
        z: 10
        visible: root.popover === "volume"
        width: volumeRow.implicitWidth + 20
        height: 230
        radius: 16
        color: Theme.bgAlt
        border.color: Theme.border
        // mapToItem isn't reactive: re-evaluate whenever the popover opens or the zone resizes
        readonly property point anchor: { root.popover; root.width; root.height;
                                          return volumeButton.mapToItem(root, 0, volumeButton.height / 2); }
        x: anchor.x - width - 10
        y: Math.max(8, Math.min(root.height - height - 8, anchor.y - height / 2))

        MouseArea { anchors.fill: parent }   // keep clicks inside

        RowLayout {
            id: volumeRow
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            VolumeColumn {
                id: appVolume
                visible: !!root.appAudio
                caption: root.appName
                volume: root.appAudio?.volume ?? 0
                muted: root.appAudio?.muted ?? false
                onSetVolume: v => root.setAppVolume(v)
                onSetMuted: m => root.setAppMuted(m)
            }
            Rectangle { visible: !!root.appAudio; Layout.fillHeight: true; Layout.topMargin: 6; Layout.bottomMargin: 6; implicitWidth: 1; color: Theme.border }
            VolumeColumn {
                id: systemVolume
                caption: Tr.t("System")
                volume: root.sinkAudio?.volume ?? 0
                muted: root.sinkAudio?.muted ?? false
                onSetVolume: v => { if (root.sinkAudio) root.sinkAudio.volume = v; }
                onSetMuted: m => { if (root.sinkAudio) root.sinkAudio.muted = m; }
            }
        }
    }

    // Audio output picker (PipeWire sinks), left of the output button
    Rectangle {
        parent: root
        z: 10
        visible: root.popover === "output"
        width: 300
        height: outputList.implicitHeight + 20
        radius: 16
        color: Theme.bgAlt
        border.color: Theme.border
        // mapToItem isn't reactive: re-evaluate whenever the popover opens or the zone resizes
        readonly property point anchor: { root.popover; root.width; root.height;
                                          return outputButton.mapToItem(root, 0, outputButton.height / 2); }
        x: anchor.x - width - 10
        y: Math.max(8, Math.min(root.height - height - 8, anchor.y - height / 2))

        MouseArea { anchors.fill: parent }   // keep clicks inside

        ColumnLayout {
            id: outputList
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 10
            spacing: 4

            Label { text: Tr.t("OUTPUT"); dim: true; font.pixelSize: 10; font.weight: Font.DemiBold; font.letterSpacing: 1; Layout.leftMargin: 6 }

            Repeater {
                id: outputRepeater
                model: Media.sinks
                delegate: Rectangle {
                    id: sinkItem
                    required property var modelData
                    required property int index
                    readonly property bool current: modelData === Media.sink
                    Layout.fillWidth: true
                    implicitHeight: 36

                    // Keyboard: ↑/↓ move, Enter picks, Esc closes
                    activeFocusOnTab: root.popover === "output"
                    objectName: "sink" + index
                    Keys.onReturnPressed: { Media.setSink(modelData); root.popover = ""; outputButton.forceActiveFocus(); }
                    Keys.onEnterPressed: { Media.setSink(modelData); root.popover = ""; outputButton.forceActiveFocus(); }
                    Keys.onDownPressed: nextItemInFocusChain(true).forceActiveFocus()
                    Keys.onUpPressed: nextItemInFocusChain(false).forceActiveFocus()
                    Keys.onEscapePressed: { root.popover = ""; outputButton.forceActiveFocus(); }
                    FocusRing {}
                    radius: 10
                    color: current ? Theme.withAlpha(Theme.accent, 0.16) : (sinkMouse.containsMouse || activeFocus ? Theme.bgHover : "transparent")

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 10
                        Glyph { text: parent.parent.current ? "\uf00c" : ""; font.pixelSize: 11; color: Theme.accent; Layout.preferredWidth: 14 }
                        Label {
                            Layout.fillWidth: true
                            text: Media.sinkName(parent.parent.modelData)
                            font.pixelSize: 12
                            font.weight: parent.parent.current ? Font.DemiBold : Font.Normal
                        }
                    }
                    MouseArea {
                        id: sinkMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: { Media.setSink(parent.modelData); root.popover = ""; }
                    }
                }
            }
        }
    }
}
