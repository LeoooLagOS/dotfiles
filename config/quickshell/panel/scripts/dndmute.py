#!/usr/bin/env python3
"""Do Not Disturb for the apps' own sounds (services/Comms.qml runs it).

WhatsApp Web, Teams… play their notification sound themselves, in the app,
so the notification daemon can't hold it back. This mutes their audio
streams instead.

stdin: one line per change, the PIDs of the apps to keep quiet, separated
by spaces (an empty line: none). A stream is theirs when its process
(application.process.id) is one of them or a child of one (Chromium and
Electron play from a child process).

Chromium's audio runs in a sandbox: its streams carry a PID of their own
namespace (no such process here). Then the stream's application.process.binary
is compared with the apps' own (/proc/<pid>/comm: "brave", "teams-for-linux").

Streams of an app that is also recording (a call going on) are left alone.

WirePlumber remembers a muted app (by application.name) and starts its next
streams muted. So the names muted here are kept in a file, and a stream of
one of them that shouldn't be quiet anymore is unmuted when it shows up.
"""
import ctypes
import json
import os
import signal
import subprocess
import sys
import threading

STATE = os.path.expanduser("~/.local/state/quickshell-panel/dnd-muted.json")

lock = threading.Lock()
sub = None                    # `pactl subscribe`
quiet = set()                 # PIDs of the apps to keep quiet


def load():
    try:
        with open(STATE) as f:
            return set(json.load(f))
    except (OSError, ValueError):
        return set()


muted = load()                # application.names muted by this script


def save():
    os.makedirs(os.path.dirname(STATE), exist_ok=True)
    with open(STATE, "w") as f:
        json.dump(sorted(muted), f)


def ancestors(pid):
    out = set()
    while pid > 1 and pid not in out:
        out.add(pid)
        try:
            with open(f"/proc/{pid}/stat") as f:
                # comm may hold spaces / parentheses: ppid comes after the last ")"
                pid = int(f.read().rsplit(")", 1)[1].split()[1])
        except (OSError, IndexError, ValueError):
            break
    return out


def pactl_list(what):
    try:
        r = subprocess.run(["pactl", "-f", "json", "list", what], capture_output=True, text=True, timeout=5)
        return json.loads(r.stdout or "[]")
    except (OSError, ValueError, subprocess.TimeoutExpired):
        return []


def comm(pid):
    try:
        with open(f"/proc/{pid}/comm") as f:
            return f.read().strip()
    except OSError:
        return ""


def owner(stream, apps, bins):
    """The quiet app (its PID) the stream belongs to, or None."""
    props = stream["properties"]
    try:
        pid = int(props.get("application.process.id", "0"))
    except ValueError:
        pid = 0
    hit = ancestors(pid) & apps if pid else set()
    if hit:
        return next(iter(hit))
    # A sandboxed PID: by the program
    return bins.get(props.get("application.process.binary", ""))


def sync():
    with lock:
        apps = set(quiet)
        bins = {comm(p): p for p in apps if comm(p)}
        changed = False
        # An app recording (a call): its sound goes through
        calling = {owner(s, apps, bins) for s in pactl_list("source-outputs")} - {None}
        for s in pactl_list("sink-inputs"):
            name = s["properties"].get("application.name", "")
            app = owner(s, apps, bins)
            want = app is not None and app not in calling
            if want and not s["mute"]:
                subprocess.run(["pactl", "set-sink-input-mute", str(s["index"]), "1"])
                if name and name not in muted:
                    muted.add(name)
                    changed = True
            elif not want and s["mute"] and name in muted:
                subprocess.run(["pactl", "set-sink-input-mute", str(s["index"]), "0"])
                # Unmuted: WirePlumber remembers that now
                muted.discard(name)
                changed = True
        if changed:
            save()


def read_stdin():
    for line in sys.stdin:
        pids = set()
        for p in line.split():
            if p.isdigit():
                pids.add(int(p))
        with lock:
            quiet.clear()
            quiet.update(pids)
        sync()
    # The panel is gone (or reloaded): take `pactl subscribe` along, or each
    # reload would leave one connected until pipewire-pulse refuses clients
    if sub:
        sub.terminate()
    os._exit(0)


def main():
    threading.Thread(target=read_stdin, daemon=True).start()
    sync()
    global sub
    # Dies with this script, however it ends (PR_SET_PDEATHSIG)
    libc = ctypes.CDLL("libc.so.6", use_errno=True)
    sub = subprocess.Popen(["pactl", "subscribe"], stdout=subprocess.PIPE, text=True,
                           preexec_fn=lambda: libc.prctl(1, signal.SIGTERM))
    for line in sub.stdout:
        # A new stream, or a recording starting / ending
        if ("'new'" in line and "sink-input" in line) or "source-output" in line:
            sync()


if __name__ == "__main__":
    main()
