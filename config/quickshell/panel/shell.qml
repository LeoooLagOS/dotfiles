//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

// Modular side panel. Tabs, zones and their layout are in common/Config.qml.
// Toggle: qs -c panel ipc call panel toggle   (bound to SUPER ALT + N)
// Also the notification daemon (services/Notifs.qml) and its popups.

import QtQuick
import Quickshell
import Quickshell.Io
import "./common"
import "./services"

ShellRoot {
    // Services that must run from the start (not only once a zone uses them)
    readonly property var services: [SystemSettings, Toggles, LauncherTheme]

    Panel {}
    NotificationPopups {}
    CommsDock {}

    IpcHandler {
        target: "panel"

        function toggle(): void { PanelState.open = !PanelState.open; }
        function open(): void { PanelState.open = true; }
        function close(): void { PanelState.open = false; }
        // Open on a tab by name, e.g. `qs -c panel ipc call panel tab Weather`
        // (not named "show": that clashes with the `qs ipc show` subcommand)
        function toggleDnd(): void { Notifs.toggleDnd(); }
        function currentTab(): string { return PanelState.open ? Config.tabs[PanelState.tab].name : ""; }
        function clearNotifications(): void { Notifs.clearAll(); }
        // Open a tab with one zone highlighted, e.g. `zone Controls SystemZone`
        function zone(tabName: string, zoneName: string): void { PanelState.open = true; PanelState.goTo(tabName, zoneName); }
        // Change a setting (value as JSON), e.g. `setting dim 600`, `setting mode '"light"'`
        function setting(key: string, value: string): string {
            if (!(key in Settings.defaults)) return "unknown setting: " + key;
            try { Settings.set(key, JSON.parse(value)); } catch (e) { return "value must be JSON"; }
            return JSON.stringify(Settings.v[key]);
        }
        function getSetting(key: string): string { return JSON.stringify(Settings.v[key]); }
        // Open Settings, optionally on a section, e.g. `settings power`
        function settings(section: string): void { PanelState.open = true; PanelState.openSettings(section); }
        // Screen recording start / stop (SUPER ALT Print), services/Recorder.qml
        function record(): string {
            if (!Recorder.installed) { Recorder.checkInstalled(); return "gpu-screen-recorder is not installed"; }
            Recorder.toggle();
            return Recorder.recording ? "stopping" : "starting";
        }
        // Radio on/off (the Media tab's radio view; services/Radio.qml)
        function radio(): string { Radio.toggle(); return Radio.active ? "stopping" : "playing " + (Radio.current?.name ?? ""); }
        // WhatsApp / Thunderbird with the dock, show / hide (SUPER Y; services/Comms.qml)
        function comms(): void { Comms.toggle(); }
        // Caffeine on/off (SUPER ALT I)
        function caffeine(): string { Toggles.setCaffeine(!Toggles.caffeine, 0); return Toggles.caffeine ? "on" : "off"; }
        // Colors: `themeMode light|dark|system`, `toggleInverted`, `currentTheme`
        function themeMode(mode: string): void { if (["system", "dark", "light"].includes(mode)) Theme.setMode(mode); }
        function toggleInverted(): void { Theme.setInverted(!Theme.chosenInverted); }
        function currentTheme(): string { return (Theme.chosenLight ? "light" : "dark") + (Theme.chosenInverted ? " inverted" : "") + " (" + Theme.modeSetting + ", " + Theme.scope + ")"; }
        // Keybinds (SUPER SHIFT + letter): open on that tab, or close if it's the one shown
        function tabToggle(name: string): void {
            const i = Config.tabs.findIndex(t => t.name.toLowerCase() === name.toLowerCase());
            if (PanelState.open && i === PanelState.tab) PanelState.open = false;
            else tab(name);
        }
        function tab(name: string): void {
            const i = Config.tabs.findIndex(t => t.name.toLowerCase() === name.toLowerCase());
            PanelState.open = true;
            if (i >= 0) PanelState.tab = i;
        }
    }
}
