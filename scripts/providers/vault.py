#!/usr/bin/env python3
"""Obsidian vault → the panel's deadlines (a task provider, see the panel's
scripts/providers.py). Linked to ~/.config/lagos/providers/vault by install.sh.

Usage (called by the panel):
  vault.py tasks         open tasks with a due date, and today's gym session
  vault.py done ID       check it off in its note / log the gym session
  vault.py undone ID     back (Undo)

Tasks: every `- [ ] … [due:: YYYY-MM-DD]` (optionally `[due:: YYYY-MM-DD HH:MM]`)
in the vault, outside 82_Templates. The title drops the #task/… tag and the
due field; `where` is the course (90_Logs/Academia/<term>/<Course>/…) or the
note's folder; a click opens the note in Obsidian. Done checks the box in the
note (the same line, found again by its text).

Gym: on a training day (the 9th-semester weekly routine below), "Gym · <day>"
for today, quiet (no reminders: missing it is not a failure). Done adds a row
to the year's log, 90_Logs/Health/Gym/Gym_Log_<year>.md, with an empty Notes
cell (write "min" there for a 40–45 min compressed session, weights, how it
felt). A click opens the split's note.

Optional ~/.config/lagos/vault.json overrides the defaults:
  {"path": "~/Documents/my-cs-notes",
   "gym": {"days": {"mon": "Upper", …}, "log_dir": "90_Logs/Health/Gym",
           "split_note": "45_…/5_Day_Hybrid_ULxPPL_Split"}}
"""
import hashlib
import json
import os
import re
import sys
import urllib.parse
from datetime import date
from pathlib import Path

CONFIG = Path.home() / ".config/lagos/vault.json"
DEFAULTS = {
    "path": "~/Documents/my-cs-notes",
    "skip": [".obsidian", ".trash", ".git", "82_Templates"],
    "gym": {
        "days": {"mon": "Upper", "tue": "Lower (quad focus)", "thu": "Push",
                 "fri": "Pull", "sat": "Legs (posterior chain)"},
        "log_dir": "90_Logs/Health/Gym",
        "split_note": "45_Bio_Hardware_and_Performance/03_Training_and_Hypertrophy/5_Day_Hybrid_ULxPPL_Split",
    },
}
WEEKDAYS = ["mon", "tue", "wed", "thu", "fri", "sat", "sun"]

TASK = re.compile(r"^(\s*[-*] )\[( |x|X)\] (.*)$")
DUE = re.compile(r"\[due::\s*(\d{4}-\d{2}-\d{2})(?:[ T](\d{2}:\d{2}))?\s*\]")


def config():
    c = json.loads(json.dumps(DEFAULTS))
    try:
        user = json.loads(CONFIG.read_text())
        c["gym"].update(user.pop("gym", {}))
        c.update(user)
    except (OSError, ValueError):
        pass
    c["root"] = Path(os.path.expanduser(c["path"]))
    return c


def note_url(root, rel):
    """obsidian:// link to a note (rel without .md)."""
    return "obsidian://open?" + urllib.parse.urlencode(
        {"vault": root.name, "file": rel}, quote_via=urllib.parse.quote)


def line_id(rel, line):
    """A task's id: its note and its text with the box unchecked (so done / undone still find it)."""
    text = TASK.sub(r"\1[ ] \3", line.rstrip("\n"))
    return rel + "#" + hashlib.sha1(text.encode()).hexdigest()[:10]


def clean_title(text):
    text = DUE.sub("", text)
    text = re.sub(r"#task/\S+", "", text)
    text = re.sub(r"\s*→\s*\[\[[^\]]+\]\]\s*$", "", text.strip())   # "… → [[Its_Note]]": the note it leads to
    text = re.sub(r"\[\[([^\]|]+)\|([^\]]+)\]\]", r"\2", text)     # [[note|alias]] → alias
    text = re.sub(r"\[\[([^\]]+)\]\]", lambda m: m.group(1).replace("_", " "), text)
    text = re.sub(r"`|\*\*?", "", text)
    return re.sub(r"\s+", " ", text).strip(" .:")


def where_of(rel):
    parts = rel.split("/")
    if len(parts) > 4 and parts[0] == "90_Logs" and parts[1] == "Academia":
        return parts[3].replace("_", " ")
    return parts[-2].replace("_", " ") if len(parts) > 1 else ""


def notes(c):
    root = c["root"]
    for dirpath, dirs, files in os.walk(root):
        dirs[:] = [d for d in dirs if d not in c["skip"] and not d.startswith(".")]
        for f in files:
            if f.endswith(".md"):
                p = Path(dirpath) / f
                yield p, p.relative_to(root).as_posix()


def vault_tasks(c):
    out = []
    for path, rel in notes(c):
        try:
            text = path.read_text(encoding="utf-8")
        except (OSError, UnicodeDecodeError):
            continue
        if "[due::" not in text:
            continue
        for line in text.splitlines():
            m = TASK.match(line)
            if not m or m.group(2) != " ":
                continue
            d = DUE.search(m.group(3))
            if not d:
                continue
            title = clean_title(m.group(3))
            if not title:
                continue
            out.append({
                "id": line_id(rel, line), "title": title,
                "due": d.group(1) + ("T" + d.group(2) if d.group(2) else ""),
                "where": where_of(rel), "open": note_url(c["root"], rel[:-3]),
            })
    return out


# ---------------------------------------------------------------- gym

def gym_log(c, day):
    return c["root"] / c["gym"]["log_dir"] / f"Gym_Log_{day.year}.md"


def gym_today(c, day):
    """Today's session name, or None on a rest day."""
    return c["gym"]["days"].get(WEEKDAYS[day.weekday()])


def gym_logged(c, day):
    try:
        return f"| {day.isoformat()} |" in gym_log(c, day).read_text(encoding="utf-8")
    except OSError:
        return False


def gym_task(c):
    today = date.today()
    session = gym_today(c, today)
    if not session or gym_logged(c, today):
        return []
    return [{"id": "gym:" + today.isoformat(), "title": "Gym · " + session, "due": today.isoformat(),
             "where": "07:15", "remind": False, "open": note_url(c["root"], c["gym"]["split_note"])}]


def gym_mark(c, day, done):
    log = gym_log(c, day)
    session = gym_today(c, day) or "Session"
    try:
        text = log.read_text(encoding="utf-8")
    except OSError:
        text = (f"---\ntags: [training, gym_log]\n---\n# 🏋️ Gym Log {day.year}\n\n"
                "One row per session, added from the panel. Notes: `min` for a compressed\n"
                "40–45 min session, top sets, how it felt.\n\n"
                "| Date | Day | Session | Notes |\n| :--- | :-- | :------ | :---- |\n")
    row = f"| {day.isoformat()} | {day.strftime('%a')} | {session.split(' (')[0]} |  |"
    if done:
        if f"| {day.isoformat()} |" in text:
            return {"ok": True}
        # In date order (a session logged a day late goes before the later ones)
        lines = text.rstrip("\n").split("\n")
        at = next((i for i, l in enumerate(lines) if re.match(r"\| \d{4}-\d{2}-\d{2} \|", l)
                   and l[2:12] > day.isoformat()), len(lines))
        lines.insert(at, row)
        text = "\n".join(lines) + "\n"
    else:
        # Only the row the panel added (Notes still empty)
        lines = text.splitlines()
        if row not in lines:
            return {"ok": False, "error": "the log's row was already edited"}
        lines.remove(row)
        text = "\n".join(lines) + "\n"
    log.parent.mkdir(parents=True, exist_ok=True)
    write(log, text)
    return {"ok": True}


# ---------------------------------------------------------------- done / undone

def write(path, text):
    tmp = path.with_name("." + path.name + ".tmp")
    tmp.write_text(text, encoding="utf-8")
    os.replace(tmp, path)


def mark(c, task_id, done):
    if task_id.startswith("gym:"):
        try:
            return gym_mark(c, date.fromisoformat(task_id[4:]), done)
        except ValueError:
            return {"ok": False, "error": "bad gym id"}
    rel = task_id.rsplit("#", 1)[0]
    path = (c["root"] / rel).resolve()
    if c["root"].resolve() not in path.parents or path.suffix != ".md":
        return {"ok": False, "error": "not a note in the vault"}
    try:
        text = path.read_text(encoding="utf-8")
    except OSError as e:
        return {"ok": False, "error": str(e)}
    lines = text.split("\n")
    for i, line in enumerate(lines):
        m = TASK.match(line)
        if m and line_id(rel, line) == task_id:
            lines[i] = f"{m.group(1)}[{'x' if done else ' '}] {m.group(3)}"
            write(path, "\n".join(lines))
            return {"ok": True}
    return {"ok": False, "error": "the task changed in its note"}


def main():
    a = sys.argv[1:]
    c = config()
    if not c["root"].is_dir():
        print(f"no vault at {c['root']}", file=sys.stderr)
        sys.exit(1)
    if a == ["tasks"]:
        out = {"label": "Vault", "tasks": gym_task(c) + vault_tasks(c)}
    elif len(a) == 2 and a[0] in ("done", "undone"):
        out = mark(c, a[1], a[0] == "done")
    else:
        print(__doc__, file=sys.stderr)
        sys.exit(2)
    print(json.dumps(out, ensure_ascii=False))


if __name__ == "__main__":
    main()
