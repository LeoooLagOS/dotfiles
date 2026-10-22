pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../common"

// State and actions of the Controls toggles that have no service of their own.
//   night      hyprsunset through scripts/wm/Hyprsunset.sh (same state file as
//              SUPER N and waybar); temperature saved for the script
//   caffeine   `systemd-inhibit --what=idle` (hypridle honors it), optionally timed
//   airplane   rfkill: Wi-Fi + Bluetooth blocked; turning it off restores what
//              was on before
//   game       scripts/wm/GameMode.sh (Hyprland animations off = on)
Singleton {
    id: root

    readonly property string scripts: Quickshell.env("HOME") + "/.config/hypr/scripts"

    // ---------------- Night light ----------------
    property bool night: false
    FileView {
        path: Quickshell.env("HOME") + "/.cache/.hyprsunset_state"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: root.night = text().trim() === "on"
    }
    function toggleNight() { Quickshell.execDetached([scripts + "/Hyprsunset.sh", "toggle"]); }
    FileView { id: tempFile; path: Quickshell.env("HOME") + "/.config/lagos/nightlight-temp"; printErrors: false; preload: false }
    // Live while dragging; saved (for the script) when released
    function previewTemp(k) { if (night) Quickshell.execDetached(["hyprctl", "hyprsunset", "temperature", String(k)]); }
    function setTemp(k) {
        Settings.set("nightTemp", k);
        tempFile.setText(k + "\n");
        previewTemp(k);
    }

    // ---------------- Caffeine ----------------
    property bool caffeine: false
    property var caffeineUntil: null           // Date, or null = until turned off
    property int caffeineMinutes: 0            // the chosen duration (0 = until turned off)
    function setCaffeine(on, minutes) {
        caffeineMinutes = on ? minutes : 0;
        caffeineUntil = on && minutes ? new Date(Date.now() + minutes * 60000) : null;
        caffeine = on;
    }
    Process {
        running: root.caffeine
        command: ["systemd-inhibit", "--what=idle", "--who=Quickshell panel", "--why=Caffeine (Controls)", "sleep", "infinity"]
    }
    Timer {
        interval: 30000
        running: root.caffeine && root.caffeineUntil !== null
        repeat: true
        onTriggered: if (new Date() >= root.caffeineUntil) root.setCaffeine(false, 0)
    }
    readonly property string caffeineStatus: !caffeine ? Tr.t("Off")
        : caffeineUntil ? Tr.t("Until %1", Qt.formatTime(caffeineUntil, "HH:mm")) : Tr.t("Until turned off")

    // ---------------- Airplane mode ----------------
    property bool wifiBlocked: false
    property bool btBlocked: false
    readonly property bool airplane: wifiBlocked && btBlocked
    property var beforeAirplane: ({ wifi: true, bt: false })
    function readRfkill() { if (!rfkillProc.running) rfkillProc.running = true; }
    Process {
        id: rfkillProc
        command: ["rfkill", "-J", "-o", "TYPE,SOFT"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const list = Object.values(JSON.parse(text))[0] ?? [];
                    const blocked = type => list.filter(d => d.type === type).some(d => d.soft === "blocked");
                    root.wifiBlocked = blocked("wlan");
                    root.btBlocked = blocked("bluetooth");
                } catch (e) {}
            }
        }
    }
    function toggleAirplane() {
        if (!airplane) {
            beforeAirplane = { wifi: !wifiBlocked, bt: !btBlocked };
            Quickshell.execDetached(["bash", "-c", "rfkill block wlan; rfkill block bluetooth"]);
        } else {
            Quickshell.execDetached(["bash", "-c", (beforeAirplane.wifi ? "rfkill unblock wlan;" : "")
                + (beforeAirplane.bt ? "rfkill unblock bluetooth;" : "") + "true"]);
        }
        readSoon.restart();
    }

    // ---------------- Game mode ----------------
    property bool game: false
    property bool gameBusy: false              // GameMode.sh reloads Hyprland when turning off
    Process {
        id: gameProc
        command: ["bash", "-c", "hyprctl getoption animations:enabled -j | jq -r '.bool'"]
        stdout: StdioCollector { onStreamFinished: root.game = text.trim() === "false" || text.trim() === "0" }
    }
    function toggleGame() {
        gameBusy = true;
        game = !game;
        gameRun.running = true;
    }
    Process {
        id: gameRun
        command: [root.scripts + "/GameMode.sh"]
        onRunningChanged: if (!running) { root.gameBusy = false; gameProc.running = true; }
    }

    // ---------------- Polling (only while the panel is open) ----------------
    Timer { id: readSoon; interval: 400; onTriggered: root.readRfkill() }
    Timer {
        interval: 3000
        running: PanelState.open
        repeat: true
        triggeredOnStart: true
        onTriggered: { root.readRfkill(); if (!gameRun.running && !gameProc.running) gameProc.running = true; }
    }
}
