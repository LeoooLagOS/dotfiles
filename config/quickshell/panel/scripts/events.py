#!/usr/bin/env python3
"""Calendar events for the panel (Calendar zone, Calendar tab, reminders).

Usage:
  events.py list FROM TO [--force]   events between two dates (YYYY-MM-DD, inclusive)
  events.py add                      create a local event; JSON on stdin:
                                     {title, date, start, end, allDay, location, notes, reminder}
  events.py delete UID               delete a local event

`list` prints JSON: {"events": [...], "sources": N, "errors": [...]}; each event:
  {uid, date, start, end, startIso, allDay, title, location, notes, calendar,
   source ("outlook" | "local"), important, high, reminder (minutes, 0 = none)}

Sources (no URLs are stored in the dotfiles repo):
  1. Evolution webcal subscriptions (~/.config/evolution/sources/*.source) —
     e.g. the published Outlook calendar. The URL is read at runtime and the .ics
     is cached in ~/.cache/quickshell-panel/ for CACHE_TTL (--force skips it).
     These events are treated as important and get a 15-minute reminder
     (published Outlook calendars don't include their alarms). Outlook's
     "High importance" (X-MICROSOFT-CDO-IMPORTANCE:2) is reported as `high`.
  2. Local .ics files in ~/.config/lagos/calendars/. Events created from the
     panel go to panel.ics there; their reminder comes from their VALARM.

Runs inside ~/.local/share/quickshell-panel/venv (icalendar,
recurring-ical-events) so recurring events and timezones are expanded.
"""

import configparser
import json
import sys
import time
import urllib.request
import uuid
from datetime import date, datetime, timedelta, timezone
from pathlib import Path

import icalendar
import recurring_ical_events

HOME = Path.home()
EVO_SOURCES = HOME / ".config/evolution/sources"
LOCAL_DIR = HOME / ".config/lagos/calendars"
PANEL_ICS = LOCAL_DIR / "panel.ics"
CACHE_DIR = HOME / ".cache/quickshell-panel"
CACHE_TTL = 15 * 60
OUTLOOK_REMINDER = 15  # minutes


# ---------------------------------------------------------------- sources

def webcal_sources():
    """(name, url, cache_file) for each enabled Evolution webcal calendar."""
    out = []
    for f in sorted(EVO_SOURCES.glob("*.source")):
        cp = configparser.ConfigParser(interpolation=None, strict=False)
        try:
            cp.read(f, encoding="utf-8")
        except configparser.Error:
            continue
        if cp.get("Calendar", "BackendName", fallback="") != "webcal":
            continue
        if cp.get("Data Source", "Enabled", fallback="true") != "true":
            continue
        host = cp.get("Authentication", "Host", fallback="")
        path = cp.get("WebDAV Backend", "ResourcePath", fallback="") or cp.get(
            "Authentication", "ResourcePath", fallback="")
        uri = cp.get("WebDAV Backend", "Uri", fallback="")
        if not uri and host and path:
            uri = f"https://{host}{path}"
        uri = uri.replace("webcal://", "https://")
        if uri:
            name = cp.get("Data Source", "DisplayName", fallback=f.stem)
            out.append((name, uri, CACHE_DIR / f"{f.stem}.ics"))
    return out


def fetch(url, cache_file, errors, force=False):
    """Return .ics bytes, refreshing the cache when stale (or forced)."""
    fresh = cache_file.exists() and time.time() - cache_file.stat().st_mtime < CACHE_TTL
    if force or not fresh:
        try:
            req = urllib.request.Request(url, headers={"User-Agent": "quickshell-panel"})
            with urllib.request.urlopen(req, timeout=15) as r:
                data = r.read()
            CACHE_DIR.mkdir(parents=True, exist_ok=True)
            cache_file.write_bytes(data)
            cache_file.chmod(0o600)
        except Exception as e:  # offline: fall back to the stale cache
            errors.append(f"{cache_file.stem}: {type(e).__name__}")
    return cache_file.read_bytes() if cache_file.exists() else None


# ---------------------------------------------------------------- list

def to_local(value):
    """date stays a date; aware datetimes are converted to local time."""
    if isinstance(value, datetime):
        return value.astimezone() if value.tzinfo else value
    return value


def reminder_minutes(ev):
    """Minutes before start from the first relative VALARM, else 0."""
    for alarm in ev.walk("VALARM"):
        trig = alarm.get("TRIGGER")
        if trig is not None and isinstance(trig.dt, timedelta):
            return max(0, int(-trig.dt.total_seconds() // 60))
    return 0


def cmd_list(start, end, force):
    end = end + timedelta(days=1)  # inclusive
    errors, calendars = [], []

    for name, url, cache in webcal_sources():
        data = fetch(url, cache, errors, force)
        if data:
            calendars.append((name, "outlook", data))
    if LOCAL_DIR.is_dir():
        for f in sorted(LOCAL_DIR.glob("*.ics")):
            calendars.append(("Panel" if f == PANEL_ICS else f.stem, "local", f.read_bytes()))

    events = []
    for name, source, data in calendars:
        try:
            cal = icalendar.Calendar.from_ical(data)
            occurrences = recurring_ical_events.of(cal).between(start, end)
        except Exception as e:
            errors.append(f"{name}: {type(e).__name__}")
            continue
        for ev in occurrences:
            s = to_local(ev.get("DTSTART").dt)
            e = to_local(ev.get("DTEND").dt) if ev.get("DTEND") else s
            all_day = not isinstance(s, datetime)
            importance = int(str(ev.get("X-MICROSOFT-CDO-IMPORTANCE", 1)) or 1)
            outlook = source == "outlook"
            base = {
                "uid": str(ev.get("UID", "")),
                "start": "" if all_day else s.strftime("%H:%M"),
                "end": "" if all_day else e.strftime("%H:%M"),
                "startIso": "" if all_day else s.isoformat(),
                "allDay": all_day,
                "title": str(ev.get("SUMMARY", "")).strip() or "(no title)",
                "location": str(ev.get("LOCATION", "")).strip(),
                "notes": str(ev.get("DESCRIPTION", "")).strip()[:300],
                "calendar": name,
                "source": source,
                "important": outlook or importance >= 2,
                "high": importance >= 2,
                "reminder": OUTLOOK_REMINDER if outlook else reminder_minutes(ev),
            }
            # All-day events spanning several days appear on each day
            day = s if all_day else s.date()
            last = (e - timedelta(days=1)) if all_day and e > s else (e.date() if not all_day else s)
            while day <= last:
                if start <= day < end:
                    events.append(dict(base, date=day.isoformat()))
                day += timedelta(days=1)

    events.sort(key=lambda x: (x["date"], not x["allDay"], x["start"]))
    print(json.dumps({"events": events, "sources": len(calendars), "errors": errors}))


# ---------------------------------------------------------------- add / delete

def load_panel_calendar():
    if PANEL_ICS.exists():
        return icalendar.Calendar.from_ical(PANEL_ICS.read_bytes())
    cal = icalendar.Calendar()
    cal.add("prodid", "-//lagos//quickshell-panel//EN")
    cal.add("version", "2.0")
    cal.add("x-wr-calname", "Panel")
    return cal


def save_panel_calendar(cal):
    LOCAL_DIR.mkdir(parents=True, exist_ok=True)
    tmp = PANEL_ICS.with_suffix(".tmp")
    tmp.write_bytes(cal.to_ical())
    tmp.replace(PANEL_ICS)


def cmd_add(spec):
    title = (spec.get("title") or "").strip()
    if not title:
        raise ValueError("title is required")
    day = date.fromisoformat(spec["date"])
    ev = icalendar.Event()
    ev.add("uid", f"{uuid.uuid4()}@quickshell-panel")
    ev.add("dtstamp", datetime.now(timezone.utc))
    ev.add("summary", title)
    if spec.get("location"):
        ev.add("location", spec["location"].strip())
    if spec.get("notes"):
        ev.add("description", spec["notes"].strip())

    if spec.get("allDay"):
        ev.add("dtstart", day)
        ev.add("dtend", day + timedelta(days=1))
    else:
        local_tz = datetime.now().astimezone().tzinfo
        sh, sm = map(int, spec["start"].split(":"))
        start = datetime(day.year, day.month, day.day, sh, sm, tzinfo=local_tz)
        if spec.get("end"):
            eh, em = map(int, spec["end"].split(":"))
            end = datetime(day.year, day.month, day.day, eh, em, tzinfo=local_tz)
            if end <= start:
                end += timedelta(days=1)          # ends after midnight
        else:
            end = start + timedelta(hours=1)
        # Stored in UTC: unambiguous for any reader
        ev.add("dtstart", start.astimezone(timezone.utc))
        ev.add("dtend", end.astimezone(timezone.utc))

    minutes = int(spec.get("reminder") or 0)
    if minutes > 0 and not spec.get("allDay"):
        alarm = icalendar.Alarm()
        alarm.add("action", "DISPLAY")
        alarm.add("description", title)
        alarm.add("trigger", timedelta(minutes=-minutes))
        ev.add_component(alarm)

    cal = load_panel_calendar()
    cal.add_component(ev)
    save_panel_calendar(cal)
    print(json.dumps({"ok": True, "uid": str(ev["uid"])}))


def cmd_delete(uid):
    cal = load_panel_calendar()
    kept = [c for c in cal.subcomponents if not (c.name == "VEVENT" and str(c.get("UID")) == uid)]
    removed = len(cal.subcomponents) - len(kept)
    cal.subcomponents[:] = kept
    save_panel_calendar(cal)
    print(json.dumps({"ok": removed > 0}))


def main():
    args = sys.argv[1:]
    try:
        if args and args[0] == "add":
            cmd_add(json.load(sys.stdin))
        elif args and args[0] == "delete":
            cmd_delete(args[1])
        else:
            if args and args[0] == "list":
                args = args[1:]
            force = "--force" in args
            args = [a for a in args if a != "--force"]
            cmd_list(date.fromisoformat(args[0]), date.fromisoformat(args[1]), force)
    except Exception as e:
        print(json.dumps({"ok": False, "error": f"{type(e).__name__}: {e}", "events": [], "errors": [str(e)]}))


if __name__ == "__main__":
    main()
