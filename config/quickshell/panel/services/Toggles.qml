pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../common"

// State and actions of the Controls toggles that have no service of their own.
//   night      hyprsunset through scripts/wm/Hyprsunset.sh (same state file as
//              SUPER ALT N and waybar); temperature saved for the script; on a
//              schedule too, like Windows (Settings → Night light)
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
        onLoaded: { root.night = text().trim() === "on"; root.nightRead = true; }
        onLoadFailed: { root.night = false; root.nightRead = true; }
    }
    property bool nightRead: false              // the state file was read: `night` is real
    function toggleNight() { Quickshell.execDetached([scripts + "/Hyprsunset.sh", "toggle"]); }

    // Schedule, like Windows' (Settings → Night light): never / sunset to
    // sunrise (today's times from the forecast, Open-Meteo, for the weather
    // location) / set hours. It acts only when the period changes (and once
    // at start), so turning it on or off by hand lasts until the next change.
    function minutesOf(hhmm) { const p = String(hhmm).split(":"); return Number(p[0]) * 60 + Number(p[1]); }
    // {on, off} in minutes of the day, or null (no schedule, or no sun times yet)
    readonly property var nightWindow: {
        const s = Settings.v.nightSchedule;
        if (s === "hours") return { on: Settings.v.nightOnAt, off: Settings.v.nightOffAt };
        if (s !== "sun") return null;
        const today = Qt.formatDate(clock.now, "yyyy-MM-dd");
        // Offline, the last forecast's times: they move a minute a day
        const d = Forecast.daily.find(x => x.date === today) ?? Forecast.daily[0];
        return d?.sunset && d?.sunrise ? { on: minutesOf(d.sunset), off: minutesOf(d.sunrise) } : null;
    }
    function fmtMin(m) { return String(Math.floor(m / 60)).padStart(2, "0") + ":" + String(m % 60).padStart(2, "0"); }
    // "On at 17:54 · off at 06:42", for the Controls detail
    readonly property string nightPlan: nightWindow
        ? Tr.t("On at %1 · off at %2", fmtMin(nightWindow.on), fmtMin(nightWindow.off)) : ""
    property var scheduleWanted: null           // the last period's choice; null = decide now
    function checkSchedule() {
        const w = nightWindow;
        if (!w || !nightRead || w.on === w.off) return;
        const n = new Date();
        const m = n.getHours() * 60 + n.getMinutes();
        const want = w.on > w.off ? (m >= w.on || m < w.off) : (m >= w.on && m < w.off);
        if (want === scheduleWanted) return;
        scheduleWanted = want;
        if (want !== night) toggleNight();
    }
    QtObject { id: clock; property date now: new Date() }
    Timer {
        interval: 30000
        running: Settings.v.nightSchedule !== "off"
        repeat: true
        triggeredOnStart: true
        onTriggered: { clock.now = new Date(); root.checkSchedule(); }
    }
    // A new schedule decides again right away (a hand toggle doesn't outlive it)
    Connections {
        target: Settings
        function onChanged(key) {
            if (["nightSchedule", "nightOnAt", "nightOffAt"].includes(key)) { root.scheduleWanted = null; root.checkSchedule(); }
        }
    }
    onNightReadChanged: checkSchedule()
    onNightWindowChanged: checkSchedule()
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
