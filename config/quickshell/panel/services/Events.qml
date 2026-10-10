pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../common"

// Calendar events from scripts/events.py.
//   - month data: the month shown in the calendar (`year`, `month`)
//   - upcoming:   today → +7 days, independent of the month on screen; drives
//                 the agenda and the reminders
//   - reminders:  a notification `reminder` minutes before each event (15 for
//                 Outlook events, which are marked important → critical
//                 urgency; local events use the reminder chosen when created).
//                 Already-sent reminders are remembered across restarts.
//   - add / remove local events (panel.ics), refresh (forces an Outlook download)
Singleton {
    id: root
    property int year: new Date().getFullYear()
    property int month: new Date().getMonth()    // 0-based
    property date selected: new Date()           // shared by the calendar zones
    property var byDate: ({})                     // month data: "YYYY-MM-DD" → [events]
    property var upcoming: []                     // next 7 days, sorted
    property bool loading: false
    property var errors: []
    property string lastError: ""                 // from add/delete

    readonly property string script: Quickshell.shellDir + "/scripts/events.py"

    function key(d) {
        return d.getFullYear() + "-" + String(d.getMonth() + 1).padStart(2, "0")
             + "-" + String(d.getDate()).padStart(2, "0");
    }
    function eventsOn(d) {
        const k = key(d);
        return byDate[k] ?? upcoming.filter(e => e.date === k);
    }
    function run(proc, args, stdin) {
        proc.command = ["bash", "-c", Config.eventsPython + " \"$0\" \"$@\"", script].concat(args);
        proc.stdinPayload = stdin ?? "";
        proc.running = true;
    }

    // ---------------- Month data ----------------
    function reload(force) {
        // Whole visible grid: from a week before the 1st to 6 weeks after
        const from = new Date(year, month, 1 - 7), to = new Date(year, month, 1 + 42);
        run(monthProc, ["list", key(from), key(to)].concat(force ? ["--force"] : []));
    }
    onYearChanged: reloadSoon.restart()
    onMonthChanged: reloadSoon.restart()
    Timer { id: reloadSoon; interval: 150; onTriggered: root.reload(false) }

    Process {
        id: monthProc
        property string stdinPayload: ""
        onRunningChanged: { root.loading = running; if (running && stdinPayload) { write(stdinPayload); stdinEnabled = false; } }
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const d = JSON.parse(text);
                    const map = {};
                    for (const e of d.events) (map[e.date] = map[e.date] ?? []).push(e);
                    root.byDate = map;
                    root.errors = d.errors;
                } catch (e) { console.warn("events:", e, text.slice(0, 200)); }
            }
        }
        stderr: StdioCollector { onStreamFinished: if (text.trim()) console.warn("events.py:", text.trim().slice(-300)) }
    }

    // ---------------- Upcoming (today → +7 days) ----------------
    function reloadUpcoming(force) {
        const today = new Date(), to = new Date(today.getFullYear(), today.getMonth(), today.getDate() + 7);
        run(upcomingProc, ["list", key(today), key(to)].concat(force ? ["--force"] : []));
    }
    Process {
        id: upcomingProc
        property string stdinPayload: ""
        stdout: StdioCollector {
            onStreamFinished: {
                try { root.upcoming = JSON.parse(text).events; root.checkReminders(); }
                catch (e) { console.warn("events (upcoming):", e); }
            }
        }
    }

    // Force-refresh everything (Outlook download skips the cache)
    function refresh() { reload(true); refreshUpcomingSoon.restart(); }
    Timer { id: refreshUpcomingSoon; interval: 2500; onTriggered: root.reloadUpcoming(false) }

    Timer {
        interval: Config.eventsIntervalMs
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: { if (!monthProc.running) root.reload(false); root.reloadUpcoming(false); }
    }

    // ---------------- Local events: add / remove ----------------
    // spec: { title, date "YYYY-MM-DD", start "HH:MM", end "HH:MM", allDay, location, notes, reminder }
    function add(spec) { lastError = ""; run(editProc, ["add"], JSON.stringify(spec)); }
    function remove(uid) { lastError = ""; run(editProc, ["delete", uid]); }

    Process {
        id: editProc
        property string stdinPayload: ""
        stdinEnabled: true
        onRunningChanged: if (running && stdinPayload !== "") { write(stdinPayload + "\n"); stdinEnabled = false; }
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const d = JSON.parse(text);
                    if (!d.ok) root.lastError = d.error ?? "Could not save the event";
                } catch (e) { root.lastError = String(e); }
                editProc.stdinEnabled = true;
                root.reload(false);
                root.reloadUpcoming(false);
            }
        }
    }

    // ---------------- Reminders ----------------
    property var reminded: ({})            // "uid|startIso" → true

    FileView {
        id: remindedFile
        path: Quickshell.env("HOME") + "/.local/state/quickshell-panel/reminded.json"
        atomicWrites: true
        onLoaded: { try { root.reminded = JSON.parse(text()); } catch (e) { root.reminded = {}; } }
        onLoadFailed: root.reminded = {}
    }

    function checkReminders() {
        const now = new Date();
        let changed = false;
        const r = Object.assign({}, reminded);
        for (const e of upcoming) {
            if (e.allDay || !e.startIso || !(e.reminder > 0)) continue;
            const start = new Date(e.startIso);
            const k = e.uid + "|" + e.startIso;
            if (r[k] || now >= start) continue;
            if (now >= new Date(start.getTime() - e.reminder * 60000)) {
                notify(e, Math.max(1, Math.round((start - now) / 60000)));
                r[k] = true;
                changed = true;
            }
        }
        if (changed) {
            // Forget reminders older than 2 days so the file stays small
            const cutoff = now.getTime() - 2 * 86400000;
            for (const k of Object.keys(r)) if (new Date(k.split("|")[1]).getTime() < cutoff) delete r[k];
            reminded = r;
            Quickshell.execDetached(["mkdir", "-p", Quickshell.env("HOME") + "/.local/state/quickshell-panel"]);
            remindedFile.setText(JSON.stringify(r));
        }
    }

    function notify(e, mins) {
        const when = mins <= 1 ? "now" : "in " + mins + " min";
        const body = e.start + (e.end ? " – " + e.end : "") + (e.location ? " · " + e.location : "")
                   + (e.high ? "\nHigh importance" : "");
        Quickshell.execDetached(["notify-send",
            "-a", "Calendar", "-i", "x-office-calendar",
            "-u", e.important ? "critical" : "normal",
            "-c", "calendar.reminder",
            (e.important ? "★ " : "") + e.title + " · " + when, body]);
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root.checkReminders()
    }
}
