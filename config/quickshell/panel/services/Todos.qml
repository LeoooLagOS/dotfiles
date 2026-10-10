pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// To-do list: tasks and ideas, stored as JSON in ~/.config/lagos/todo.json
// (outside the repo, like the other personal data in ~/.config/lagos).
// Item: { id, text, kind: "task" | "idea", done, due: "YYYY-MM-DD" | "", created, doneAt }
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

    function add(text, kind, due) {
        text = (text || "").trim();
        if (!text) return;
        update(list => list.concat([{
            id: Date.now().toString(36) + Math.random().toString(36).slice(2, 6),
            text: text, kind: kind || "task", done: false, due: due || "",
            created: new Date().toISOString(), doneAt: ""
        }]));
    }
    function toggle(id) {
        update(list => list.map(i => i.id === id
            ? Object.assign({}, i, { done: !i.done, doneAt: !i.done ? new Date().toISOString() : "" }) : i));
    }
    function edit(id, text) {
        text = (text || "").trim();
        if (!text) return remove(id);
        update(list => list.map(i => i.id === id ? Object.assign({}, i, { text: text }) : i));
    }
    function setKind(id, kind) { update(list => list.map(i => i.id === id ? Object.assign({}, i, { kind: kind }) : i)); }
    function remove(id) { update(list => list.filter(i => i.id !== id)); }
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
    function isOverdue(i) { return !i.done && i.due && i.due < todayKey(); }

    FileView {
        id: file
        path: Quickshell.env("HOME") + "/.config/lagos/todo.json"
        atomicWrites: true
        onLoaded: { try { root.items = JSON.parse(text()); } catch (e) { root.items = []; } }
        onLoadFailed: root.items = []
    }
}
