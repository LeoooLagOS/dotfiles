pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

// The page in each browser window, any browser (scripts/weburl.py: Firefox
// and Chromium families, native or Flatpak), for the bar's window title and
// workspaces:
//   WebPages.of(toplevel)   { domain, icon (file URL or ""), title (the page's),
//                             search (a search results page), url }, or null
//                             (not a browser, a browser's own page, not found yet)
//   WebPages.iconOf(toplevel)  the site's icon to show for it, or "": the
//                             browser's own then (searches, sites without one)
// Looked up whenever a browser window's title changes. A page the browser
// hasn't saved yet (just opened) is tried again a few times.
Singleton {
    id: root

    property var pages: ({})                    // app id + "\n" + title → page, or false (none)
    property var queue: []                      // [{ k, id, title }]
    property string busy: ""
    property var tries: ({})                    // k → lookups that found nothing

    function appOf(t) { return String(t?.wayland?.appId ?? t?.lastIpcObject?.class ?? ""); }
    // A browser itself, not a site installed as an app (Brave's "brave-<id>-Default")
    function isBrowser(id) {
        return /firefox|librewolf|zen|floorp|waterfox|brave|chrome|chromium|vivaldi|edge|opera|thorium/i.test(id)
            && !/-[a-p]{32}-/.test(id);
    }
    function of(t) {
        if (!t || !isBrowser(appOf(t))) return null;
        return pages[appOf(t) + "\n" + String(t.title ?? "")] || null;
    }
    function iconOf(t) {
        const p = of(t);
        return p && p.icon && !p.search ? p.icon : "";
    }

    function want(t) {
        const id = appOf(t), title = String(t?.title ?? "");
        if (!isBrowser(id) || !title) return;
        const k = id + "\n" + title;
        if (k in pages || k === busy || queue.some(q => q.k === k)) return;
        queue = queue.concat([{ k: k, id: id, title: title }]);
        next();
    }
    function next() {
        if (busy || !queue.length) return;
        const q = queue[0];
        queue = queue.slice(1);
        busy = q.k;
        proc.asked = q;
        proc.command = ["python3", Quickshell.shellDir + "/scripts/weburl.py", q.id, q.title];
        proc.running = true;
    }
    function settle(q, page) {
        const o = Object.assign({}, pages);
        // Titles come and go (a video's, a chat's unread count): keep the last few hundred
        const keys = Object.keys(o);
        if (keys.length > 300) for (const k of keys.slice(0, 100)) delete o[k];
        if (page) o[q.k] = page;
        else {
            const n = (tries[q.k] ?? 0) + 1;
            tries[q.k] = n;
            if (n >= 4) o[q.k] = false;
            else again.push(q);
        }
        pages = o;
        busy = "";
        next();
    }

    Process {
        id: proc
        property var asked: null
        stdout: StdioCollector {
            onStreamFinished: {
                let d = null;
                try { d = JSON.parse(text); } catch (e) {}
                root.settle(proc.asked, d && d.domain ? {
                    domain: d.domain, url: d.url, title: d.title ?? "", search: !!d.search,
                    icon: d.icon ? "file://" + d.icon : ""
                } : null);
            }
        }
    }

    // Not found yet: Firefox saves its session every ~15 s, Chromium its history
    // every few seconds. Tried again while a window still shows that title.
    property var again: []
    Timer {
        interval: 5000
        repeat: true
        running: true
        onTriggered: {
            if (!root.again.length) return;
            const shown = new Set(Hyprland.toplevels.values.map(t => root.appOf(t) + "\n" + String(t.title ?? "")));
            const qs = root.again.filter(q => shown.has(q.k));
            root.again = [];
            for (const q of qs) if (!root.queue.some(x => x.k === q.k)) root.queue = root.queue.concat([q]);
            root.next();
        }
    }

    // Every window: looked up as it opens and as its title changes
    Instantiator {
        model: Hyprland.toplevels
        delegate: QtObject {
            required property var modelData
            readonly property string key: root.appOf(modelData) + "\n" + String(modelData?.title ?? "")
            onKeyChanged: root.want(modelData)
            Component.onCompleted: root.want(modelData)
        }
    }
}
