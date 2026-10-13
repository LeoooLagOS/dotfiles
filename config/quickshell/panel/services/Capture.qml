pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../common"
import "../common/When.js" as When

// Quick capture (QuickAdd.qml): one line in natural language becomes a to-do or
// an event (common/When.js), with a live preview of what was understood.
//   open(text, from)   show it, prefilled (from: where it came from, kept as notes)
//   openSelection()    prefilled with the selected text (primary selection,
//                      else the clipboard): SUPER SHIFT Z
//   toggleKind()       task ↔ event (Tab)
//   save()             Enter: to Todos / Events, said on the island with an Undo
// SUPER Z opens it (IPC quickAdd); notifications have an "Add" button.
Singleton {
    id: root

    property bool shown: false
    property string text: ""
    property string source: ""                // "WhatsApp · Ana: …"
    property string kind: ""                  // "" (as understood) | "task" | "event"
    property date now: new Date()
    readonly property var result: When.parse(text + (kind ? (kind === "event" ? " #event" : " #task") : ""), now)
    readonly property var chips: text.trim() ? When.describe(result, now) : []

    signal opened()
    function open(prefill, from) {
        now = new Date();
        text = prefill ?? "";
        source = from ?? "";
        kind = "";
        shown = true;
        opened();
    }
    function close() { shown = false; }
    function openSelection() { selProc.running = true; }
    function toggleKind() { kind = result.kind === "event" ? "task" : "event"; }

    function save() {
        const r = result;
        if (!r.title) return;
        const when = (r.date ? When.dayWord(r.date, now).toLowerCase() : "") + (r.start ? " " + r.start : "");
        if (r.kind === "event") {
            Events.add({ title: r.title, date: r.date, start: r.start, end: r.end, allDay: r.allDay,
                         location: r.place, notes: source, reminder: r.allDay ? 0 : 10, repeat: r.repeat }, true);
        } else {
            const before = Todos.items;
            Todos.add(r.title, "task", r.date, r.start, r.repeat, r.place);
            BarState.say("", "Added: " + r.title + (when ? " · " + when : ""), () => Todos.restore(before));
        }
        shown = false;
    }

    // The selected text (primary selection), else the clipboard
    Process {
        id: selProc
        command: ["bash", "-c", "t=$(wl-paste --primary --no-newline 2>/dev/null); [ -n \"$t\" ] || t=$(wl-paste --no-newline 2>/dev/null); printf '%s' \"$t\" | head -c 400"]
        stdout: StdioCollector { onStreamFinished: root.open(text.replace(/\s+/g, " ").trim(), "") }
    }
}
