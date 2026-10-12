pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import "../common"

// The notification daemon (replaces swaync): receives every notification,
// keeps the history, shows popups (unless Do Not Disturb) and tells waybar
// about the count / DND state.
Singleton {
    id: root

    property bool dnd: false
    // Do Not Disturb with an end: a Date, or null = until turned off
    property var dndUntil: null
    property bool dndScheduled: false       // turned on by the quiet-hours schedule
    property var popups: []                 // notifications currently shown as popups
    property var received: ({})             // notification id → Date received
    property int replying: 0                // cards with the reply box open (popups take the keyboard)
    property var replyingId: null           // the notification whose reply box was opened last

    // Newest first: the live ones and the copies of replaced ones (archive)
    readonly property var list: {
        const live = server.trackedNotifications.values.slice().reverse();
        if (!archive.length) return live;
        const t = n => received[n.id]?.getTime() ?? 0;
        return live.concat(archive).sort((a, b) => t(b) - t(a));
    }

    // --- Replaced notifications ---
    // Some apps reuse one notification and replace its text (WhatsApp in Brave:
    // one per chat, or one for all). The server updates it in place, so the
    // earlier message would vanish and the new one wouldn't pop up. Instead the
    // earlier text stays in the history as a plain copy (no actions), and the
    // new one arrives like a new notification.
    property var archive: []                // copies, any order (list sorts them)
    property int archiveSeq: 0
    property var lastContent: ({})          // id → { summary, body, image } as last seen
    function contentOf(n) { return { summary: n.summary, body: n.body, image: n.image }; }
    function watchContent(n) {
        const c = Object.assign({}, lastContent);
        c[n.id] = contentOf(n);
        lastContent = c;
        const changed = () => Qt.callLater(root.replaced, n);
        n.summaryChanged.connect(changed);
        n.bodyChanged.connect(changed);
    }
    function replaced(n) {
        const before = lastContent[n.id];
        if (!before || !n.tracked || (before.summary === n.summary && before.body === n.body)) return;
        const keep = !syncTag(n) && progressOf(n) < 0;      // not volume bars, progress…
        if (keep) {
            const o = { id: "a" + (++archiveSeq), archived: true, appName: n.appName, appIcon: n.appIcon,
                        desktopEntry: n.desktopEntry, summary: before.summary, body: before.body, image: before.image,
                        urgency: n.urgency, hints: n.hints, actions: [], transient: false, tracked: true,
                        hasInlineReply: false, inlineReplyPlaceholder: "" };
            o.dismiss = () => { root.archive = root.archive.filter(x => x !== o); };
            o.expire = o.dismiss;
            const r = Object.assign({}, received);
            r[o.id] = received[n.id];
            r[n.id] = new Date();
            received = r;
            archive = archive.concat([o]);
        }
        const c = Object.assign({}, lastContent);
        c[n.id] = contentOf(n);
        lastContent = c;
        if (keep) arrive(n);
    }
    readonly property int count: list.length

    // Popup durations (ms): Settings → Notifications (0 = until dismissed);
    // low urgency stays half as long, critical 30 s
    function timeoutFor(n) {
        if (n.urgency === NotificationUrgency.Critical) return 30000;
        const k = placeKind(n);
        if (k === "level") return 1800;                           // just feedback
        if (k === "call" || k === "reminder") return 0;           // until answered / dismissed
        if (k === "security") return 30000;                       // time to read / copy the code
        const s = Settings.v.popupSecs * 1000;
        if (s === 0) return 0;
        return n.urgency === NotificationUrgency.Low ? Math.max(2000, s / 2) : s;
    }

    function timeAgo(n) {
        const t = n ? received[n.id] : null;
        if (!t) return "";
        const s = Math.floor((clock.date - t) / 1000);
        if (s < 60) return "now";
        if (s < 3600) return Math.floor(s / 60) + "m";
        if (s < 86400) return Math.floor(s / 3600) + "h";
        return Qt.formatDate(t, "MMM d");
    }

    // --- Classify / search / sort (Notifications tab) ---

    // Apps treated as messaging, besides the "im.*" / "email.*" categories
    readonly property var messagingApps: ["discord", "vesktop", "telegram", "whatsapp", "signal", "slack",
                                          "element", "teams", "thunderbird", "evolution", "geary", "mail",
                                          "zapzap", "wasistlos", "whatsie", "caprine", "ferdium", "outlook", "gmail"]

    // --- Web apps ---
    // A site's notification comes from the browser ("Brave", "Firefox").
    // Chromium browsers put the site in the body (a link, or a first line with
    // the host); the known ones are recognized by that host: name, type, and
    // the body without it. appLabel(n) is what the panel shows and what rules
    // (Per app), grouping and the tab's app filter use.
    readonly property var webServices: [
        // Any *.whatsapp.com: the installed app runs on web-fallback.whatsapp.com
        { hosts: ["whatsapp.com"], name: "WhatsApp", kind: "message" },
        { hosts: ["teams.microsoft.com", "teams.live.com", "teams.cloud.microsoft"], name: "Teams", kind: "message" },
        { hosts: ["outlook.office.com", "outlook.office365.com", "outlook.live.com", "outlook.cloud.microsoft"], name: "Outlook", kind: "message" },
        { hosts: ["mail.google.com"], name: "Gmail", kind: "message" },
        { hosts: ["chat.google.com"], name: "Google Chat", kind: "message" },
        { hosts: ["meet.google.com"], name: "Google Meet", kind: "message" },
        { hosts: ["calendar.google.com"], name: "Google Calendar", kind: "reminder" },
        { hosts: ["messenger.com", "facebook.com"], name: "Messenger", kind: "message" },
        { hosts: ["instagram.com"], name: "Instagram", kind: "message" },
        { hosts: ["web.telegram.org"], name: "Telegram", kind: "message" },
        { hosts: ["discord.com"], name: "Discord", kind: "message" },
        { hosts: ["app.slack.com"], name: "Slack", kind: "message" },
        { hosts: ["music.youtube.com", "open.spotify.com"], name: "Music", kind: "media" }
    ]
    readonly property var browsers: ["brave", "firefox", "chrom", "edge", "vivaldi", "opera", "epiphany", "web", "zen", "librewolf"]
    // The site a browser notification comes from ("web.whatsapp.com"), or ""
    function originOf(n) {
        if (!n) return "";
        const app = ((n.appName || "") + " " + (n.desktopEntry || "")).toLowerCase();
        if (!browsers.some(b => app.includes(b))) return "";
        const m = /(?:https?:\/\/)?((?:[a-z0-9-]+\.)+[a-z]{2,})/i.exec(String(n.body ?? ""));
        return m ? m[1].toLowerCase() : "";
    }
    function webService(n) {
        const host = originOf(n);
        if (host) return webServices.find(s => s.hosts.some(h => host === h || host.endsWith("." + h))) ?? null;
        // An installed web app may send under its own name ("WhatsApp Web")
        const app = (n?.appName || "").toLowerCase();
        return app ? webServices.find(s => app.startsWith(s.name.toLowerCase())) ?? null : null;
    }

    // Icons of the web apps installed from Brave / Chromium (their launchers in
    // ~/.local/share/applications: Name, Icon, file), so a WhatsApp notification
    // shows WhatsApp's icon and not the browser's. Re-read every few minutes.
    property var webApps: []                   // [{ name, icon, entry }]
    function webAppIcon(n) {
        if (!n) return "";
        const entry = String(n.desktopEntry || "");
        let a = webApps.find(w => entry && w.entry === entry);
        const ws = a ? null : webService(n);
        if (!a && ws) a = webApps.find(w => w.name.toLowerCase().startsWith(ws.name.toLowerCase()));
        return a?.icon ?? "";
    }
    Process {
        id: webAppsProc
        running: true
        command: ["bash", "-c", "for f in \"$HOME\"/.local/share/applications/*flextop*.desktop \"$HOME\"/.local/share/applications/chrome-*.desktop; do [ -f \"$f\" ] || continue; "
                  // Brave's Icon= may point inside its sandbox to a file that isn't
                  // there; then use the name, found in ~/.local/share/icons (hicolor)
                  + "i=$(grep -m1 '^Icon=' \"$f\" | cut -d= -f2-); case $i in /*) [ -f \"$i\" ] || i=$(basename \"${i%.*}\");; esac; "
                  + "printf '%s\\t%s\\t%s\\n' \"$(grep -m1 '^Name=' \"$f\" | cut -d= -f2-)\" \"$i\" \"$(basename \"$f\" .desktop)\"; done"]
        stdout: StdioCollector {
            onStreamFinished: root.webApps = text.split("\n").filter(l => l).map(l => {
                const [name, icon, entry] = l.split("\t");
                return { name: name, icon: icon && icon.startsWith("/") ? "file://" + icon : icon, entry: entry };
            })
        }
    }
    Timer { interval: 300000; repeat: true; running: true; onTriggered: webAppsProc.running = true }
    function appLabel(n) { return webService(n)?.name ?? (n?.appName || "Other"); }

    // --- Email (Thunderbird) ---
    // Thunderbird says "<account> received 12 new messages" / "<Subject> from
    // "<Sender>"". Shown as: sender (title), subject (body), the account above,
    // "12 new"; one card per account (the conversation key).
    function mailOf(n) {
        if (!n || !/thunderbird/i.test((n.appName || "") + (n.desktopEntry || ""))) return null;
        const s = /^(.+?) received (\d+) new messages?$/.exec(plain(n.summary).trim());
        if (!s) return null;
        const b = /^([\s\S]*?)\s+from\s+"?([^"]+?)"?\s*$/.exec(plain(n.body).trim());
        return { account: s[1], count: +s[2], subject: b ? b[1] : plain(n.body).trim(), sender: b ? b[2] : "" };
    }
    // What the card shows: title, a small line above it, and how many it stands for
    function titleOf(n) { const m = mailOf(n); return m ? (m.sender || m.account) : (n?.summary || appLabel(n)); }
    function contextOf(n) { const m = mailOf(n); return m ? m.account : ""; }
    function countOf(n) { const m = mailOf(n); return Math.max(m ? m.count : 1, groupCount[n?.id] ?? 1); }
    function conversationOf(n) {
        const m = mailOf(n);
        return m ? "mail|" + m.account : appLabel(n) + "|" + plain(n?.summary).trim();
    }
    // The body without the site line Chromium adds ("<a href=…>web.whatsapp.com</a>\n\n…")
    function bodyOf(n) {
        const mail = mailOf(n);
        if (mail) return mail.subject;
        const b = String(n?.body ?? "");
        if (!webService(n)) return b;                 // only for the known sites
        return b.replace(/^\s*(<a [^>]*>[^<]*<\/a>|(?:https?:\/\/)?(?:[a-z0-9-]+\.)+[a-z]{2,}\/?)\s*(\n|<br\s*\/?>)*/i, "");
    }
    readonly property var systemApps: ["notify-send", "networkmanager", "nm-applet", "blueman", "battery",
                                       "udiskie", "power", "system", "hyprland", "swappy", "grim",
                                       "screen recording", "screenshot", "hyprsunset", "tuned", "dnf", "packagekit"]
    readonly property var mediaApps: ["spotify", "mpv", "vlc", "rhythmbox", "elisa", "amberol", "cider", "tidal",
                                      "strawberry", "lollypop", "clementine", "audacious", "celluloid", "youtube music",
                                      "spot", "g4music", "gapless", "quod libet", "deadbeef", "ncspot", "spotify-player"]

    // "critical" | "message" | "system" | "app"
    function kind(n) {
        if (n.urgency === NotificationUrgency.Critical) return "critical";
        if (webService(n)?.kind === "message") return "message";
        const cat = String(n.hints?.category ?? "").toLowerCase();
        const app = appLabel(n).toLowerCase();
        if (cat.startsWith("im") || cat.startsWith("email") || messagingApps.some(a => app.includes(a))) return "message";
        if (cat.startsWith("device") || cat.startsWith("network") || systemApps.some(a => app.includes(a))) return "system";
        return "app";
    }

    function plain(s) { return String(s ?? "").replace(/<[^>]*>/g, ""); }

    function matches(n, query) {
        if (!query) return true;
        const q = query.toLowerCase();
        return [appLabel(n), n.summary, plain(n.body)].some(t => String(t ?? "").toLowerCase().includes(q));
    }

    // filter: "all" | "critical" | "message" | "system" | "app" | "app:<name>"
    function select(filter, query, sort) {
        let out = list.filter(n => matches(n, query) && (
            filter === "all" ? true
            : filter.startsWith("app:") ? appLabel(n) === filter.slice(4)
            : kind(n) === filter));
        const t = n => received[n.id]?.getTime() ?? 0;
        const rank = n => n.urgency === NotificationUrgency.Critical ? 0 : n.urgency === NotificationUrgency.Normal ? 1 : 2;
        if (sort === "oldest") out.sort((a, b) => t(a) - t(b));
        else if (sort === "app") out.sort((a, b) => appLabel(a).localeCompare(appLabel(b)) || t(b) - t(a));
        else if (sort === "urgency") out.sort((a, b) => rank(a) - rank(b) || t(b) - t(a));
        else out.sort((a, b) => t(b) - t(a));
        return out;
    }

    readonly property var apps: [...new Set(list.map(n => appLabel(n)))].sort()

    // --- Where popups appear (Settings → Notifications → Where popups appear) ---
    // Finer than kind() (the Notifications tab's filter), first match wins:
    //   call      incoming call (category call.*, "incoming call" / "llamada entrante")
    //   critical  urgency critical
    //   security  2FA / login codes, sign-in alerts, polkit, password managers
    //   level     sync tag + value hint (volume, brightness)
    //   progress  value hint without a sync tag (downloads, copies, updates)
    //   reminder  category calendar.* / reminder apps (services/Events.qml sends these)
    //   media     now playing (category x-gnome.music, mediaApps)
    //   message · system · app   from kind()
    readonly property var securityApps: ["polkit", "1password", "bitwarden", "keepassxc", "proton pass", "authenticator",
                                         "authy", "gnome-keyring", "kwallet", "seahorse"]
    readonly property var reminderApps: ["calendar", "evolution-alarm", "reminder", "korganizer", "todo", "planify", "errands"]
    function textOf(n) { return plain((n.summary ?? "") + " " + bodyOf(n)); }
    function isCall(n) {
        const cat = String(n.hints?.category ?? "").toLowerCase();
        return cat.startsWith("call") || /\b(incoming (video |voice )?call|(video)?llamada entrante|is calling( you)?|te est[aá] llamando|calling you)\b/i.test(textOf(n));
    }
    // A 4–8 digit code in a security notification ("Your code is 482913")
    function codeOf(n) {
        const m = /\b(\d{4,8})\b/.exec(textOf(n));
        return m ? m[1] : "";
    }
    function isSecurity(n) {
        const app = ((n.appName || "") + " " + (n.desktopEntry || "")).toLowerCase();
        if (securityApps.some(a => app.includes(a))) return true;
        const t = textOf(n);
        if (/\b(verification|verify|security|2fa|two-factor|otp|one-time|passcode|c[oó]digo|code|pin)\b/i.test(t) && codeOf(n)) return true;
        return /(new (sign-?in|login)|nuevo inicio de sesi[oó]n|authentication required|autenticaci[oó]n requerida)/i.test(t);
    }
    function placeKind(n) {
        if (isCall(n)) return "call";
        if (n.urgency === NotificationUrgency.Critical) return "critical";
        if (isSecurity(n)) return "security";
        const tagged = !!syncTag(n), valued = progressOf(n) >= 0;
        if (tagged && valued) return "level";
        if (valued) return "progress";
        const cat = String(n.hints?.category ?? "").toLowerCase();
        const app = ((n.appName || "") + " " + (n.desktopEntry || "")).toLowerCase();
        const web = webService(n);
        if (web && web.kind !== "message") return web.kind;
        if (cat.startsWith("calendar") || cat.startsWith("x-calendar") || reminderApps.some(a => app.includes(a))) return "reminder";
        if (cat.startsWith("x-gnome.music") || mediaApps.some(a => app.includes(a))) return "media";
        const k = kind(n);
        return k === "message" || k === "system" ? k : "app";
    }

    // Per-app rules (Settings → Notifications → Per app): appName → a place,
    // "off" (history only) or "mute" (dropped, not even in the history).
    // They don't apply to critical notifications or calls.
    function ruleOf(n) {
        const r = (Settings.v.appRules ?? {})[appLabel(n)];
        return r && r !== "default" ? r : "";
    }
    // "top" | "top-left" | "top-right" | "bottom-right" | "bottom" | "off"; critical: always top center
    function placeOf(n) {
        const k = placeKind(n);
        if (k === "critical") return "top";
        const rule = ruleOf(n);
        if (rule && rule !== "mute" && k !== "call") return rule;
        return Settings.v["pos" + k[0].toUpperCase() + k.slice(1)] ?? "top";
    }

    // --- Messages grouped by conversation ---
    // A message from the same app and sender/chat (summary) as one on screen
    // takes its card, which counts them ("3 messages"); all stay in the history.
    property var groupCount: ({})              // notification id → messages in its card
    function sameConversation(a, b) {
        return a !== b && placeKind(a) === "message" && conversationOf(a) === conversationOf(b);
    }
    // Shown below the panel while it is open (the rest wait until it closes)
    readonly property var importantKinds: ["critical", "call", "security", "reminder"]
    function important(n) { return importantKinds.includes(placeKind(n)); }
    // Popups of one place, newest last, at most Settings → At most per place.
    // "under-panel": the important ones, while the panel is open
    function popupsAt(place) {
        const out = place === "under-panel" ? popups.filter(n => important(n)) : popups.filter(n => placeOf(n) === place);
        return out.slice(Math.max(0, out.length - Settings.v.maxPopups));
    }

    // --- Level notifications (volume, brightness…) ---
    // A "synchronous" tag (x-canonical-private-synchronous, the same as dunst /
    // swaync) makes a new notification replace the previous one with that tag,
    // in place, instead of stacking. With an int `value` hint (0–100, more when
    // boosted) the card is a compact level: icon, bar, percentage.
    function syncTag(n) {
        const h = n?.hints ?? {};
        return String(h["x-canonical-private-synchronous"] ?? h["synchronous"] ?? h["x-dunst-stack-tag"] ?? "");
    }
    // notification id → the level of the one it replaced, so its bar animates from there
    property var levelFrom: ({})
    function progressOf(n) {
        const v = n?.hints?.value;
        return v === undefined || v === null || v === "" ? -1 : Number(v);
    }

    function removePopup(n) {
        popups = popups.filter(p => p !== n);
        // Transient and level notifications are not kept in the history
        if (n && (n.transient || syncTag(n))) n.expire();
    }
    function dismiss(n) { n.dismiss(); }
    function clearAll() { for (const n of list.slice()) n.dismiss(); }
    function toggleDnd() { setDnd(!dnd, null); }
    // until: Date or null (until turned off)
    function setDnd(on, until) {
        dndUntil = on ? until : null;
        dndScheduled = false;
        dnd = on;
    }
    // "For 1 hour" / "Until tomorrow" (07:00) / null
    function dndFor(what) {
        const d = new Date();
        if (what === "1h") d.setHours(d.getHours() + 1);
        else if (what === "tomorrow") { d.setDate(d.getDate() + 1); d.setHours(7, 0, 0, 0); }
        else return setDnd(true, null);
        setDnd(true, d);
    }
    readonly property string dndStatus: !dnd ? "Off"
        : dndScheduled ? "Quiet hours"
        : dndUntil ? "Until " + Qt.formatTime(dndUntil, "HH:mm") + (dndUntil.getDate() !== clock.date.getDate() ? " tomorrow" : "")
        : "Until turned off"

    // Every minute: end a timed DND, and follow the quiet-hours schedule
    function inQuietHours(now) {
        const [from, to] = Settings.v.dndWindow.split("-").map(t => { const [h, m] = t.split(":"); return +h * 60 + +m; });
        const m = now.getHours() * 60 + now.getMinutes();
        return from <= to ? (m >= from && m < to) : (m >= from || m < to);
    }
    function tick() {
        const now = clock.date;
        if (dnd && dndUntil && now >= dndUntil) setDnd(false, null);
        const quiet = Settings.v.dndSched && inQuietHours(now);
        if (quiet && !dnd) { dnd = true; dndScheduled = true; dndUntil = null; }
        else if (!quiet && dnd && dndScheduled) { dnd = false; dndScheduled = false; }
    }
    Connections {
        target: Settings
        function onChanged(key) { if (key === "dndSched" || key === "dndWindow") root.tick(); }
    }

    NotificationServer {
        id: server
        keepOnReload: true
        persistenceSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        bodyHyperlinksSupported: true
        actionsSupported: true
        inlineReplySupported: true
        imageSupported: true

        onNotification: n => {
            n.tracked = true;
            const r = Object.assign({}, root.received);
            r[n.id] = new Date();
            root.received = r;
            root.watchContent(n);
            root.arrive(n);
        }
    }

    // A notification arrives (or a replaced one arrives again): popup or not
    function arrive(n) {
        {
            // Muted app: not even in the history
            if (root.ruleOf(n) === "mute" && root.placeKind(n) !== "critical" && root.placeKind(n) !== "call") {
                Qt.callLater(() => n.dismiss());
                return;
            }
            // Do Not Disturb lets through critical ones and calls (if allowed),
            // levels (feedback for a key you just pressed), security codes (you
            // asked for them) and SWAYNC_BYPASS_DND
            const pk = root.placeKind(n);
            const critical = pk === "critical";
            const bypass = pk === "level" || pk === "security" || n.hints?.["SWAYNC_BYPASS_DND"] === true
                || (pk === "call" && Settings.v.callsThroughDnd);
            const shown = root.placeOf(n) !== "off"
                && (!root.dnd || bypass || (Settings.v.critical && critical));
            // Same tag as an earlier one: take its place (popup slot included)
            const tag = root.syncTag(n);
            if (tag) {
                const old = root.list.filter(o => o !== n && root.syncTag(o) === tag);
                const i = root.popups.findIndex(p => old.includes(p));
                if (i >= 0 && root.progressOf(root.popups[i]) >= 0) {
                    const m = {};                              // only the current one is needed
                    m[n.id] = root.progressOf(root.popups[i]);
                    root.levelFrom = m;
                }
                if (shown) {
                    const next = root.popups.slice();
                    if (i >= 0) next[i] = n; else next.push(n);
                    root.popups = next;
                } else if (i >= 0) root.popups = root.popups.filter(p => !old.includes(p));
                // Later: `list` doesn't have `n` yet, and closing the old ones now
                // would make onListChanged drop `n` from the popups too
                Qt.callLater(() => { for (const o of old) o.expire(); });
                return;
            }
            // Same conversation as a message on screen: take its card, count them
            if (shown && pk === "message" && Settings.v.groupMessages) {
                const i = root.popups.findIndex(p => root.sameConversation(p, n));
                if (i >= 0) {
                    const g = Object.assign({}, root.groupCount);
                    g[n.id] = (g[root.popups[i].id] ?? 1) + 1;
                    root.groupCount = g;
                    const next = root.popups.slice();
                    next.splice(i, 1);
                    next.push(n);                          // newest: nearest the edge
                    root.popups = next;
                    return;
                }
            }
            // Already on screen (replaced in place): count it, move it to the edge
            if (root.popups.includes(n)) {
                const g = Object.assign({}, root.groupCount);
                g[n.id] = (g[n.id] ?? 1) + 1;
                root.groupCount = g;
                root.popups = root.popups.filter(p => p !== n).concat([n]);
                return;
            }
            if (shown) root.popups = root.popups.concat([n]);
        }
    }

    // Drop closed notifications from the popup list, and the oldest ones beyond
    // the history limit (Settings → Notifications)
    onListChanged: {
        if (list.length > Settings.v.history) for (const n of list.slice(Settings.v.history)) n.dismiss();
        const alive = popups.filter(p => list.includes(p));
        if (alive.length !== popups.length) popups = alive;
    }

    // Ticks once a minute so "5m ago" labels update
    SystemClock { id: clock; precision: SystemClock.Minutes; onDateChanged: root.tick() }

    // --- Persist Do Not Disturb across restarts ---
    FileView {
        id: dndFile
        path: Quickshell.env("HOME") + "/.local/state/quickshell-panel/dnd"
        onLoaded: root.dnd = text().trim() === "1"
        onLoadFailed: root.dnd = false
    }
    onDndChanged: {
        Quickshell.execDetached(["bash", "-c",
            "mkdir -p ~/.local/state/quickshell-panel && echo " + (dnd ? 1 : 0) + " > ~/.local/state/quickshell-panel/dnd"]);
        waybarState.restart();
    }
    onCountChanged: waybarState.restart()

    // --- Waybar: write the state and signal the custom/swaync module ---
    Timer {
        id: waybarState
        interval: 100
        onTriggered: Quickshell.execDetached(["bash", "-c",
            "mkdir -p ~/.cache/quickshell-panel && printf '%s %s\\n' " + root.count + " " + (root.dnd ? 1 : 0)
            + " > ~/.cache/quickshell-panel/notifs && pkill -RTMIN+11 waybar"])
    }
    Component.onCompleted: waybarState.start()
}
