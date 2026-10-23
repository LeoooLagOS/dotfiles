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
    property var received: ({})             // notification id → Date received (written in place on arrival)

    // Newest first: the live ones and the copies of replaced ones (archive)
    readonly property var list: {
        if (clearing) return [];
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
    // While many are dismissed at once (Clear all), the list stays empty instead
    // of being rebuilt, with every view that reads it, after each one
    property bool clearing: false
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
        // Closed by the app itself (WhatsApp Web closes its own after a few
        // seconds): a message stays in the history as a copy
        n.closed.connect(reason => {
            if (reason === NotificationCloseReason.CloseRequested && root.placeKind(n) === "message" && !root.isTest(n))
                root.keepCopy(n, root.lastContent[n.id] ?? root.contentOf(n), root.received[n.id]);
        });
    }
    // A plain copy in the history (no actions), received at `when`
    function keepCopy(n, content, when) {
        const o = { id: "a" + (++archiveSeq), archived: true, appName: n.appName, appIcon: n.appIcon,
                    desktopEntry: n.desktopEntry, summary: content.summary, body: content.body, image: content.image,
                    urgency: n.urgency, hints: n.hints, actions: [], transient: false, tracked: true,
                    hasInlineReply: false, inlineReplyPlaceholder: "" };
        o.dismiss = () => { root.archive = root.archive.filter(x => x !== o); };
        o.expire = o.dismiss;
        const r = Object.assign({}, received);
        r[o.id] = when ?? new Date();
        received = r;
        archive = archive.concat([o]);
        return o;
    }
    function replaced(n) {
        const before = lastContent[n.id];
        if (!before || !n.tracked || (before.summary === n.summary && before.body === n.body)) return;
        const keep = !syncTag(n) && progressOf(n) < 0;      // not volume bars, progress…
        if (keep) {
            keepCopy(n, before, received[n.id]);
            const r = Object.assign({}, received);
            r[n.id] = new Date();
            received = r;
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
        if (s < 60) return Tr.t("now");
        if (s < 3600) return Math.floor(s / 60) + "m";
        if (s < 86400) return Math.floor(s / 3600) + "h";
        return Tr.date(t, "MMM d");
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
        // The icon theme's own for a known service ("whatsapp": the green one)
        // beats the tile the browser made from the site
        const svc = webService(n);
        const themed = svc ? svc.name.toLowerCase().split(" ")[0] : "";
        if (themed && Quickshell.hasThemeIcon(themed)) return themed;
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

    // The app's icon (a path or URL), or "": a web app's own (not the
    // browser's), else the notification's app icon or a theme icon that exists
    function appIconOf(n) {
        if (!n) return "";
        const web = webAppIcon(n);
        if (web) return web.startsWith("file://") || web.startsWith("/") ? web
                      : Quickshell.hasThemeIcon(web) ? Quickshell.iconPath(web) : "";
        const imgIcon = n.image ? String(n.image).slice("image://icon/".length) : "";
        if (n.appIcon && (n.appIcon.startsWith("/") || n.appIcon.includes("://"))) return n.appIcon;
        // Only theme icons that exist (iconPath alone returns a "missing" image)
        for (const name of [imgIcon, n.appIcon, n.desktopEntry, (n.appName || "").toLowerCase()])
            if (name && Quickshell.hasThemeIcon(name)) return Quickshell.iconPath(name);
        return "";
    }
    // The notification's picture (image hint), or "". Quickshell gives an
    // image-path hint as "image://icon/<it>": a file when <it> is a path, else
    // a theme icon's name, which isn't a picture
    function imageOf(n) {
        const img = String(n?.image ?? "");
        if (!img.startsWith("image://icon/")) return img;
        const rest = img.slice("image://icon/".length);
        return rest.startsWith("/") ? "file://" + rest : rest.startsWith("file://") ? rest : "";
    }
    // The chat's photo a message comes with, or "" (Settings → Notifications →
    // Picture on messages): the image hint (Telegram, Discord, Teams, Brave's
    // sites…), or a file Brave passes as app_icon
    function photoOf(n) {
        if (!n) return "";
        const img = imageOf(n);
        if (img) return img;
        const ic = String(n.appIcon || "");
        if (!originOf(n) && !webService(n)) return "";
        return ic.startsWith("/") ? "file://" + ic : ic.startsWith("file://") ? ic : "";
    }

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
    // A chat going on: messages of one conversation less than this apart are counted together in popups
    readonly property int chatWindow: 180000
    // The history's view of a chat: its messages, newest first (Settings → Group messages)
    function threadOf(n) {
        if (!n || !Settings.v.groupMessages || placeKind(n) !== "message" || mailOf(n)) return n ? [n] : [];
        const t = x => received[x.id]?.getTime() ?? 0;
        return list.filter(o => o === n || sameConversation(o, n)).sort((a, b) => t(b) - t(a));
    }
    function dismissThread(n) { dismissAll(threadOf(n)); }
    // Cards as a view shows them, each with the rest of its chat (a grouped
    // chat shows only its newest message)
    function dismissCards(ns) { dismissAll(ns.reduce((all, n) => all.concat(threadOf(n)), [])); }
    // Some may be gone already (the app closed the one clicked)
    function dismissAll(ns) {
        const all = ns.slice();
        clearing = true;
        for (const o of all) { try { o?.dismiss(); } catch (e) {} }
        clearing = false;
    }
    // Every message of n's chat (grouped or not), n included; [n] for the rest
    // (mail too: its "conversation" is the whole account)
    function chatOf(n) {
        if (!n || placeKind(n) !== "message" || mailOf(n)) return n ? [n] : [];
        return list.filter(o => o === n || sameConversation(o, n));
    }
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
        // One card per chat: its newest message stands for the rest (they show under it)
        const firstOfChat = n => {
            if (!Settings.v.groupMessages || placeKind(n) !== "message" || mailOf(n)) return true;
            const head = threadOf(n)[0];
            return head === n;
        };
        let out = list.filter(n => firstOfChat(n) && matches(n, query) && (
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
        let place = rule && rule !== "mute" && k !== "call" ? rule
            : k === "level" && /bright|backlight/i.test(syncTag(n) + " " + (n?.summary ?? "")) ? Settings.v.posBrightness
            : Settings.v["pos" + k[0].toUpperCase() + k.slice(1)];
        // The island only while the bar shows it; calls and security codes need their card's buttons
        if (place === "island" && (!BarState.islandOn || k === "call" || k === "security")) place = "top";
        return place ?? "top";
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

    // A level the panel shows itself (brightness keys, services/Brightness.qml):
    // no notification and no D-Bus round trip, just a card object in the
    // popups (shaped like the history's copies), so the bar shows on the same
    // frame as the key press. It takes the place of the one with its tag.
    property int localSeq: 0
    function showLevel(tag, title, value, body) {
        const o = { id: "l" + (++localSeq), local: true, appName: title, appIcon: "", desktopEntry: "",
                    summary: title, body: body ?? "", image: "", urgency: NotificationUrgency.Low,
                    hints: { "x-canonical-private-synchronous": tag, value: value },
                    actions: [], transient: true, tracked: true, hasInlineReply: false, inlineReplyPlaceholder: "" };
        o.dismiss = () => { root.popups = root.popups.filter(p => p !== o); };
        o.expire = o.dismiss;
        const place = placeOf(o);
        if (place === "off") return;
        if (place === "island") {
            const old = popups.find(p => syncTag(p) === tag);    // its popup, if it was one before
            if (old) removePopup(old);
            BarState.showLevel(o);
            return;
        }
        const i = popups.findIndex(p => syncTag(p) === tag);
        const next = popups.slice();
        if (i >= 0) {
            const old = popups[i];
            const m = {};                                  // its bar animates from the old level
            m[o.id] = progressOf(old);
            levelFrom = m;
            next[i] = o;
            if (!old.local) Qt.callLater(() => old.expire());
        } else next.push(o);
        popups = next;
    }

    // A level's icon (card and island): from the sync tag / summary (speaker by
    // level, mic, sun, keyboard); "" = use the notification's own icon
    function levelGlyph(n) {
        const what = (syncTag(n) + " " + (n?.summary ?? "")).toLowerCase();
        const level = progressOf(n);
        const off = level === 0 || /mute/i.test(n?.body ?? "");
        if (/mic/.test(what)) return off ? "\uf131" : "\uf130";
        if (/bright|screen|backlight|kbd|keyboard/.test(what)) return /kbd|keyboard/.test(what) ? "\uf11c" : "\uf185";
        if (/vol|audio|sound/.test(what)) return off ? "\u{f0581}" : level < 34 ? "\u{f057f}" : level < 67 ? "\u{f0580}" : "\u{f057e}";
        return "";
    }

    function removePopup(n) {
        popups = popups.filter(p => p !== n);
        // Transient and level notifications are not kept in the history
        if (n && (n.transient || syncTag(n))) n.expire();
    }
    function dismiss(n) { n.dismiss(); }

    // --- Test notifications (Settings → Demos) ---
    // scripts/wm/NotifDemo.sh is the one list: a kind alone, all at once, or all
    // paced for a video. Marked x-lagos-test: no quick reply, a click opens nothing.
    // The two people's names come from Settings → Demos
    readonly property var tests: [
        { id: "message", label: "Message" }, { id: "group", label: "Group chat" }, { id: "mail", label: "Mail" },
        { id: "call", label: "Call" }, { id: "reminder", label: "Reminder" }, { id: "code", label: "Security code" },
        { id: "volume", label: "Volume" }, { id: "brightness", label: "Brightness" }, { id: "progress", label: "Progress" },
        { id: "download", label: "Download" }, { id: "media", label: "Now playing" }, { id: "system", label: "System" },
        { id: "critical", label: "Critical" }
    ]
    function isTest(n) { return n?.hints?.["x-lagos-test"] === true; }
    function demo(args) {
        Quickshell.execDetached([Quickshell.env("HOME") + "/.config/hypr/scripts/NotifDemo.sh",
            "-x", Settings.v.demoPersonX || "Persona X", "-y", Settings.v.demoPersonY || "Persona Y"].concat(args));
    }
    function sendTest(id) { demo(["-w", "0", "-p", "0", "-k", id]); }
    function sendAllTests() { demo(["-w", "0", "-p", "0"]); }
    // Every kind in a row, paced for a video, after a 3 s countdown
    function runDemo() { demo(["-w", "3"]); }
    function clearAll() { dismissAll(list); }
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
    readonly property string dndStatus: !dnd ? Tr.t("Off")
        : dndScheduled ? Tr.t("Quiet hours")
        : dndUntil ? Tr.t(dndUntil.getDate() !== clock.date.getDate() ? "Until %1 tomorrow" : "Until %1", Qt.formatTime(dndUntil, "HH:mm"))
        : Tr.t("Until turned off")

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
            // Its time, written in place before it's tracked: the list built
            // for it reads it already, and replacing the whole object would
            // make every card and view that reads `received` evaluate again
            root.received[n.id] = new Date();
            n.tracked = true;
            root.watchContent(n);
            root.arrive(n);
        }
    }

    // A notification arrives (or a replaced one arrives again): popup or not
    function arrive(n) {
        // Teams' assignments to the calendar (services/Events.qml, scripts/assignments.py):
        // its notifications, and its mails as Thunderbird announces them
        if (!isTest(n)) {
            const mail = mailOf(n);
            if (mail ? /teams|assignments/i.test(mail.sender + " " + mail.account)
                     : /teams/i.test(appLabel(n) + " " + (n.appName || "") + " " + (n.desktopEntry || "")))
                Events.teamsNote(mail ? { app: "mail", summary: mail.sender, body: mail.subject, mail: true }
                                      : { app: appLabel(n), summary: plain(n.summary), body: plain(bodyOf(n)) });
        }
        {
            // Muted app: not even in the history
            if (root.ruleOf(n) === "mute" && root.placeKind(n) !== "critical" && root.placeKind(n) !== "call") {
                Qt.callLater(() => n.dismiss());
                return;
            }
            // Do Not Disturb lets through critical ones and calls (if allowed),
            // levels (feedback for a key you just pressed), security codes (you
            // asked for them), SWAYNC_BYPASS_DND, and finished downloads if allowed
            // (category transfer.complete, scripts/wm/DownloadWatch.py)
            const pk = root.placeKind(n);
            const critical = pk === "critical";
            const download = String(n.hints?.category ?? "").toLowerCase() === "transfer.complete";
            const bypass = pk === "level" || pk === "security" || n.hints?.["SWAYNC_BYPASS_DND"] === true
                || (pk === "call" && Settings.v.callsThroughDnd)
                || (download && Settings.v.downloadsThroughDnd);
            const shown = root.placeOf(n) !== "off"
                && (!root.dnd || bypass || (Settings.v.critical && critical));
            // Chat messages go to the bar's island instead of a popup (Settings →
            // Bar → Messages on the island); the history keeps them as usual
            if (shown && pk === "message" && !root.mailOf(n) && BarState.takesMessages) {
                BarState.showMessage(n);
                return;
            }
            // Placed on the island (Settings → Notifications → Where popups appear):
            // levels and progress as a bar, the rest like a message. A tagged one
            // takes the place of the earlier ones with its tag, as popups do
            if (shown && root.placeOf(n) === "island") {
                const tag = root.syncTag(n);
                if (tag) {
                    const old = root.list.filter(o => o !== n && root.syncTag(o) === tag);
                    root.popups = root.popups.filter(p => !old.includes(p));
                    Qt.callLater(() => { for (const o of old) o.expire(); });
                }
                if (pk === "level" || pk === "progress") BarState.showLevel(n);
                else BarState.showMessage(n);
                return;
            }
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
                // Not on screen anymore but recent (a chat going on): count those too
                const recent = root.list.filter(o => root.sameConversation(o, n)
                    && Date.now() - (root.received[o.id]?.getTime() ?? 0) < root.chatWindow).length;
                if (recent > 0) {
                    const g = Object.assign({}, root.groupCount);
                    g[n.id] = recent + 1;
                    root.groupCount = g;
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
        if (clearing) return;
        if (list.length > Settings.v.history) for (const n of list.slice(Settings.v.history)) n.dismiss();
        const alive = popups.filter(p => p.local || list.includes(p));
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
