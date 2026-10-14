#!/usr/bin/env python3
"""What starts at login (services/Startup.qml), from two places:

  xdg   XDG autostart entries (~/.config/autostart over /etc/xdg/autostart,
        same file name), which uwsm turns into systemd user units
        app-<id>@autostart.service, skipping hidden ones and ones for other
        desktops. Listed as that generator sees them.
  hypr  the commands in startup_commands of Hyprland's user_startup.lua
        (exec_once at Hyprland's start); a commented-out one is off.

  startup.py list            one JSON array: id, kind, name, comment, icon, exec,
                             enabled, locked, state (running | exited | failed |
                             skipped | stopped), memory (bytes, when running)
  startup.py set ID on|off   start it at login or not. xdg: Hidden=true in the
                             user's copy (made from the system's when there is
                             none; on again, a copy left equal to the system's is
                             removed). hypr: the line commented out / back in
  startup.py start ID        start it now
  startup.py stop ID         stop it now (its unit, its Flatpak, its processes)
"""
import json
import os
import re
import shlex
import shutil
import subprocess
import sys

HOME = os.path.expanduser("~")
USER_DIR = os.path.join(os.environ.get("XDG_CONFIG_HOME", HOME + "/.config"), "autostart")
SYSTEM_DIRS = [os.path.join(d, "autostart") for d in os.environ.get("XDG_CONFIG_DIRS", "/etc/xdg").split(":") if d]
DESKTOPS = [d.lower() for d in os.environ.get("XDG_CURRENT_DESKTOP", "Hyprland").split(":") if d]
HYPR_FILE = os.path.join(HOME, ".config/hypr/UserConfigs/user_startup.lua")
OFF = ("hidden=true", "x-gnome-autostart-enabled=false")
# Starts the panel itself: not something to turn off from the panel
LOCKED = ("quickshell-panel",)
# Launchers whose own name says nothing about the program
WRAPPERS = {"env", "sh", "bash", "zsh", "dash", "flatpak", "python", "python3", "systemctl", "sleep", "nice"}


# ---------------- XDG autostart ----------------
def read(path):
    """The [Desktop Entry] keys of a .desktop file (untranslated ones)."""
    keys, inside = {}, False
    try:
        with open(path, encoding="utf-8", errors="replace") as f:
            for line in f:
                line = line.strip()
                if line.startswith("["):
                    inside = line == "[Desktop Entry]"
                elif inside and "=" in line and not line.startswith("#"):
                    k, v = line.split("=", 1)
                    keys.setdefault(k.strip(), v.strip())
    except OSError:
        return None
    return keys


def listed(value):
    return [x.lower() for x in (value or "").split(";") if x]


def on_path(cmd):
    return os.path.isabs(cmd) and os.access(cmd, os.X_OK) or shutil.which(cmd) is not None


def applies(k):
    """Whether it would start on this desktop at all (else it isn't listed)."""
    if k.get("Type", "Application") != "Application" or k.get("X-systemd-skip", "").lower() == "true":
        return False
    only, never = listed(k.get("OnlyShowIn")), listed(k.get("NotShowIn"))
    if only and not any(d in only for d in DESKTOPS):
        return False
    if any(d in never for d in DESKTOPS):
        return False
    if k.get("TryExec") and not on_path(k["TryExec"]):
        return False
    return bool(k.get("Exec"))


def escape(s):
    """systemd unit name escaping, as the autostart generator does it."""
    out = []
    for i, c in enumerate(s):
        if c == "/":
            out.append("-")
        elif c.isascii() and (c.isalnum() or c in ":_" or (c == "." and i > 0)):
            out.append(c)
        else:
            out.append("".join("\\x%02x" % b for b in c.encode()))
    return "".join(out)


def files():
    """id → (user path or None, system path or None)."""
    found = {}
    for d in reversed(SYSTEM_DIRS):
        for name in sorted(os.listdir(d)) if os.path.isdir(d) else []:
            if name.endswith(".desktop"):
                found[name[:-8]] = (None, os.path.join(d, name))
    if os.path.isdir(USER_DIR):
        for name in os.listdir(USER_DIR):
            if name.endswith(".desktop"):
                found[name[:-8]] = (os.path.join(USER_DIR, name), found.get(name[:-8], (None, None))[1])
    return found


def xdg_entries():
    out = []
    for id_, (user, system) in files().items():
        k = read(user or system)
        if k is None or not applies(k):
            continue
        out.append({
            "id": id_,
            "kind": "xdg",
            "name": k.get("Name") or id_,
            "comment": k.get("Comment") or k.get("GenericName") or "",
            "icon": k.get("Icon", ""),
            "exec": k.get("Exec", ""),
            "enabled": not any(f"{key.lower()}={v.lower()}" in OFF for key, v in k.items()),
            "locked": False,
            "unit": f"app-{escape(id_)}@autostart.service",
            "flatpak": k.get("X-Flatpak", ""),
        })
    return out


def without_off(lines):
    return [l for l in lines if l.strip().replace(" ", "").lower() not in OFF]


def xdg_set(id_, on):
    user, system = files().get(id_, (None, None))
    if not user and not system:
        sys.exit(f"no autostart entry {id_}")
    path = user or os.path.join(USER_DIR, id_ + ".desktop")
    with open(user or system, encoding="utf-8", errors="replace") as f:
        lines = without_off(f.read().splitlines())
    if on and system and user:
        with open(system, encoding="utf-8", errors="replace") as f:
            if f.read().splitlines() == lines:
                os.remove(user)           # the copy says nothing the system's doesn't
                return
    if not on:
        at = next((i for i, l in enumerate(lines) if l.strip() == "[Desktop Entry]"), -1)
        lines.insert(at + 1, "Hidden=true")
    os.makedirs(USER_DIR, exist_ok=True)
    write(path, lines, mode_of=user)


# ---------------- Hyprland's user_startup.lua ----------------
# A command of the startup_commands table: `"cmd",`, or `-- "cmd",` when off
HYPR_LINE = re.compile(r'^(\s*)(--\s*)?"((?:[^"\\]|\\.)*)",?\s*(--.*)?$')


def hypr_lines():
    try:
        with open(HYPR_FILE, encoding="utf-8") as f:
            return f.read().splitlines()
    except OSError:
        return []


def hypr_table(lines):
    """Line indexes of the startup_commands table's body."""
    start = next((i for i, l in enumerate(lines) if re.match(r"\s*local\s+startup_commands\s*=\s*{", l)), None)
    if start is None:
        return range(0)
    end = next((i for i in range(start + 1, len(lines)) if lines[i].strip().startswith("}")), len(lines))
    return range(start + 1, end)


def hypr_entries():
    lines, out, notes = hypr_lines(), [], []
    for i in hypr_table(lines):
        m = HYPR_LINE.match(lines[i])
        if not m:
            # Comments above a command describe it
            note = lines[i].strip()
            notes = notes + [note[2:].strip()] if note.startswith("--") else []
            continue
        cmd = m.group(3)
        words = cmd.replace("$HOME", HOME).split()
        prog = os.path.basename(words[0]) if words else cmd
        if prog in WRAPPERS and len(words) > 1:
            prog = os.path.basename(words[-1]).removesuffix(".service")
        out.append({
            "id": "hypr:" + cmd,
            "kind": "hypr",
            "name": re.sub(r"\.(sh|py)$", "", prog),
            "comment": " ".join(notes),
            "icon": "",
            "exec": cmd,
            "enabled": not m.group(2),
            "locked": any(x in cmd for x in LOCKED),
            "unit": "",
            "flatpak": "",
        })
        notes = []
    return out


def hypr_set(cmd, on):
    lines = hypr_lines()
    for i in hypr_table(lines):
        m = HYPR_LINE.match(lines[i])
        if m and m.group(3) == cmd:
            if any(x in cmd for x in LOCKED):
                sys.exit("that one starts the panel")
            rest = lines[i][m.end(1):]
            rest = re.sub(r"^--\s*", "", rest)
            lines[i] = m.group(1) + ("" if on else "-- ") + rest
            write(HYPR_FILE, lines, mode_of=HYPR_FILE)
            return
    sys.exit(f"no startup command {cmd}")


# ---------------- Running state ----------------
def write(path, lines, mode_of=None):
    path = os.path.realpath(path)             # through a symlink (dotfiles): its target
    tmp = path + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        f.write("\n".join(lines) + "\n")
    if mode_of and os.path.exists(mode_of):
        shutil.copymode(mode_of, tmp)
    os.replace(tmp, path)


def program(cmd):
    """The name its process runs under (/proc/<pid>/comm), or "" if it can't be told."""
    try:
        words = shlex.split(re.sub(r"%[a-zA-Z]", "", cmd))
    except ValueError:
        words = cmd.split()
    words = [w for w in words if "=" not in w.split("/")[0]]       # VAR=value prefixes
    if not words:
        return ""
    name = os.path.basename(words[0].replace("$HOME", HOME))
    return "" if name in WRAPPERS else name[:15]


def processes():
    """name → [pids] (this user's): by comm, and a script by its file name
    (`bash …/BatteryNotify.sh` runs as comm "bash")."""
    by, uid = {}, os.getuid()
    for p in os.listdir("/proc"):
        if not p.isdigit():
            continue
        try:
            if os.stat("/proc/" + p).st_uid != uid:
                continue
            with open(f"/proc/{p}/comm") as f:
                comm = f.read().strip()
            by.setdefault(comm, []).append(int(p))
            if comm in WRAPPERS:
                with open(f"/proc/{p}/cmdline", "rb") as f:
                    argv = f.read().split(b"\0")
                if len(argv) > 1 and argv[1] and not argv[1].startswith(b"-"):
                    by.setdefault(os.path.basename(argv[1].decode(errors="replace"))[:15], []).append(int(p))
        except OSError:
            pass
    return by


def rss(pids):
    page, total = os.sysconf("SC_PAGE_SIZE"), 0
    for p in pids:
        try:
            with open(f"/proc/{p}/statm") as f:
                total += int(f.read().split()[1]) * page
        except (OSError, IndexError, ValueError):
            pass
    return total


def units(names):
    """unit → its properties, for the loaded ones."""
    if not names:
        return {}
    out = subprocess.run(["systemctl", "--user", "show", "-p",
                          "Id,ActiveState,Result,ConditionResult,ExecMainStartTimestampMonotonic,ControlGroup", "--", *names],
                         capture_output=True, text=True).stdout
    info, cur = {}, {}
    for line in out.splitlines() + [""]:
        if not line:
            if cur.get("Id"):
                info[cur["Id"]] = cur
            cur = {}
        elif "=" in line:
            k, v = line.split("=", 1)
            cur[k] = v
    return info


def flatpak_scopes():
    """Flatpak app id → its running scopes (app-flatpak-<id>-<n>.scope)."""
    out = subprocess.run(["systemctl", "--user", "list-units", "--type=scope", "--state=running",
                          "--no-legend", "--plain", "app-flatpak-*"], capture_output=True, text=True).stdout
    by = {}
    for line in out.splitlines():
        m = re.match(r"(app-flatpak-(\S+)-\d+\.scope)\s", line.strip())
        if m:
            by.setdefault(m.group(2), []).append(m.group(1))
    return by


def mem(u):
    """What a unit's processes hold (anon + shmem + kernel): its cgroup's
    MemoryCurrent also counts the page cache, which the kernel takes back."""
    total = 0
    try:
        with open("/sys/fs/cgroup" + u.get("ControlGroup", "") + "/memory.stat") as f:
            for line in f:
                k, v = line.split()
                if k in ("anon", "shmem", "kernel"):
                    total += int(v)
    except (OSError, ValueError):
        pass
    return total


def entries():
    apps = xdg_entries() + hypr_entries()
    procs, scopes = processes(), flatpak_scopes()
    info = units([a["unit"] for a in apps if a["unit"]] + [s for v in scopes.values() for s in v])
    for a in apps:
        u = info.get(a["unit"], {})
        pids = procs.get(program(a["exec"]), [])
        own = scopes.get(a["flatpak"], [])
        if a["flatpak"] and own:
            a["state"], a["memory"] = "running", sum(mem(info.get(s, {})) for s in own) + mem(u)
        elif u.get("ActiveState") in ("active", "activating"):
            a["state"], a["memory"] = "running", mem(u)
        elif pids:
            # Started some other way (exec-once, by hand): still running
            a["state"], a["memory"] = "running", rss(pids)
        else:
            a["memory"] = 0
            a["state"] = ("failed" if u.get("ActiveState") == "failed"
                          else "skipped" if u.get("ConditionResult") == "no"
                          else "exited" if u.get("ExecMainStartTimestampMonotonic", "0") not in ("", "0")
                          else "stopped")
    apps.sort(key=lambda a: (a["kind"] != "xdg", not a["enabled"], a["name"].lower()))
    return apps


def find(id_):
    a = next((a for a in xdg_entries() + hypr_entries() if a["id"] == id_), None)
    if not a:
        sys.exit(f"no startup entry {id_}")
    return a


def start(a):
    if a["kind"] == "xdg":
        loaded = units([a["unit"]]).get(a["unit"], {}).get("ActiveState") is not None
        if loaded and a["enabled"]:
            subprocess.run(["systemctl", "--user", "start", "--no-block", a["unit"]])
            return
        cmd = re.sub(r"\s%[a-zA-Z]", "", a["exec"])
    else:
        cmd = a["exec"]
    # Its own transient unit: outlives the panel (a child of it dies with it)
    subprocess.run(["systemd-run", "--user", "--collect", "--quiet", "--", "sh", "-c", cmd])


def stop(a):
    if a["kind"] == "xdg":
        subprocess.run(["systemctl", "--user", "stop", "--no-block", a["unit"]])
        if a["flatpak"]:
            subprocess.run(["flatpak", "kill", a["flatpak"]], capture_output=True)
    pids = processes().get(program(a["exec"]), [])
    for p in pids:
        try:
            os.kill(p, 15)
        except OSError:
            pass


if __name__ == "__main__":
    args = sys.argv[1:]
    if args == ["list"]:
        print(json.dumps(entries()))
    elif len(args) == 3 and args[0] == "set" and args[2] in ("on", "off"):
        if args[1].startswith("hypr:"):
            hypr_set(args[1][5:], args[2] == "on")
        else:
            xdg_set(args[1], args[2] == "on")
            # The generator makes the units again from the files
            subprocess.run(["systemctl", "--user", "daemon-reload"])
    elif len(args) == 2 and args[0] in ("start", "stop"):
        (start if args[0] == "start" else stop)(find(args[1]))
    else:
        sys.exit(__doc__)
