#!/usr/bin/env python3
"""A call's microphone and camera (services/Call.qml).

Usage:
  call.py state BINARY TITLE   prints {"mic": "live" | "muted" | "none" | "unknown",
                                       "cam": true | false, "source": "a11y" | "system"}

The exact state is the app's own buttons, read through accessibility
(AT-SPI): in the window whose title contains TITLE (the meeting code), the
buttons "Turn off microphone" / "Turn on microphone" (and the camera's, in
English or Spanish). That needs accessibility on (org.gnome.desktop.interface
toolkit-accessibility) when the browser starts. Without it: the camera is on
while a process of BINARY has /dev/video* open, and the microphone can't be
known (a muted call keeps recording; it just doesn't send): "unknown" unless
the program isn't recording at all ("none").
"""
import glob
import json
import os
import re
import subprocess
import sys

MIC_ON = re.compile(r"^(turn off microphone|desactivar (el )?micr[oó]fono|silenciar)", re.I)
MIC_OFF = re.compile(r"^(turn on microphone|activar (el )?micr[oó]fono|reactivar)", re.I)
CAM_ON = re.compile(r"^(turn off camera|desactivar (la )?c[aá]mara)", re.I)
CAM_OFF = re.compile(r"^(turn on camera|activar (la )?c[aá]mara)", re.I)


def a11y(title):
    """{"mic": bool on, "cam": bool on} from the app's buttons, or None."""
    try:
        import gi
        gi.require_version("Atspi", "2.0")
        from gi.repository import Atspi
    except (ImportError, ValueError):
        return None
    desk = Atspi.get_desktop(0)
    for i in range(desk.get_child_count()):
        app = desk.get_child_at_index(i)
        if not app:
            continue
        for j in range(app.get_child_count()):
            frame = app.get_child_at_index(j)
            try:
                if not frame or title not in (frame.get_name() or ""):
                    continue
            except Exception:
                continue
            out, stack, seen = {}, [frame], 0
            while stack and seen < 6000 and len(out) < 2:
                o = stack.pop()
                seen += 1
                try:
                    role, name = o.get_role_name(), (o.get_name() or "").strip()
                    if role in ("push button", "toggle button"):
                        if MIC_ON.match(name): out["mic"] = True
                        elif MIC_OFF.match(name): out["mic"] = False
                        elif CAM_ON.match(name): out["cam"] = True
                        elif CAM_OFF.match(name): out["cam"] = False
                    n = o.get_child_count()
                    stack.extend(c for c in (o.get_child_at_index(k) for k in range(min(n, 500))) if c)
                except Exception:
                    pass
            if out:
                return out
    return None


def recording(binary):
    try:
        r = subprocess.run(["pactl", "-f", "json", "list", "source-outputs"], capture_output=True, text=True, timeout=5)
        return any(s["properties"].get("application.process.binary") == binary for s in json.loads(r.stdout or "[]"))
    except (OSError, ValueError, subprocess.TimeoutExpired):
        return False


def camera(binary):
    devs = {os.path.realpath(d) for d in glob.glob("/dev/video*")}
    for pid in filter(str.isdigit, os.listdir("/proc")):
        try:
            with open(f"/proc/{pid}/comm") as f:
                if f.read().strip() != binary:
                    continue
            for fd in os.listdir(f"/proc/{pid}/fd"):
                try:
                    if os.readlink(f"/proc/{pid}/fd/{fd}") in devs:
                        return True
                except OSError:
                    pass
        except OSError:
            pass                                     # sandboxed renderers: not readable, never the camera
    return False


def main():
    if len(sys.argv) < 3 or sys.argv[1] != "state":
        sys.exit(__doc__)
    binary, title = sys.argv[2], sys.argv[3] if len(sys.argv) > 3 else ""
    got = a11y(title) if title else None
    rec = recording(binary)
    if got:
        mic = "none" if not rec else "live" if got.get("mic", True) else "muted"
        print(json.dumps({"mic": mic, "cam": got.get("cam", camera(binary)), "source": "a11y"}))
    else:
        print(json.dumps({"mic": "unknown" if rec else "none", "cam": camera(binary), "source": "system"}))


if __name__ == "__main__":
    main()
