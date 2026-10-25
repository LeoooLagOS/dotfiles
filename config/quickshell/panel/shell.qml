//@ pragma UseQApplication
//@ pragma Env QT_QUICK_CONTROLS_STYLE=Basic

// Modular side panel. Tabs, zones and their layout are in common/Config.qml.
// Toggle: qs -c panel ipc call panel toggle   (bound to SUPER ALT + N)
// Also the notification daemon (services/Notifs.qml) and its popups.

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import "./common"
import "./services"

ShellRoot {
    // Services that must run from the start (not only once a zone uses them)
    readonly property var services: [SystemSettings, Toggles, LauncherTheme, Charger]

    TopBar {}
    Panel {}
    NotificationPopups {}
    CommsDock {}
    ReplyBox {}
    QuickAdd {}

    // Brightness and volume keys, straight from Hyprland (bind → hl.dsp.global):
    // no script and no notification in between, so the bar follows the key at once
    GlobalShortcut { name: "brightnessUp"; description: "Brightness up"; onPressed: Brightness.step(10) }
    GlobalShortcut { name: "brightnessDown"; description: "Brightness down"; onPressed: Brightness.step(-10) }
    // Volume keys the same way (services/Audio.qml)
    GlobalShortcut { name: "volumeUp"; description: "Volume up"; onPressed: Audio.stepVolume(5) }
    GlobalShortcut { name: "volumeDown"; description: "Volume down"; onPressed: Audio.stepVolume(-5) }
    GlobalShortcut { name: "volumeUpFine"; description: "Volume up 1%"; onPressed: Audio.stepVolume(1) }
    GlobalShortcut { name: "volumeDownFine"; description: "Volume down 1%"; onPressed: Audio.stepVolume(-1) }
    GlobalShortcut { name: "volumeMute"; description: "Mute output"; onPressed: Audio.toggleMute() }
    GlobalShortcut { name: "micMute"; description: "Mute microphone"; onPressed: Audio.toggleMic() }

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
        // Open every Comms dock app, hidden (at login: scripts/wm/CommsStartup.sh)
        function commsStart(): void { Comms.startAll(); }
        // The keyboard to the dock: ←/→, Enter, 1–9, Esc (SUPER SHIFT Y)
        function commsDock(): void { Comms.focusDock(); }
        // The top bar: hide / show it for now (SUPER CTRL ALT B; TopBar.qml)
        function barToggle(): void { BarState.toggleRequested(); }
        // Next / previous app while one is up (SUPER TAB / SUPER SHIFT TAB)
        // Quick capture (QuickAdd.qml): SUPER Z, prefilled with `text`; SUPER SHIFT Z: the selected text
        function quickAdd(text: string): void { Capture.open(text, ""); }
        function quickAddSelection(): void { Capture.openSelection(); }
        function quickAddClose(): void { Capture.close(); }
        // The call going on (services/Call.qml), as JSON
        function call(): string {
            return JSON.stringify({ active: Call.active, name: Call.name, detail: Call.detail, title: Call.title, pid: Call.pid,
                                    binary: Call.binary, mic: Call.micState, micMuted: Call.micMuted, cam: Call.camOn, exact: Call.exact });
        }
        function commsNext(): void { Comms.cycle(1); }
        function commsPrev(): void { Comms.cycle(-1); }
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
