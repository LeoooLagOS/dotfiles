pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import "../common"
import "../common/When.js" as When

// Calendar events from scripts/events.py.
//   - month data: the month shown in the calendar (`year`, `month`)
//   - upcoming:   today → +7 days, independent of the month on screen; drives
//                 the agenda and the reminders
//   - reminders:  a notification `reminder` minutes before each event (15 for
//                 Outlook events, which are marked important → critical
//                 urgency; local events use the reminder chosen when created).
//                 Already-sent reminders are remembered across restarts.
//   - add / remove local events (panel.ics), refresh (forces an Outlook download)
//   - deadlines:  Teams assignments, the task providers' tasks (scripts/providers.py)
//                 and the to-dos, with their own reminders
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
                try { root.upcoming = JSON.parse(text).events; root.upcomingLoaded = true; root.checkReminders(); }
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
        // Teams' assignments first: assignSync reloads when it's done
        onTriggered: { if (!assignSync.running) assignSync.running = true; root.reloadProviders(); }
    }

    // ---------------- Task providers (scripts/providers.py) ----------------
    // Executables in ~/.config/lagos/providers/ that list tasks with a due
    // date (e.g. a notes vault): they join the deadlines as kind "provider";
    // done / undone go back to the provider, which writes it where it lives
    property var providerTasks: []
    property var providerErrors: []
    readonly property string providers: Quickshell.shellDir + "/scripts/providers.py"
    function reloadProviders() { if (!providerList.running) providerList.running = true; }
    Process {
        id: providerList
        command: ["python3", "-I", root.providers, "list"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const d = JSON.parse(text);
                    root.providerTasks = d.tasks;
                    root.providerErrors = d.errors;
                    for (const e of d.errors) console.warn("providers:", e);
                } catch (e) { console.warn("providers:", e, text.slice(0, 200)); }
            }
        }
    }
    function providerDone(x) {
        providerTasks = providerTasks.filter(t => !(t.source === x.source && t.id === x.id));
        providerMark("done", x, () => BarState.say("", Tr.t("Done: %1", x.title), () => providerMark("undone", x, null)));
    }
    function providerMark(action, x, onOk) {
        markComp.createObject(root, { onOk: onOk, command: ["python3", "-I", root.providers, action, x.source, x.id] }).running = true;
    }
    Component {
        id: markComp
        Process {
            property var onOk
            stdout: StdioCollector {
                onStreamFinished: {
                    let r = {};
                    try { r = JSON.parse(text); } catch (e) {}
                    if (r.ok) { if (onOk) onOk(); }
                    else BarState.say("", Tr.t("Not saved: %1", r.error ?? Tr.t("provider failed")));
                    root.reloadProviders();
                }
            }
            onExited: destroy()
        }
    }

    // ---------------- Teams assignments (scripts/assignments.py) ----------------
    // Written to ~/.config/lagos/calendars/Teams.ics, read like any local
    // calendar: from Microsoft Graph once signed in (`assignments.py login`; the
    // school has to allow it), and from Teams' notifications (teamsNote, called
    // by Notifs for Teams' notifications and mails). A note without a date
    // becomes a to-do. Synced (and old ones dropped) with every refresh
    readonly property string assignments: Quickshell.shellDir + "/scripts/assignments.py"
    Process {
        id: assignSync
        command: ["python3", "-I", root.assignments, "sync"]
        onExited: { if (!monthProc.running) root.reload(false); root.reloadUpcoming(false); }
        stderr: StdioCollector { onStreamFinished: if (text.trim()) console.info("assignments:", text.trim().slice(-200)) }
    }
    // Handed in (a note can't know): out of the calendar until Teams says otherwise
    function teamsDone(uid) {
        const e = upcoming.find(x => x.uid === uid);
        Quickshell.execDetached(["python3", "-I", root.assignments, "done", uid]);
        upcoming = upcoming.filter(x => x.uid !== uid);
        reloadSoon.restart();
        BarState.say("\uf00c", Tr.t("Handed in: %1", (e?.title ?? "").replace(/^Entrega:\s*/, "")), () => {
            undoProc.command = ["python3", "-I", root.assignments, "undone", uid];
            undoProc.running = true;
        });
    }
    Process { id: undoProc; onExited: { root.reload(false); root.reloadUpcoming(false); } }
    function teamsNote(n) {
        noteComp.createObject(root, { payload: JSON.stringify(n) }).running = true;
    }
    Component {
        id: noteComp
        Process {
            property string payload
            command: ["python3", "-I", root.assignments, "note"]
            stdinEnabled: true
            onRunningChanged: if (running) { write(payload); stdinEnabled = false; }
            stdout: StdioCollector {
                onStreamFinished: {
                    let r = {};
                    try { r = JSON.parse(text); } catch (e) {}
                    if (r.todo) {
                        if (!Todos.items.some(i => !i.done && i.text === r.todo)) Todos.add(r.todo, "task", "");
                        BarState.say("\uf0ae", Tr.t("To-do from Teams: %1", r.todo));
                    } else if (r.event) {
                        BarState.say("\uf073", Tr.t("Due %1: %2", Tr.date(new Date(r.due), "ddd d MMM HH:mm"), r.event));
                        if (!monthProc.running) root.reload(false);
                        root.reloadUpcoming(false);
                    }
                }
            }
            onExited: destroy()
        }
    }

    // ---------------- Deadlines: what has to be handed in ----------------
    // Teams assignments (the "Teams" calendar, scripts/assignments.py), the
    // providers' tasks (above) and the open to-do tasks (services/Todos.qml),
    // soonest first, overdue on top, the ones without a date last:
    //   [{ kind: "teams" | "provider" | "todo", uid / id, title, due: Date | null, dateOnly, where, important,
    //      provider: source, label, remind, open }]
    // dueText(d) / dueColor(d): "Today 23:59 · in 2 h 58 min" / red under a day, amber under three
    property date now: new Date()
    function isDeadline(e) { return e.calendar === "Teams"; }
    // The real start (startIso: an event past midnight is listed on both days)
    function startOf(e) { return e.startIso ? new Date(e.startIso) : new Date(e.date + "T" + (e.start || "00:00")); }
    function endOf(e) {
        if (e.allDay) return new Date(e.date + "T23:59:59");
        const start = startOf(e);
        const end = new Date(start);
        if (e.end) {
            const [h, m] = e.end.split(":");
            end.setHours(+h, +m, 0, 0);
            if (end < start) end.setDate(end.getDate() + 1);      // past midnight
        }
        return end;
    }
    function isOver(e) { return endOf(e) <= now; }
    function isNow(e) { return !e.allDay && startOf(e) <= now && !isOver(e); }
    // A day's events without the deadlines (they have their own list); today's
    // without the ones already over
    function dayEvents(d) {
        const today = key(d) === key(now);
        return eventsOn(d).filter(e => !isDeadline(e) && !(today && isOver(e)));
    }
    readonly property var deadlines: {
        const out = [];
        for (const e of upcoming)
            if (isDeadline(e)) out.push({ kind: "teams", uid: e.uid, title: e.title.replace(/^Entrega:\s*/, ""),
                                          due: new Date(e.startIso), dateOnly: false, where: e.location,
                                          important: !!e.important });
        for (const t of providerTasks) {
            const timed = t.due.length > 10;
            out.push({ kind: "provider", source: t.source, label: t.label, id: t.id, title: t.title,
                       due: t.due ? new Date(timed ? t.due : t.due + "T23:59") : null, dateOnly: !timed,
                       where: t.where, remind: t.remind, open: t.open });
        }
        for (const t of Todos.items)
            if (!t.done && t.kind !== "idea")
                out.push({ kind: "todo", id: t.id, title: t.text, due: Todos.dueAt(t),
                           dateOnly: !t.time, where: t.place || "", repeat: t.repeat || "" });
        const at = d => d.due ? d.due.getTime() : Number.MAX_SAFE_INTEGER;
        return out.sort((a, b) => at(a) - at(b));
    }
    function deadlinesOn(d) { return deadlines.filter(x => x.due && key(x.due) === key(d)); }
    function dayWord(d) {
        const t = new Date(now); t.setHours(0, 0, 0, 0);
        const x = new Date(d); x.setHours(0, 0, 0, 0);
        const diff = Math.round((x - t) / 86400000);
        return diff === 0 ? Tr.t("Today") : diff === 1 ? Tr.t("Tomorrow") : diff === -1 ? Tr.t("Yesterday")
             : diff > 0 && diff < 7 ? Tr.date(d, "dddd") : Tr.date(d, "ddd d MMM");
    }
    function dueText(x) {
        if (!x.due) return Tr.t("No date");
        const when = dayWord(x.due) + (x.dateOnly ? "" : " " + Qt.formatTime(x.due, "HH:mm"));
        const min = Math.round((x.due - now) / 60000);
        if (min < 0) return Tr.t("Overdue · %1", when);
        const left = min < 60 ? min + " min"
                   : min < 1440 ? Math.floor(min / 60) + " h" + (min % 60 ? " " + (min % 60) + " min" : "")
                   : Tr.t("%1 days", Math.round(min / 1440));
        return Tr.t("%1 · in %2", when, left);
    }
    function dueColor(x) {
        if (!x.due) return Theme.fgDim;
        const h = (x.due - now) / 3600000;
        return h < 24 ? Theme.bad : h < 72 ? Theme.warn : Theme.accent2;
    }
    // Done: a to-do is checked; a Teams one leaves the calendar; a provider's goes back to it
    function complete(x) {
        if (x.kind === "teams") teamsDone(x.uid);
        else if (x.kind === "provider") providerDone(x);
        else Todos.toggle(x.id);
    }

    // ---------------- Local events: add / remove ----------------
    // spec: { title, date "YYYY-MM-DD", start "HH:MM", end "HH:MM", allDay, location, notes, reminder,
    //         repeat: "" | "daily" | "weekdays" | "weekly" | "monthly" }
    // announce: say it on the island, with an Undo
    function add(spec, announce) {
        lastError = "";
        editProc.onSaved = announce ? (d => BarState.say("\uf073", Tr.t("Added: %1", spec.title) + " · " + When.dayWord(spec.date, null, Tr).toLowerCase()
                                                          + (spec.allDay ? "" : " " + spec.start),
                                                          () => root.remove(d.uid, true))) : null;
        run(editProc, ["add"], JSON.stringify(spec));
    }
    // A removed event can come back (Undo): the same fields, a new uid
    function remove(uid, quiet) {
        lastError = "";
        const e = upcoming.concat(...Object.values(byDate)).find(x => x.uid === uid);
        editProc.onSaved = quiet || !e ? null : (() => BarState.say("\uf1f8", Tr.t("Removed: %1", e.title), () => root.add({
            title: e.title, date: e.date, start: e.start, end: e.end, allDay: e.allDay,
            location: e.location, notes: e.notes, reminder: e.reminder }, false)));
        run(editProc, ["delete", uid]);
    }

    Process {
        id: editProc
        property string stdinPayload: ""
        property var onSaved: null
        stdinEnabled: true
        onRunningChanged: if (running && stdinPayload !== "") { write(stdinPayload + "\n"); stdinEnabled = false; }
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const d = JSON.parse(text);
                    if (!d.ok) root.lastError = d.error ?? Tr.t("Could not save the event");
                    else if (editProc.onSaved) editProc.onSaved(d);
                    editProc.onSaved = null;
                } catch (e) { root.lastError = String(e); }
                editProc.stdinEnabled = true;
                root.reload(false);
                root.reloadUpcoming(false);
            }
        }
    }

    // ---------------- Reminders ----------------
    // reminded.json: "uid|startIso" → true (events), "<deadline>|<dueIso>|<stage>"
    // → true (deadlines), "snooze|<deadline>|<dueIso>" → when to say it again,
    // "_brief" → the day the morning brief was sent
    property var reminded: ({})
    property bool remindedLoaded: false
    property bool upcomingLoaded: false

    FileView {
        id: remindedFile
        path: Quickshell.env("HOME") + "/.local/state/quickshell-panel/reminded.json"
        atomicWrites: true
        onLoaded: { try { root.reminded = JSON.parse(text()); } catch (e) { root.reminded = {}; } root.remindedLoaded = true; }
        onLoadFailed: { root.reminded = {}; root.remindedLoaded = true; }
    }
    function saveReminded(r) {
        // Forget reminders older than 2 days so the file stays small, but not
        // the ones of a deadline still listed (overdue: it'd be said again)
        const cutoff = Date.now() - 2 * 86400000;
        const live = new Set(deadlines.filter(x => x.due).map(x => deadlineKey(x)));
        for (const k of Object.keys(r)) {
            const p = k.split("|");
            const of = k.startsWith("snooze|") ? p[1] + "|" + p[2] : p[0] + "|" + p[1];
            if (new Date(p[k.startsWith("snooze|") ? 2 : 1]).getTime() < cutoff && !live.has(of)) delete r[k];
        }
        reminded = r;
        Quickshell.execDetached(["mkdir", "-p", Quickshell.env("HOME") + "/.local/state/quickshell-panel"]);
        remindedFile.setText(JSON.stringify(r));
    }

    // Events: `reminder` minutes before they start (not the deadlines: below)
    function checkReminders() {
        if (!remindedLoaded || !upcomingLoaded) return;
        const now = new Date();
        let changed = false;
        const r = Object.assign({}, reminded);
        for (const e of upcoming) {
            if (e.allDay || !e.startIso || !(e.reminder > 0) || isDeadline(e)) continue;
            const start = new Date(e.startIso);
            const k = e.uid + "|" + e.startIso;
            if (r[k] || now >= start) continue;
            if (now >= new Date(start.getTime() - e.reminder * 60000)) {
                notify(e, Math.max(1, Math.round((start - now) / 60000)));
                r[k] = true;
                changed = true;
            }
        }
        if (checkDeadlines(r)) changed = true;
        if (brief(r)) changed = true;
        if (changed) saveReminded(r);
    }

    function notify(e, mins) {
        const when = mins <= 1 ? Tr.t("now") : mins < 120 ? Tr.t("in %1 min", mins) : Tr.t("in %1 h", Math.round(mins / 60));
        const body = e.start + (e.end ? " – " + e.end : "") + (e.location ? " · " + e.location : "")
                   + (e.high ? "\n" + Tr.t("High importance") : "");
        Quickshell.execDetached(["notify-send",
            "-a", "Calendar", "-i", "x-office-calendar",
            "-u", e.important ? "critical" : "normal",
            "-c", "calendar.reminder",
            (e.important ? "★ " : "") + e.title + " · " + when, body]);
    }

    // ---------------- Deadline reminders ----------------
    // Each deadline is said at every stage it reaches (Settings → Weather &
    // calendar → Reminders: 3 days, 1 day, 3 h, 1 h before by default; one
    // reached while off is said once), and once more when it's overdue. Each
    // stays until answered (a reminder) with Done · In 1 h · Tomorrow (9:00).
    function deadlineKey(x) {
        const id = x.kind === "teams" ? x.uid : x.kind === "provider" ? x.source + ":" + x.id : "todo:" + x.id;
        return id + "|" + x.due.toISOString();
    }
    function checkDeadlines(r) {
        let changed = false;
        const stages = (Settings.v.dueStages ?? []).slice().sort((a, b) => b - a);
        for (const x of deadlines) {
            if (!x.due || x.remind === false) continue;
            const k = deadlineKey(x), left = (x.due - now) / 60000;
            const snooze = r["snooze|" + k];
            if (snooze) {
                if (now.getTime() >= snooze) { delete r["snooze|" + k]; dueNotify(x, k); changed = true; }
                continue;
            }
            if (left <= 0) {
                if (!r[k + "|over"]) { r[k + "|over"] = true; dueNotify(x, k); changed = true; }
                continue;
            }
            const reached = stages.filter(m => left <= m);
            if (!reached.length || r[k + "|" + reached[reached.length - 1]]) continue;
            for (const m of reached) r[k + "|" + m] = true;
            dueNotify(x, k);
            changed = true;
        }
        return changed;
    }
    function dueNotify(x, k) {
        const over = x.due <= now;
        // Important (High importance, `assignments.py add --important`): ★ and always critical
        const title = (x.important ? "★ " : "") + Tr.t(over ? "Overdue: %1" : "To hand in: %1", x.title);
        const body = dueText(x) + (x.where ? " · " + x.where : "");
        dueComp.createObject(root, { item: x, key: k, command: ["notify-send",
            "-a", x.kind === "teams" ? "Teams assignments" : x.kind === "provider" ? x.label : "To-do", "-i", "task-due",
            "-u", x.important || over || (x.due - now) <= 3600000 ? "critical" : "normal",
            "-c", "calendar.reminder",
            "-A", "done=" + Tr.t("Done"), "-A", "hour=" + Tr.t("In 1 h"), "-A", "tomorrow=" + Tr.t("Tomorrow"),
            title, body] }).running = true;
    }
    Component {
        id: dueComp
        Process {
            property var item
            property string key
            stdout: StdioCollector {
                onStreamFinished: {
                    const a = text.trim();
                    if (a === "done") root.complete(item);
                    else if (a === "hour" || a === "tomorrow") {
                        const t = new Date();
                        if (a === "hour") t.setHours(t.getHours() + 1);
                        else { t.setDate(t.getDate() + 1); t.setHours(9, 0, 0, 0); }
                        const r = Object.assign({}, root.reminded);
                        r["snooze|" + key] = t.getTime();
                        root.saveReminded(r);
                        BarState.say("\uf1f6", Tr.t(a === "hour" ? "Again in 1 h: %1" : "Again tomorrow 9:00: %1", item.title));
                    }
                }
            }
            onExited: destroy()
        }
    }

    // ---------------- While you were away ----------------
    // Every minute the panel notes it's alive; starting again, the events that
    // began meanwhile are listed in one notification
    FileView {
        id: aliveFile
        path: Quickshell.env("HOME") + "/.local/state/quickshell-panel/alive"
        preload: false
    }
    property real lastAlive: 0
    property bool aliveRead: false            // read before it's written again
    Process {
        running: true
        command: ["cat", Quickshell.env("HOME") + "/.local/state/quickshell-panel/alive"]
        stdout: StdioCollector { onStreamFinished: root.lastAlive = Number(text.trim()) || 0 }
        onExited: root.aliveRead = true
    }
    onLastAliveChanged: {
        if (!lastAlive || Date.now() - lastAlive < 180000) return;
        run(missedProc, ["list", key(new Date(lastAlive)), key(new Date())]);
    }
    Process {
        id: missedProc
        property string stdinPayload: ""
        stdout: StdioCollector {
            onStreamFinished: {
                let list = [];
                try { list = JSON.parse(text).events; } catch (e) { return; }
                const missed = list.filter(e => !e.allDay && !root.isDeadline(e) && e.startIso
                    && new Date(e.startIso).getTime() > root.lastAlive && new Date(e.startIso) <= new Date());
                if (!missed.length) return;
                const lines = missed.slice(0, 6).map(e => root.dayWord(new Date(e.startIso)) + " " + e.start + "  " + e.title);
                if (missed.length > 6) lines.push(Tr.t("…and %1 more", missed.length - 6));
                Quickshell.execDetached(["notify-send", "-a", "Calendar", "-i", "x-office-calendar", "-c", "calendar.reminder",
                    Tr.n(missed.length, "While you were away · %1 event", "While you were away · %1 events"), lines.join("\n")]);
            }
        }
    }
    Timer {
        interval: 60000
        running: root.aliveRead
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            Quickshell.execDetached(["mkdir", "-p", Quickshell.env("HOME") + "/.local/state/quickshell-panel"]);
            aliveFile.setText(String(Date.now()));
        }
    }

    // ---------------- Morning brief ----------------
    // Once a day, from Settings → Reminders → "Morning brief at" (or at the
    // first start after it): today's events, what's due, the open to-dos.
    // Open: the panel's Overview
    function brief(r) {
        if (!Settings.v.briefOn || r._brief === key(now) || now.getHours() < Settings.v.briefHour) return false;
        r._brief = key(now);
        const evs = upcoming.filter(e => e.date === key(now) && !isDeadline(e) && !isOver(e));
        const timed = evs.filter(e => !e.allDay);
        const dueToday = deadlines.filter(x => x.due && key(x.due) === key(now));
        const overdue = deadlines.filter(x => x.due && x.due < now);
        const open = deadlines.filter(x => x.kind === "todo" && (!x.due || key(x.due) > key(now)));
        const lines = [];
        if (timed.length) lines.push(Tr.n(timed.length, "%1 event · first %2", "%1 events · first %2", timed[0].start + " " + timed[0].title));
        for (const e of evs.filter(e => e.allDay)) lines.push(e.title);
        if (overdue.length) lines.push(Tr.t("Overdue: %1", overdue.map(x => x.title).join(", ")));
        for (const x of dueToday.filter(x => x.due >= now)) lines.push(Tr.t("Due %1 · %2", x.dateOnly ? Tr.t("today") : Qt.formatTime(x.due, "HH:mm"), x.title));
        if (open.length) lines.push(Tr.n(open.length, "%1 other to-do", "%1 other to-dos"));
        if (!lines.length) lines.push(Tr.t("Nothing planned"));
        briefProc.command = ["notify-send", "-a", "Calendar", "-i", "x-office-calendar", "-c", "calendar.reminder",
                             "-A", "open=" + Tr.t("Open"), Tr.t("Today · %1", Tr.date(now, "dddd d MMMM")), lines.join("\n")];
        briefProc.running = true;
        return true;
    }
    Process {
        id: briefProc
        stdout: StdioCollector {
            onStreamFinished: if (text.trim() === "open") { PanelState.open = true; PanelState.goTo("Overview", ""); }
        }
    }

    // ---------------- Coming up (the bar's left twin, bar/Agenda.qml) ----------------
    // The next event starting within Settings → Reminders → "Events on the
    // bar" minutes, or the most urgent deadline within "Deadlines on the bar"
    // hours (overdue ones always; not the quiet ones, remind: false): { icon, text, color }, or null
    readonly property var soon: {
        const evs = upcoming.filter(e => !isDeadline(e) && !e.allDay && startOf(e) > now
                                         && (startOf(e) - now) / 60000 <= Settings.v.soonEvent);
        const ev = evs.sort((a, b) => startOf(a) - startOf(b))[0];
        const dl = deadlines.find(x => x.due && x.remind !== false && (x.due <= now || (x.due - now) / 3600000 <= Settings.v.soonDue));
        const evMin = ev ? (startOf(ev) - now) / 60000 : Infinity;
        const dlMin = dl ? (dl.due - now) / 60000 : Infinity;
        if (ev && evMin <= dlMin)
            return { icon: "\uf073", color: Theme.accent2,
                     text: ev.title + " · " + (evMin < 1 ? Tr.t("now") : Tr.t("in %1 min", Math.round(evMin))) + (ev.location ? " · " + ev.location : "") };
        if (dl)
            return { icon: "\uf0ae", color: dueColor(dl),
                     text: dl.title + " · " + (dlMin <= 0 ? Tr.t("overdue") : dlMin < 60 ? Math.round(dlMin) + " min"
                                                : Math.floor(dlMin / 60) + " h" + (dlMin % 60 >= 1 ? " " + Math.round(dlMin % 60) + " min" : "")) };
        return null;
    }

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: { root.now = new Date(); root.checkReminders(); }
    }
}
