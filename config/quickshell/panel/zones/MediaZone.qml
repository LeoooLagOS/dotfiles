import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris
import Quickshell.Widgets
import "../common"
import "../services"

// ZONE: Media (full tab) — large album art; track info with two side buttons
// (system volume as a vertical slider, audio output picker); transport
// controls; and at the bottom a cava visualizer that doubles as the seekable
// progress bar, with elapsed / total time.
// Two views, switched by the button in the top-right corner (saved,
// Settings.v.mediaMode): the MPRIS player, or internet radio (services/Radio.qml)
// with the same layout — station logo, a chip per station, what's on air,
// previous / play-stop / next station, and cava with the listening time.
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
             lib.cardRate ? [lib.bitperfect ? { t: "Bit-perfect", on: true }
                                           : { t: "Resampled " + (lib.rate / 1000) + " → " + (lib.cardRate / 1000) + " kHz", on: false }] : [])
    readonly property var station: Radio.current
    readonly property var sinkAudio: Media.sink?.audio ?? null

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
            model: [{ mode: "player", icon: "\uf001" }, { mode: "radio", icon: "\u{f0439}" }, { mode: "library", icon: "\u{f0025}" }]
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
            Label { anchors.horizontalCenter: parent.horizontalCenter; text: "Nothing playing"; dim: true; font.pixelSize: 15 }
            Label { anchors.horizontalCenter: parent.horizontalCenter; text: "Play something in Spotify, Firefox, mpv…"; dim: true; font.pixelSize: 12 }
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

            Glyph { anchors.centerIn: parent; text: root.radio ? "\u{f0439}" : root.library ? "\u{f0025}" : "\uf001"; font.pixelSize: 64; color: Theme.fgDim; visible: art.status !== Image.Ready }
            Image {
                id: art
                anchors.fill: parent
                source: root.radio ? (root.station?.logo ?? "")
                      : root.library ? (root.lib.cover ? "file://" + root.lib.cover : "")
                      : (root.player?.trackArtUrl ?? "")
                fillMode: Image.PreserveAspectCrop
                sourceSize: Qt.size(600, 600)
                asynchronous: true
            }
        }

        // --- Info, controls, visualizer ---
        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 12

            // Player picker (only when there is more than one) / station picker
            Flow {
                Layout.fillWidth: true
                Layout.rightMargin: 40           // room for the player ↔ radio button
                spacing: 6
                visible: root.radio || (root.library ? root.qualityChips.length > 0 : Media.players.length > 1)
                Repeater {
                    model: root.radio ? Radio.stations : root.library ? root.qualityChips : Media.players
                    delegate: Chip {
                        required property var modelData
                        implicitHeight: 26
                        // Identity alone is ambiguous (e.g. two Firefox tabs): add the track
                        text: { if (root.radio) return modelData.name;
                                if (root.library) return modelData.t;
                                const t = modelData.identity.split(" ")[0] + (modelData.trackTitle ? " · " + modelData.trackTitle : "");
                                return t.length > 34 ? t.slice(0, 33) + "…" : t; }
                        active: root.radio ? modelData.name === root.station?.name : root.library ? modelData.on : modelData === root.player
                        onClicked: root.radio ? Radio.play(modelData) : root.library ? {} : Media.pick(modelData)
                    }
                }
            }

            Item { Layout.fillHeight: true }

            // Track info + side buttons (volume, output)
            RowLayout {
                Layout.fillWidth: true
                spacing: 16

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    Label {
                        text: root.radio ? (Radio.loading ? "RADIO · CONNECTING…" : Radio.recording ? "RADIO · LIVE · ● REC " + Radio.recordElapsed
                                            : Radio.active ? "RADIO · LIVE" : "RADIO")
                            : root.library ? "LIBRARY · " + (Library.playing ? "PLAYING" : Library.active ? "PAUSED" : Library.albums.length + " ALBUMS")
                                         : (root.player?.identity ?? "")
                        dim: true
                        font.pixelSize: 11
                        font.weight: Font.DemiBold
                        font.letterSpacing: 1
                        Layout.fillWidth: true
                    }
                    Label {
                        text: root.radio ? (root.station?.name ?? "No stations")
                            : root.library ? (Library.active ? root.lib.title : "Choose an album")
                            : (root.player?.trackTitle || "Unknown title")
                        color: Theme.accent
                        font.pixelSize: 24
                        font.weight: Font.DemiBold
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        Layout.fillWidth: true
                    }
                    // Radio: what's on air (the stream's title), then frequency / city
                    Label { text: root.radio ? Radio.onAir : root.library ? (Library.active ? root.lib.artist : "Browse your albums with the search button") : (root.player?.trackArtist ?? ""); font.pixelSize: 15; visible: text !== ""; Layout.fillWidth: true; elide: Text.ElideRight }
                    Label { text: root.radio ? (root.station?.subtitle ?? "") : root.library ? (Library.active ? root.lib.album : "") : (root.player?.trackAlbum ?? ""); dim: true; font.pixelSize: 13; visible: text !== ""; Layout.fillWidth: true }
                }

                ColumnLayout {
                    id: sideButtons
                    Layout.alignment: Qt.AlignVCenter
                    spacing: 8

                    IconButton {
                        id: volumeButton
                        icon: (root.sinkAudio?.muted ?? false) ? "\uf026" : "\uf028"
                        active: root.popover === "volume"
                        onClicked: { root.popover = root.popover === "volume" ? "" : "volume"; if (root.popover) vslider.forceActiveFocus(); }
                    }
                    IconButton {
                        id: outputButton
                        icon: "\u{f04c3}"     // speaker / audio output
                        active: root.popover === "output"
                        onClicked: { root.popover = root.popover === "output" ? "" : "output"; if (root.popover) outputFocus.start(); }
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
                }
            }

            Item { Layout.fillHeight: true }

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
                Layout.topMargin: 6
                spacing: 10

                Label { Layout.alignment: Qt.AlignBottom; text: root.radio ? Radio.elapsed : root.library ? Media.fmt(root.lib.elapsed) : Media.fmt(root.player?.position); dim: true; font.pixelSize: 11; font.features: { "tnum": 1 } }

                Item {
                    id: viz
                    Layout.fillWidth: true
                    implicitHeight: 76

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

                Label { Layout.alignment: Qt.AlignBottom; text: root.radio ? "LIVE" : root.library ? Media.fmt(root.lib.duration) : Media.fmt(root.player?.length)
                        color: root.radio && Radio.active ? Theme.accent : Theme.fgDim
                        font.pixelSize: 11; font.weight: root.radio ? Font.DemiBold : Font.Normal; font.features: { "tnum": 1 } }
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
                text: Library.problem === "mpd" ? "The music library needs MPD" : Library.problem ? "The music library isn't answering" : "Connecting to the library…"
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
                    ? "MPD plays ~/Music in full quality. Install it and start it once:\nsudo dnf install mpd mpc  ·  systemctl --user enable --now mpd"
                    : Library.problem
            }
        }
    }

    // ---------------- Library: browse albums ----------------
    // Over the right column, like the radio search: album covers (filter by
    // album or artist); an album opens its tracks — Play, Queue, or a track.
    property var openAlbum: null
    onSearchingChanged: if (!searching) openAlbum = null
    Rectangle {
        id: libPane
        parent: root
        z: 8
        visible: root.library && root.searching
        readonly property real side: root.height - 2 * Theme.zonePadding
        readonly property string q: libField.text.trim().toLowerCase()
        readonly property var shown: q ? Library.albums.filter(a => (a.album + " " + a.artist).toLowerCase().includes(q)) : Library.albums
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
                TextField { id: libField; Layout.fillWidth: true; icon: "\uf002"; placeholder: "Album or artist" }
                IconButton {
                    icon: "\uf021"                 // rescan ~/Music
                    iconSize: 12; implicitWidth: 34; implicitHeight: 30
                    active: Library.now.updating ?? false
                    onClicked: Library.rescan()
                }
            }
            Label {
                text: Library.loadingAlbums ? "READING ~/Music…"
                    : libPane.shown.length + (libPane.shown.length === 1 ? " ALBUM" : " ALBUMS")
                      + (Library.albums.filter(a => a.hires).length ? " · " + Library.albums.filter(a => a.hires).length + " HI-RES" : "")
                dim: true; font.pixelSize: 10; font.weight: Font.DemiBold; font.letterSpacing: 1
            }
            GridView {
                id: albumGrid
                Layout.fillWidth: true
                Layout.fillHeight: true
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
                Label {
                    anchors.centerIn: parent
                    width: parent.width - 40
                    horizontalAlignment: Text.AlignHCenter
                    wrapMode: Text.Wrap
                    visible: parent.count === 0 && !Library.loadingAlbums
                    text: libPane.q ? "No albums match" : "No albums yet. Put them in ~/Music as Artist/Album (Year)/, or import with: beet import <folder>"
                    dim: true
                    font.pixelSize: 12
                }
            }
        }

        // An album: header with Play / Queue, then its tracks
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8
            id: albumView
            visible: !!root.openAlbum
            readonly property var a: root.openAlbum ?? ({ tracks: [] })

            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                IconButton { icon: "\uf053"; iconSize: 11; implicitWidth: 30; implicitHeight: 28; onClicked: root.openAlbum = null }
                ClippingRectangle {
                    implicitWidth: 56; implicitHeight: 56; radius: 8; color: Theme.bgHover
                    Image { anchors.fill: parent; source: albumView.a.cover ? "file://" + albumView.a.cover : ""
                            sourceSize: Qt.size(112, 112); fillMode: Image.PreserveAspectCrop; asynchronous: true }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 1
                    Label { text: albumView.a.album ?? ""; font.pixelSize: 15; font.weight: Font.DemiBold; elide: Text.ElideRight; Layout.fillWidth: true }
                    Label { text: (albumView.a.artist ?? "") + (albumView.a.year ? " · " + albumView.a.year : ""); dim: true; font.pixelSize: 12; elide: Text.ElideRight; Layout.fillWidth: true }
                    Label { text: (albumView.a.quality ?? "") + " · " + albumView.a.tracks.length + " tracks"; dim: true; font.pixelSize: 11 }
                }
                Chip { text: "Play"; icon: "\uf04b"; filled: true; onClicked: { Library.play(root.openAlbum, 0); root.searching = false; } }
                Chip { text: "Queue"; icon: "\uf067"; onClicked: Library.queue(root.openAlbum) }
            }
            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 2
                boundsBehavior: Flickable.StopAtBounds
                model: albumView.a.tracks
                delegate: Rectangle {
                    id: trackRow
                    required property var modelData
                    required property int index
                    readonly property bool current: Library.active && Library.now.title === modelData.title && Library.now.album === root.openAlbum?.album
                    width: ListView.view.width
                    height: 36
                    radius: 8
                    color: current ? Theme.withAlpha(Theme.accent, 0.14) : trackMouse.containsMouse ? Theme.bgHover : "transparent"
                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 10
                        anchors.rightMargin: 10
                        spacing: 10
                        Label { text: trackRow.current && Library.playing ? "\u25b6" : (trackRow.modelData.track || trackRow.index + 1); color: trackRow.current ? Theme.accent : Theme.fgDim
                                font.pixelSize: 12; font.features: { "tnum": 1 }; Layout.preferredWidth: 22; horizontalAlignment: Text.AlignRight }
                        Label { text: trackRow.modelData.title; font.pixelSize: 13; font.weight: trackRow.current ? Font.DemiBold : Font.Normal; elide: Text.ElideRight; Layout.fillWidth: true }
                        Label { text: Media.fmt(trackRow.modelData.duration); dim: true; font.pixelSize: 11; font.features: { "tnum": 1 } }
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
                    placeholder: "Station name or frequency, e.g. 96.9"
                    onAccepted: Radio.search(text, root.mexicoOnly)
                }
                Chip {
                    text: "Mexico only"
                    implicitHeight: 30
                    active: root.mexicoOnly
                    onClicked: { root.mexicoOnly = !root.mexicoOnly; if (searchPane.querying) Radio.search(searchField.text, root.mexicoOnly); }
                }
            }

            Label {
                text: !searchPane.querying ? "YOUR STATIONS"
                    : Radio.searching ? "SEARCHING…"
                    : Radio.searchError ? "" : Radio.results.length + (Radio.results.length === 1 ? " STATION" : " STATIONS")
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
                    text: searchPane.querying ? "No stations found" : "No stations yet: search to add some"
                    dim: true
                    font.pixelSize: 12
                }
            }
        }
    }

    // ---------------- Popovers ----------------

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

    // Vertical volume slider (system output), left of the speaker button
    Rectangle {
        parent: root
        z: 10
        visible: root.popover === "volume"
        width: 64
        height: 210
        radius: 16
        color: Theme.bgAlt
        border.color: Theme.border
        // mapToItem isn't reactive: re-evaluate whenever the popover opens or the zone resizes
        readonly property point anchor: { root.popover; root.width; root.height;
                                          return volumeButton.mapToItem(root, 0, volumeButton.height / 2); }
        x: anchor.x - width - 10
        y: Math.max(8, Math.min(root.height - height - 8, anchor.y - height / 2))

        MouseArea { anchors.fill: parent }   // keep clicks inside

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 8

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: (root.sinkAudio?.muted ?? false) ? "Mute" : Math.round((root.sinkAudio?.volume ?? 0) * 100) + "%"
                font.pixelSize: 12
                font.weight: Font.DemiBold
            }

            // Track + fill + knob, drag vertically
            Item {
                id: vslider
                Layout.fillHeight: true
                Layout.alignment: Qt.AlignHCenter
                implicitWidth: 24

                // Keyboard: ↑/↓ by 5%, M mutes, Esc closes the popover
                focus: root.popover === "volume"
                function nudge(d) { if (root.sinkAudio) root.sinkAudio.volume = Math.max(0, Math.min(1, root.sinkAudio.volume + d)); }
                Keys.onUpPressed: nudge(0.05)
                Keys.onDownPressed: nudge(-0.05)
                Keys.onRightPressed: nudge(0.05)
                Keys.onLeftPressed: nudge(-0.05)
                Keys.onPressed: event => {
                    if (event.key === Qt.Key_M && root.sinkAudio) { root.sinkAudio.muted = !root.sinkAudio.muted; event.accepted = true; }
                    else if (event.key === Qt.Key_Escape) { root.popover = ""; volumeButton.forceActiveFocus(); event.accepted = true; }
                }
                readonly property real value: Math.min(1, root.sinkAudio?.volume ?? 0)

                Rectangle {
                    id: vtrack
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 6
                    height: parent.height
                    radius: 3
                    color: Theme.track
                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: parent.height * vslider.value
                        radius: 3
                        color: Theme.accent
                    }
                }
                Rectangle {
                    anchors.horizontalCenter: parent.horizontalCenter
                    y: vtrack.height * (1 - vslider.value) - height / 2
                    width: 16; height: 16; radius: 8
                    color: Theme.fg
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    function set(my) {
                        if (root.sinkAudio) root.sinkAudio.volume = Math.max(0, Math.min(1, 1 - my / height));
                    }
                    onPressed: mouse => set(mouse.y)
                    onPositionChanged: mouse => { if (pressed) set(mouse.y); }
                    onWheel: wheel => {
                        if (root.sinkAudio)
                            root.sinkAudio.volume = Math.max(0, Math.min(1, root.sinkAudio.volume + (wheel.angleDelta.y > 0 ? 0.05 : -0.05)));
                    }
                }
            }

            IconButton {
                Layout.alignment: Qt.AlignHCenter
                implicitWidth: 34; implicitHeight: 28
                icon: (root.sinkAudio?.muted ?? false) ? "\uf026" : "\uf028"
                active: root.sinkAudio?.muted ?? false
                onClicked: if (root.sinkAudio) root.sinkAudio.muted = !root.sinkAudio.muted
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

            Label { text: "OUTPUT"; dim: true; font.pixelSize: 10; font.weight: Font.DemiBold; font.letterSpacing: 1; Layout.leftMargin: 6 }

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
