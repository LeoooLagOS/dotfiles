pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// The panel's language: the system's (LANG) unless Settings → Appearance →
// Language picks one. Text is written in English in the code and looked up in
// i18n/<lang>.json (English text → translation); a missing one stays English.
//   Tr.t("Clear all")                  text
//   Tr.t("Due %1", when)               %1, %2… replaced by the arguments
//   Tr.n(count, "%1 message", "%1 messages")   singular / plural
//   Tr.date(d, "ddd d MMM")            dates in the language (Qt.formatDate is always English)
//   Tr.cap(s)                          first letter uppercase
// Calling them in a binding makes it follow a change of language.
// Scripts read the same files (scripts/wm/lagos_i18n.py, lagos_i18n.sh).
Singleton {
    id: root

    readonly property var languages: [["en", "English"], ["es", "Español"]]
    readonly property string system: Qt.locale().name           // e.g. en_US, from LANG
    readonly property string lang: {
        const s = Settings.v.language;
        const l = s && s !== "system" ? s : system.slice(0, 2);
        return languages.some(o => o[0] === l) ? l : "en";
    }
    // Dates and numbers: the system's region when it speaks the chosen language
    readonly property var locale: Qt.locale(system.slice(0, 2) === lang ? system : ({ en: "en_US", es: "es_MX" })[lang])

    property var dict: ({})

    FileView {
        path: root.lang === "en" ? "" : Quickshell.shellDir + "/i18n/" + root.lang + ".json"
        watchChanges: true
        onFileChanged: reload()
        onLoaded: { try { root.dict = JSON.parse(text()); } catch (e) { root.dict = {}; } }
        onLoadFailed: root.dict = {}
    }

    function t(s, ...args) {
        let r = root.lang === "en" ? s : (root.dict[s] || s);
        for (let i = 0; i < args.length; i++) r = r.split("%" + (i + 1)).join(String(args[i]));
        return r;
    }
    function n(count, one, many, ...args) { return t(count === 1 ? one : many, count, ...args); }
    function date(d, format) { return d ? new Date(d).toLocaleString(root.locale, format) : ""; }
    // First letter up: Spanish names are lowercase ("jue", "octubre")
    function cap(s) { return s ? s[0].toUpperCase() + s.slice(1) : ""; }
}
