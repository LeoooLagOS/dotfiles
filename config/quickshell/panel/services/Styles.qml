pragma Singleton

import QtQuick
import Quickshell
import "../common"

// Styles for the start menu (bar/StartMenu.qml): ready-made looks built only
// from settings that already exist, so picking one is the same as setting them
// by hand in Settings, and any other combination is simply "your own".
// A style as a file of tokens (shapes, fonts, animations) is ROADMAP Phase 6
// (Flavors_and_Styles); until then these are its first data.
// Light / dark is apart: it combines with any of them.
Singleton {
    id: root

    readonly property var presets: [
        { id: "islands", icon: "", name: Tr.t("Islands"), description: Tr.t("Each group floats, with glass and motion"),
          set: { barStyle: "islands", blur: true, animations: true } },
        { id: "classic", icon: "", name: Tr.t("Classic"), description: Tr.t("One bar across the top, like Windows"),
          set: { barStyle: "full", blur: true, animations: true } },
        { id: "floating", icon: "", name: Tr.t("Floating"), description: Tr.t("One bar that floats away from the edges"),
          set: { barStyle: "floating", blur: true, animations: true } },
        { id: "light", icon: "", name: Tr.t("Lightweight"), description: Tr.t("No glass or animations: less work for an old computer"),
          set: { barStyle: "full", blur: false, animations: false } }
    ]

    // The preset all of whose settings are the current ones, or null (your own)
    readonly property var current: presets.find(p => Object.keys(p.set).every(k => Settings.v[k] === p.set[k])) ?? null

    function apply(id) {
        const p = presets.find(x => x.id === id);
        if (!p) return;
        for (const k of Object.keys(p.set)) Settings.set(k, p.set[k]);
    }
}
