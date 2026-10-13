pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../common/When.js" as When

// To-do list: tasks and ideas, stored as JSON in ~/.config/lagos/todo.json
// (outside the repo, like the other personal data in ~/.config/lagos).
// Item: { id, text, kind: "task" | "idea", done, due: "YYYY-MM-DD" | "",
//         time: "HH:MM" | "" (due at that time, else at the end of the day),
//         repeat: "" | "daily" | "weekdays" | "weekly" | "monthly", place, created, doneAt }
// Completing a repeating one moves it to its next date instead. Completing and
// removing say so on the bar's island with an Undo (BarState.say).
Singleton {
    id: root
    property var items: []

    readonly property int openCount: items.filter(i => !i.done).length
    readonly property int doneCount: items.filter(i => i.done).length

    function save() {
        Quickshell.execDetached(["mkdir", "-p", Quickshell.env("HOME") + "/.config/lagos"]);
        file.setText(JSON.stringify(items, null, 2));
    }
    function update(fn) { items = fn(items.slice()); save(); }

    function add(text, kind, due, time, repeat, place) {
        text = (text || "").trim();
        if (!text) return "";
        const id = Date.now().toString(36) + Math.random().toString(36).slice(2, 6);
        update(list => list.concat([{
            id: id, text: text, kind: kind || "task", done: false, due: due || "",
            time: time || "", repeat: repeat || "", place: place || "",
            created: new Date().toISOString(), doneAt: ""
        }]));
        return id;
    }
    // Back to how the list was (Undo)
    function restore(snapshot) { items = snapshot; save(); }
    function toggle(id) {
        const before = items, it = items.find(i => i.id === id);
        if (!it) return;
        if (!it.done && it.repeat) {
            const next = When.nextDate(it.due, it.repeat);
            update(list => list.map(i => i.id === id ? Object.assign({}, i, { due: next }) : i));
            BarState.say("\uf01e", "Done · next " + When.dayWord(next).toLowerCase(), () => root.restore(before));
            return;
        }
        update(list => list.map(i => i.id === id
            ? Object.assign({}, i, { done: !i.done, doneAt: !i.done ? new Date().toISOString() : "" }) : i));
        if (!it.done) BarState.say("\uf00c", "Done: " + it.text, () => root.restore(before));
    }
    function setRepeat(id, repeat) {
        update(list => list.map(i => i.id === id ? Object.assign({}, i, { repeat: repeat || "",
                                                                       due: i.due || (repeat ? Events.key(new Date()) : "") }) : i));
    }
    function setDue(id, due, time) {
        update(list => list.map(i => i.id === id ? Object.assign({}, i, { due: due || "", time: due ? time || "" : "" }) : i));
    }
    function edit(id, text) {
        text = (text || "").trim();
        if (!text) return remove(id);
        update(list => list.map(i => i.id === id ? Object.assign({}, i, { text: text }) : i));
    }
    function setKind(id, kind) { update(list => list.map(i => i.id === id ? Object.assign({}, i, { kind: kind }) : i)); }
    function remove(id) {
        const before = items, it = items.find(i => i.id === id);
        update(list => list.filter(i => i.id !== id));
        if (it) BarState.say("\uf1f8", "Removed: " + it.text, () => root.restore(before));
    }
    function clearDone() { update(list => list.filter(i => !i.done)); }

    // Open items first (overdue/soonest due date first, then newest), done items last
    function sorted(filter) {
        return items
            .filter(i => filter === "all" || i.kind === filter)
            .slice()
            .sort((a, b) => (a.done - b.done)
                || ((a.due || "9999") < (b.due || "9999") ? -1 : (a.due || "9999") > (b.due || "9999") ? 1 : 0)
                || (b.created > a.created ? 1 : -1));
    }

    // Local date (toISOString would give the UTC date, a day ahead in the evening)
    function todayKey() {
        const d = new Date();
        return d.getFullYear() + "-" + String(d.getMonth() + 1).padStart(2, "0") + "-" + String(d.getDate()).padStart(2, "0");
    }
    function isOverdue(i) { return !i.done && !!i.due && dueAt(i) < new Date(); }
    // When it's due: its time, else the end of its day
    function dueAt(i) { return i.due ? new Date(i.due + "T" + (i.time || "23:59")) : null; }

    FileView {
        id: file
        path: Quickshell.env("HOME") + "/.config/lagos/todo.json"
        atomicWrites: true
        onLoaded: { try { root.items = JSON.parse(text()); } catch (e) { root.items = []; } }
        onLoadFailed: root.items = []
    }
}
