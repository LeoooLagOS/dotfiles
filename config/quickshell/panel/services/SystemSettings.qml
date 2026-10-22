pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.UPower
import "../common"

// Applies the Settings that live outside the panel, and reads the "About" info.
//   hypridle   ~/.config/lagos/hypridle.conf (sourced by config/hypr/hypridle.conf),
//              then hypridle is restarted
//   battery    ~/.config/lagos/battery-alerts (read by scripts/wm/BatteryNotify.sh)
//   lid        ~/.config/lagos/lid (read by scripts/wm/LaptopLid.sh on each lid close)
//   profile    power profile at login (tuned-ppd / power-profiles-daemon)
//   wallpaper  automatic rotation through Wallpapers.apply()
//   blur       scripts/wm/PanelBlur.sh (state in ~/.config/lagos/panel-blur)
//   wallust    scripts/wm/WallustToggle.sh (state in ~/.config/lagos/wallust)
//   rofi       scripts/wm/RofiPosition.sh (state: ~/.config/hypr/rofi/position.rasi)
// For blur and wallust the state files are the source of truth: the scripts can
// be run on their own, so the switches follow the files, and a switch only runs
// its script when it disagrees with the file.
Singleton {
    id: root

    readonly property string dir: Quickshell.env("HOME") + "/.config/lagos"
    readonly property string scripts: Quickshell.env("HOME") + "/.config/hypr/scripts"

    // ---------------- Blur / wallust state files ----------------
    FileView {
        id: blurState
        property bool on: true
        path: root.dir + "/panel-blur"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: { on = text().trim() !== "off"; if (Settings.loaded) Settings.set("blur", on); }
    }
    FileView {
        id: rofiState
        property string position: "bottom"
        path: Quickshell.env("HOME") + "/.config/hypr/rofi/position.rasi"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: { position = /location:\s*south/.test(text()) ? "bottom" : "center"; if (Settings.loaded) Settings.set("rofiPosition", position); }
    }
    FileView {
        id: wallustState
        property bool on: true
        path: root.dir + "/wallust"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
        onLoaded: { on = text().trim() !== "off"; if (Settings.loaded) Settings.set("wallust", on); }
    }
    property var about: ({})

    // ---------------- hypridle ----------------
    readonly property var idleKeys: ["dim", "warn", "lock", "screenOff", "suspend", "mediaGuard"]
    function hypridleText() {
        const v = Settings.v;
        return "# Written by the Quickshell panel (Settings → Power & idle). Edit it there.\n"
            + "$dim_timeout = " + v.dim + "\n"
            + "$warn_timeout = " + v.warn + "\n"
            + "$lock_timeout = " + v.lock + "\n"
            + "$screen_off_timeout = " + v.screenOff + "\n"
            + "$suspend_timeout = " + v.suspend + "\n"
            + "$media_guard = " + (v.mediaGuard ? "playerctl status 2>/dev/null | grep -q 'Playing' ||" : "true &&") + "\n";
    }
    FileView { id: idleFile; path: root.dir + "/hypridle.conf"; atomicWrites: true; printErrors: false; preload: false }
    FileView { id: batteryFile; path: root.dir + "/battery-alerts"; atomicWrites: true; printErrors: false; preload: false }
    FileView { id: lidFile; path: root.dir + "/lid"; atomicWrites: true; printErrors: false; preload: false }
    readonly property var lidKeys: ["lidBattery", "lidAc", "lidDocked"]

    function writeFiles() {
        Quickshell.execDetached(["mkdir", "-p", dir]);
        idleFile.setText(hypridleText());
        batteryFile.setText(Settings.v.battery.slice().sort((a, b) => b - a).join(" ") + "\n");
        lidFile.setText("# Written by the Quickshell panel (Settings → Power & idle). Edit it there.\n"
            + "battery=" + Settings.v.lidBattery + "\nac=" + Settings.v.lidAc + "\ndocked=" + Settings.v.lidDocked + "\n");
    }
    // Restart hypridle through Hyprland, so it stays a child of the compositor.
    // hypridle ignores SIGTERM/SIGINT, hence the SIGKILL after a short wait.
    Timer {
        id: restartIdle
        interval: 1200
        onTriggered: Quickshell.execDetached(["bash", "-c",
            "pkill -x hypridle; sleep 0.5; pkill -KILL -x hypridle; sleep 0.2; "
            + "hyprctl dispatch 'hl.dsp.exec_cmd(\"hypridle\")' >/dev/null"])
    }

    Connections {
        target: Settings
        function onLoadedChanged() { if (Settings.loaded) root.startup(); }
        function onChanged(key) {
            if (root.idleKeys.includes(key)) { root.writeFiles(); restartIdle.restart(); }
            else if (key === "battery" || root.lidKeys.includes(key)) root.writeFiles();
            else if (key === "rotate" || key === "rotateMin") rotation.restart();
            else if (key === "blur" && Settings.v.blur !== blurState.on)
                Quickshell.execDetached([root.scripts + "/PanelBlur.sh", Settings.v.blur ? "on" : "off"]);
            else if (key === "rofiPosition" && Settings.v.rofiPosition !== rofiState.position)
                Quickshell.execDetached([root.scripts + "/RofiPosition.sh", Settings.v.rofiPosition]);
            else if (key === "wallust" && Settings.v.wallust !== wallustState.on)
                Quickshell.execDetached([root.scripts + "/WallustToggle.sh", Settings.v.wallust ? "on" : "off"]);
        }
    }

    // ---------------- Power profile at login ----------------
    // Applied once per boot (a marker in $XDG_RUNTIME_DIR survives panel restarts)
    readonly property var profileMap: ({ "power-saver": PowerProfile.PowerSaver, "balanced": PowerProfile.Balanced, "performance": PowerProfile.Performance })
    Process {
        id: profileOnce
        command: ["bash", "-c", "m=\"${XDG_RUNTIME_DIR:-/tmp}/quickshell-panel-profile-applied\"; [ -e \"$m\" ] || { touch \"$m\"; echo apply; }"]
        stdout: StdioCollector {
            onStreamFinished: {
                const p = root.profileMap[Settings.v.loginProfile];
                if (text.trim() === "apply" && p !== undefined) PowerProfiles.profile = p;
            }
        }
    }

    Component.onCompleted: if (Settings.loaded) startup()
    function startup() {
        writeFiles();             // so hypridle's `source` always finds the file
        profileOnce.running = true;
        refreshAbout();
        // Switches follow the state files (missing file = on)
        Settings.set("blur", blurState.on);
        Settings.set("wallust", wallustState.on);
        Settings.set("rofiPosition", rofiState.position);
    }

    // ---------------- Wallpaper rotation ----------------
    Timer {
        id: rotation
        interval: Settings.v.rotateMin * 60 * 1000
        running: Settings.v.rotate
        repeat: true
        onTriggered: { pickNext.armed = true; Wallpapers.refresh(); }
    }
    // Pick once the list is fresh
    Connections {
        id: pickNext
        property bool armed: false
        target: Wallpapers
        function onItemsChanged() {
            if (!pickNext.armed) return;
            pickNext.armed = false;
            const others = Wallpapers.items.filter(i => i.path !== Wallpapers.current);
            if (others.length) Wallpapers.apply(others[Math.floor(Math.random() * others.length)].path);
        }
    }

    // ---------------- About ----------------
    function refreshAbout() { if (!aboutProc.running) aboutProc.running = true; }
    Process {
        id: aboutProc
        command: ["bash", "-c", `
            . /etc/os-release
            gpu=$(lspci 2>/dev/null | grep -iE 'vga|3d' | sed -E 's/.*: //; s/Corporation //; s/ \\(rev.*//; s/.*\\[(.*)\\].*/\\1/' | paste -sd '·' | sed 's/·/ · /g')
            cals=$(ls ~/.config/lagos/calendars/*.ics 2>/dev/null | wc -l)
            jq -n \\
              --arg model "$(cat /sys/class/dmi/id/product_name 2>/dev/null)" \\
              --arg cpu "$(lscpu | sed -n 's/^Model name: *//p' | sed -E 's/\\(R\\)|\\(TM\\)|[0-9]+th Gen //g; s/  +/ /g')" \\
              --arg gpu "$gpu" \\
              --arg memory "$(awk '/MemTotal/{printf "%d GB", $2/1048576 + 0.5}' /proc/meminfo)" \\
              --arg os "$PRETTY_NAME" \\
              --arg kernel "$(uname -r)" \\
              --arg versions "$(hyprctl version 2>/dev/null | awk 'NR==1{print $2}') · $(qs --version 2>/dev/null | awk '{print $2}')" \\
              --arg dotfiles "$(git -C ~/dotfiles log -1 --format='%h · %s' 2>/dev/null)" \\
              --arg weatherHome "$(cat ~/.config/lagos/weather-home 2>/dev/null || echo 'Automatic (IP)')" \\
              --arg cals "$cals" \\
              --arg lidService "$(systemctl --user is-active --quiet lagos-lid.service && echo 'This session (lagos-lid.service)' || echo 'logind (lagos-lid.service is not running)')" \\
              '$ARGS.named'
        `]
        stdout: StdioCollector {
            onStreamFinished: { try { root.about = JSON.parse(text); } catch (e) { console.warn("about:", e); } }
        }
    }
    // Wallpaper info comes from the Wallpapers service
    readonly property var info: Object.assign({}, about, {
        wallpaperDir: Config.wallpaperDir.replace("$HOME", "~"),
        wallpaper: Wallpapers.current ? Wallpapers.current.split("/").pop() : "—",
        calendars: about.cals === undefined ? "…" : Tr.t("Evolution webcal + %1 .ics file(s)", about.cals),
        weatherHome: about.weatherHome === undefined ? "…" : Tr.t(about.weatherHome),
        lidService: about.lidService === undefined ? "…" : Tr.t(about.lidService)
    })
}
