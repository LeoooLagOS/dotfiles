#!/usr/bin/env python3
"""Brings the laptop screen back when it stays black after waking up.

When the screen comes back on (after suspend, or after it was turned off for
being idle), the Intel GPU sometimes fails to reconnect to the laptop panel,
and the kernel logs:

    i915 ... [CONNECTOR:...:eDP-1] ... Failed to enable link training

The system is awake (the lock screen takes the password), but the panel stays
black. After that error the kernel lowers the link speed and waits for the
compositor to set the screen up again (a "modeset"), which Hyprland doesn't do
on its own. Turning the panel off and on again (DPMS) is such a modeset.

    PanelRelink.py watch   follows the kernel log and does it on its own
                           (run by lagos-panel-relink.service)
    PanelRelink.py now     does it right away (SUPER CTRL ALT + P, works on
                           the lock screen, so it can be pressed blind)

Turning off PSR (System/etc/modprobe.d/i915-psr.conf) didn't stop the error.
"""

import json
import queue
import subprocess
import sys
import threading
import time
from collections import deque

ERROR = r"eDP-[0-9]+.*Failed to enable link training"
SETTLE = 2  # seconds: the kernel logs the error in bursts; act once per burst
MAX_TRIES = 3  # relinks per WINDOW; if they keep failing, stop (no endless blinking)
WINDOW = 60


def log(msg: str) -> None:
    print(msg, flush=True)  # stdout goes to the journal under systemd


def laptop_panel() -> dict | None:
    """The laptop panel as Hyprland lists it, or None while it's disabled
    (docked to an external monitor)."""
    out = subprocess.run(["hyprctl", "monitors", "-j"], capture_output=True, text=True).stdout
    try:
        monitors = json.loads(out)
    except json.JSONDecodeError:
        return None
    return next((m for m in monitors if m["name"].startswith("eDP")), None)


def dpms(action: str, monitor: str) -> None:
    arg = f'{{ action = "{action}", monitor = "{monitor}" }}'
    subprocess.run(["hyprctl", "dispatch", "hl.dsp.dpms", arg], capture_output=True)


def relink(only_if_on: bool) -> None:
    panel = laptop_panel()
    if panel is None:
        log("laptop panel is disabled, nothing to do")
        return
    # The watcher leaves a screen that is meant to be off (idle, lid closed) alone.
    if only_if_on and not panel["dpmsStatus"]:
        log(f"{panel['name']} is off on purpose, leaving it")
        return
    log(f"relinking {panel['name']}: off and on again")
    dpms("off", panel["name"])
    time.sleep(1)
    dpms("on", panel["name"])


def read_lines(stream, lines: queue.Queue) -> None:
    for line in stream:
        lines.put(line.strip())
    lines.put(None)  # journalctl exited


def watch() -> int:
    journal = subprocess.Popen(
        ["journalctl", "--dmesg", "--follow", "--lines=0", "--output=cat", "--grep", ERROR],
        stdout=subprocess.PIPE,
        text=True,
    )
    lines: queue.Queue = queue.Queue()
    threading.Thread(target=read_lines, args=(journal.stdout, lines), daemon=True).start()
    tries: deque = deque()

    while True:
        line = lines.get()
        if line is None:
            return 1  # systemd restarts the service
        log(f"kernel: {line}")
        # Wait until the burst is over, so one failure means one relink.
        try:
            while True:
                if lines.get(timeout=SETTLE) is None:
                    return 1
        except queue.Empty:
            pass

        now = time.monotonic()
        while tries and now - tries[0] > WINDOW:
            tries.popleft()
        if len(tries) >= MAX_TRIES:
            log(f"{MAX_TRIES} relinks in {WINDOW} s didn't help, waiting (SUPER CTRL ALT + P to retry)")
            continue
        tries.append(now)
        relink(only_if_on=True)


def main() -> int:
    mode = sys.argv[1] if len(sys.argv) > 1 else ""
    if mode == "watch":
        return watch()
    if mode == "now":
        relink(only_if_on=False)
        return 0
    print(__doc__)
    return 2


if __name__ == "__main__":
    sys.exit(main())
