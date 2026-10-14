#!/usr/bin/env python3
"""Task providers → the panel's deadlines (services/Events.qml).

Usage:
  providers.py list              every provider's open tasks, merged
  providers.py done NAME ID      a task is done (the provider writes it back)
  providers.py undone NAME ID    back (Undo)

A provider is any executable in ~/.config/lagos/providers/ (its file name is
its NAME; hidden files and ones not executable are skipped). The panel knows
nothing else about it; it only has to answer:

  <provider> tasks       JSON on stdout:
                           {"label": "Vault",            what the panel calls it
                            "tasks": [{"id": "…",        stable, given back to done / undone
                                       "title": "…",
                                       "due": "YYYY-MM-DD" or "YYYY-MM-DDTHH:MM" (or "": no date),
                                       "where": "…",     optional: the class, the place…
                                       "remind": true,   optional: false = no reminders
                                       "open": "url"}]}  optional: opened with xdg-open on a click
  <provider> done ID     mark it done; prints {"ok": true} or {"ok": false, "error": "…"}
  <provider> undone ID   the same, back

`list` prints {"tasks": [... each with "source": NAME and "label"], "errors": [...]}.
Calendar events don't need a provider: an .ics file in ~/.config/lagos/calendars/
is read like any local calendar (scripts/events.py).
"""
import json
import os
import subprocess
import sys
from pathlib import Path

DIR = Path.home() / ".config/lagos/providers"
TIMEOUT = 15


def providers():
    if not DIR.is_dir():
        return []
    return [p for p in sorted(DIR.iterdir())
            if not p.name.startswith(".") and p.is_file() and os.access(p, os.X_OK)]


def call(path, *args):
    r = subprocess.run([str(path), *args], capture_output=True, text=True, timeout=TIMEOUT)
    if r.returncode != 0:
        raise RuntimeError((r.stderr.strip().splitlines() or [f"exit {r.returncode}"])[-1][:200])
    return json.loads(r.stdout)


def list_tasks():
    tasks, errors = [], []
    for p in providers():
        try:
            d = call(p, "tasks")
            label = str(d.get("label") or p.name)
            for t in d.get("tasks", []):
                if not t.get("id") or not t.get("title"):
                    continue
                tasks.append({
                    "source": p.name, "label": label,
                    "id": str(t["id"]), "title": str(t["title"]),
                    "due": str(t.get("due") or ""), "where": str(t.get("where") or ""),
                    "remind": t.get("remind", True) is not False, "open": str(t.get("open") or ""),
                })
        except Exception as e:
            errors.append(f"{p.name}: {e}")
    return {"tasks": tasks, "errors": errors}


def mark(action, name, task_id):
    path = DIR / name
    if "/" in name or path not in providers():
        return {"ok": False, "error": f"no provider {name}"}
    try:
        return call(path, action, task_id)
    except Exception as e:
        return {"ok": False, "error": str(e)}


def main():
    a = sys.argv[1:]
    if a[:1] == ["list"]:
        out = list_tasks()
    elif len(a) == 3 and a[0] in ("done", "undone"):
        out = mark(*a)
    else:
        print(__doc__, file=sys.stderr)
        sys.exit(2)
    print(json.dumps(out, ensure_ascii=False))


if __name__ == "__main__":
    main()
