#!/usr/bin/env python3
"""Teams assignments → the panel's calendar (services/Events.qml).

Usage:
  assignments.py login    sign in to the school account (device code: open the
                          link it prints and type the code), once
  assignments.py sync     read the pending assignments (signed in) and write the calendar
  assignments.py note     a Teams notification on stdin (JSON: {app, summary,
                          body, mail}): if it's about an assignment, keep it
                          (prints {"event": …} with a due date, else {"todo": …})
  assignments.py done UID handed in: the event (uid from Teams.ics) leaves the calendar
  assignments.py undone UID  back (Undo)
  assignments.py status   whether it's signed in, and the last sync

Two sources, one file:
  1. Microsoft Graph (below), once signed in: every assignment with its due time.
     Needs the school to allow it (an administrator's consent).
  2. Teams' own notifications (services/Notifs.qml passes those from Teams, and
     Teams' mails as Thunderbird announces them): "New assignment …", "Fecha de
     entrega mañana: "Proyecto final"", "… due Oct 15 at 11:59 PM"… The title
     is the quoted name (else what follows "assignment:" / "tarea:"), the date
     today / tomorrow / mañana / a weekday / "15 de octubre" / "Oct 15" /
     15/10[/2026], the time "23:59" / "11:59 PM" (default 23:59). Without a
     date it's a to-do instead (the panel adds it). Every one that matched is
     logged to ~/.local/state/quickshell-panel/teams-notes.jsonl, to tune the
     patterns. Graph's list, when there is one, wins over a note of the same name.

Reads the assignments of every class through Microsoft Graph's education API
(delegated, read-only: EduAssignments.ReadBasic, EduRoster.ReadBasic) and
writes ~/.config/lagos/calendars/Teams.ics, which scripts/events.py reads like
any local calendar: one event per assignment not handed in yet, at its due
time, with a reminder a day before (and the class as its place). Handed in,
returned or past due a week: gone from the file.

Signs in as "Microsoft Graph Command Line Tools" (the public client of
Microsoft's Graph PowerShell / CLI, which asks for each permission when
signing in) unless ~/.config/lagos/teams-assignments.json says otherwise:
  {"client_id": "…", "tenant": "organizations"}
The refresh token is kept in ~/.local/state/quickshell-panel/graph-token.json
(only readable by you). Nothing is sent anywhere but Microsoft.
"""
import json
import os
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime, timedelta, timezone
from pathlib import Path

HOME = Path.home()
CONFIG = HOME / ".config/lagos/teams-assignments.json"
TOKEN = HOME / ".local/state/quickshell-panel/graph-token.json"
STATE = HOME / ".local/state/quickshell-panel/assignments.json"
NOTES_LOG = HOME / ".local/state/quickshell-panel/teams-notes.jsonl"
ICS = HOME / ".config/lagos/calendars/Teams.ics"
GRAPH = "https://graph.microsoft.com/v1.0"
SCOPES = "EduAssignments.ReadBasic EduRoster.ReadBasic offline_access"
REMINDER_MIN = 24 * 60          # a day before
KEEP_LATE = timedelta(days=7)   # past due but not handed in: still shown this long


def config():
    c = {"client_id": "14d82eec-204b-4c2f-b7e8-296a70dab67e", "tenant": "organizations"}
    try:
        c.update(json.loads(CONFIG.read_text()))
    except (OSError, ValueError):
        pass
    return c


def post(url, data):
    req = urllib.request.Request(url, urllib.parse.urlencode(data).encode())
    try:
        with urllib.request.urlopen(req, timeout=30) as r:
            return json.load(r)
    except urllib.error.HTTPError as e:
        try:
            return json.load(e)
        except ValueError:
            return {"error": str(e.code), "error_description": e.reason}


def save_token(tok):
    TOKEN.parent.mkdir(parents=True, exist_ok=True)
    tok["expires_at"] = time.time() + int(tok.get("expires_in", 3600)) - 60
    fd = os.open(TOKEN, os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600)
    with os.fdopen(fd, "w") as f:
        json.dump({k: tok[k] for k in ("access_token", "refresh_token", "expires_at") if k in tok}, f)


def login():
    c = config()
    base = f"https://login.microsoftonline.com/{c['tenant']}/oauth2/v2.0"
    dc = post(base + "/devicecode", {"client_id": c["client_id"], "scope": SCOPES})
    if "device_code" not in dc:
        sys.exit("Couldn't start signing in: " + dc.get("error_description", str(dc)))
    print(dc["message"], flush=True)
    deadline = time.time() + int(dc.get("expires_in", 900))
    interval = int(dc.get("interval", 5))
    while time.time() < deadline:
        time.sleep(interval)
        tok = post(base + "/token", {"grant_type": "urn:ietf:params:oauth:grant-type:device_code",
                                     "client_id": c["client_id"], "device_code": dc["device_code"]})
        err = tok.get("error")
        if err == "authorization_pending":
            continue
        if err == "slow_down":
            interval += 5
            continue
        if err:
            sys.exit("Signing in failed: " + tok.get("error_description", err))
        save_token(tok)
        print("Signed in.", flush=True)
        return
    sys.exit("The code expired: run login again.")


def access_token():
    try:
        tok = json.loads(TOKEN.read_text())
    except (OSError, ValueError):
        sys.exit("Not signed in: run `assignments.py login`.")
    if tok.get("expires_at", 0) > time.time():
        return tok["access_token"]
    c = config()
    new = post(f"https://login.microsoftonline.com/{c['tenant']}/oauth2/v2.0/token",
               {"grant_type": "refresh_token", "client_id": c["client_id"],
                "refresh_token": tok.get("refresh_token", ""), "scope": SCOPES})
    if "access_token" not in new:
        sys.exit("Signed out (" + new.get("error_description", new.get("error", "?")).split("\n")[0]
                 + "): run `assignments.py login` again.")
    new.setdefault("refresh_token", tok.get("refresh_token"))
    save_token(new)
    return new["access_token"]


def get_all(path, token):
    url, out = GRAPH + path, []
    while url:
        req = urllib.request.Request(url, headers={"Authorization": "Bearer " + token})
        try:
            with urllib.request.urlopen(req, timeout=30) as r:
                page = json.load(r)
        except urllib.error.HTTPError as e:
            try:
                msg = json.load(e).get("error", {}).get("message", "")
            except ValueError:
                msg = ""
            raise RuntimeError(f"{path}: HTTP {e.code} {msg}".strip())
        out += page.get("value", [])
        url = page.get("@odata.nextLink")
    return out


def esc(s):
    return (str(s or "").replace("\\", "\\\\").replace(";", "\\;").replace(",", "\\,")
            .replace("\r", "").replace("\n", "\\n"))


def fold(line):
    # iCalendar lines: at most 75 octets, continued with a leading space
    out, b = [], line.encode()
    while len(b) > 75:
        cut = 75
        while cut > 0 and (b[cut] & 0xC0) == 0x80:      # not inside a UTF-8 character
            cut -= 1
        out.append(b[:cut].decode())
        b = b" " + b[cut:]
    out.append(b.decode())
    return "\r\n".join(out)


def plain(html):
    import html as h
    import re
    t = re.sub(r"<br\s*/?>|</p>|</div>|</li>", "\n", str(html or ""), flags=re.I)
    return h.unescape(re.sub(r"<[^>]+>", "", t)).strip()


def utc(s):
    return datetime.fromisoformat(s.replace("Z", "+00:00")).astimezone(timezone.utc)


def load_state():
    try:
        return json.loads(STATE.read_text())
    except (OSError, ValueError):
        return {}


def save_state(st):
    STATE.parent.mkdir(parents=True, exist_ok=True)
    tmp = STATE.with_suffix(".tmp")
    tmp.write_text(json.dumps(st, ensure_ascii=False))
    tmp.replace(STATE)


def sync():
    st = load_state()
    if TOKEN.exists():
        token = access_token()
        classes = {c["id"]: c.get("displayName", "") for c in get_all("/education/me/classes", token)}
        now = datetime.now(timezone.utc)
        graph = []
        for a in get_all("/education/me/assignments?$expand=submissions", token):
            due = a.get("dueDateTime")
            if not due or a.get("status") not in (None, "assigned"):
                continue
            subs = a.get("submissions") or []
            state = subs[0].get("status", "") if subs else ""
            if state in ("submitted", "returned") or utc(due) < now - KEEP_LATE:
                continue
            graph.append({"id": a["id"], "title": a.get("displayName", "Assignment"), "due": utc(due).isoformat(),
                          "class": classes.get(a.get("classId"), ""), "url": a.get("webUrl", ""),
                          "notes": "\n\n".join(x for x in [plain((a.get("instructions") or {}).get("content")),
                                                            "Reassigned" if state == "reassigned" else ""] if x)})
        st["graph"] = graph
        st["synced"] = now.isoformat()
    render(st)
    save_state(st)
    print(f"{len(st.get('graph', []))} from Teams, {len(st.get('notes', []))} from notifications")


def render(st):
    """Teams.ics from Graph's assignments and the notes (not past due a week)."""
    now = datetime.now(timezone.utc)
    hidden = set(st.get("hidden", []))
    graph = [g for g in st.get("graph", []) if "teams-" + g["id"] not in hidden]
    names = {g["title"].strip().lower() for g in graph}
    notes = [n for n in st.get("notes", []) if n["title"].strip().lower() not in names]
    st["notes"] = [n for n in st.get("notes", []) if utc(n["due"]) >= now - KEEP_LATE]
    items = [dict(g, uid="teams-" + g["id"]) for g in graph] + \
            [dict(n, uid="teams-note-" + n["key"]) for n in notes
             if utc(n["due"]) >= now - KEEP_LATE and "teams-note-" + n["key"] not in hidden]
    stamp = now.strftime("%Y%m%dT%H%M%SZ")
    lines = ["BEGIN:VCALENDAR", "VERSION:2.0", "PRODID:-//lagos//panel teams assignments//EN",
             "X-WR-CALNAME:Teams"]
    for it in sorted(items, key=lambda i: i["due"]):
        when = utc(it["due"]).strftime("%Y%m%dT%H%M%SZ")
        notes = "\n\n".join(x for x in [it.get("notes", ""), it.get("url", "")] if x)
        lines += ["BEGIN:VEVENT", f"UID:{it['uid']}", f"DTSTAMP:{stamp}",
                  f"DTSTART:{when}", f"DTEND:{when}",
                  fold("SUMMARY:" + esc("Entrega: " + it["title"])),
                  fold("LOCATION:" + esc(it.get("class", ""))) if it.get("class") else None,
                  fold("DESCRIPTION:" + esc(notes)) if notes else None,
                  fold("URL:" + it["url"]) if it.get("url") else None,
                  "BEGIN:VALARM", "ACTION:DISPLAY", "DESCRIPTION:Entrega",
                  f"TRIGGER:-PT{REMINDER_MIN}M", "END:VALARM", "END:VEVENT"]
    lines.append("END:VCALENDAR")
    text = "\r\n".join(l for l in lines if l) + "\r\n"
    ICS.parent.mkdir(parents=True, exist_ok=True)
    old = ICS.read_text() if ICS.exists() else ""
    # Only the stamps differ: leave the file (and the calendar) alone
    strip = lambda t: "\n".join(l for l in t.splitlines() if not l.startswith("DTSTAMP"))
    if strip(old) != strip(text):
        tmp = ICS.with_suffix(".tmp")
        tmp.write_text(text)
        tmp.replace(ICS)


# ---------------- Notes: assignments from Teams' notifications ----------------
TASK = re.compile(r"\b(assignment|tarea|asignaci[oó]n|entrega|deliverable)\b", re.I)
# A notification that announces one, not a chat message that mentions homework
ANNOUNCE = re.compile(r"(new assignment|assignment (is )?due|due (today|tomorrow|on|by)|\bdue\b.*\d|"
                      r"(nueva|nuevo) (tarea|asignaci[oó]n)|tarea nueva|se (te )?(ha )?asign|"
                      r"fecha de entrega|vence|para entregar|entrega (hoy|mañana|el)|"
                      r"assigned (you|a new)|posted (a|an) (new )?assignment|public[oó] una tarea)", re.I)
DUE = re.compile(r"\b(is due|due (today|tomorrow|on|by|this|next|mon|tue|wed|thu|fri|sat|sun)|vence (hoy|mañana|el)|"
                 r"fecha (de|l[ií]mite de) entrega)", re.I)
MONTHS = {m: i + 1 for i, names in enumerate([
    ("enero", "january", "jan", "ene"), ("febrero", "february", "feb"), ("marzo", "march", "mar"),
    ("abril", "april", "apr", "abr"), ("mayo", "may"), ("junio", "june", "jun"), ("julio", "july", "jul"),
    ("agosto", "august", "aug", "ago"), ("septiembre", "setiembre", "september", "sep", "sept", "set"),
    ("octubre", "october", "oct"), ("noviembre", "november", "nov"), ("diciembre", "december", "dec", "dic"),
]) for m in names}
WEEKDAYS = {d: i for i, names in enumerate([
    ("lunes", "monday", "mon", "lun"), ("martes", "tuesday", "tue", "mar"), ("miércoles", "miercoles", "wednesday", "wed", "mié", "mie"),
    ("jueves", "thursday", "thu", "jue"), ("viernes", "friday", "fri", "vie"), ("sábado", "sabado", "saturday", "sat", "sáb", "sab"),
    ("domingo", "sunday", "sun", "dom"),
]) for d in names}


def title_of(text):
    m = re.search(r"[\"“«']([^\"”»']{3,120})[\"”»']", text)
    if m:
        return m.group(1).strip()
    m = re.search(r"(?:assignment|tarea|asignaci[oó]n)\s*(?:nueva)?\s*[:\-–]\s*(.{3,120}?)(?:\s*[·|\n]|\s+(?:due|vence|para el|fecha)\b|$)", text, re.I)
    return m.group(1).strip(" .") if m else ""


def due_of(text, now):
    """The due moment in local time, or None."""
    t = text.lower()
    day = None
    m = re.search(r"\b(hoy|today|mañana|manana|tomorrow)\b", t)
    if m:
        day = now.date() + timedelta(days=0 if m.group(1) in ("hoy", "today") else 1)
    if day is None:
        m = re.search(r"\b(\d{1,2})\s*(?:de\s+)?([a-záéíóú]{3,10})\.?(?:\s*(?:de|,)?\s*(\d{4}))?\b", t)
        if m and m.group(2) in MONTHS:
            day = (int(m.group(1)), MONTHS[m.group(2)], int(m.group(3)) if m.group(3) else None)
        else:
            m = re.search(r"\b([a-z]{3,10})\.?\s+(\d{1,2})(?:st|nd|rd|th)?(?:,?\s*(\d{4}))?\b", t)
            if m and m.group(1) in MONTHS:
                day = (int(m.group(2)), MONTHS[m.group(1)], int(m.group(3)) if m.group(3) else None)
            else:
                m = re.search(r"\b(\d{1,2})/(\d{1,2})(?:/(\d{2,4}))?\b", t)
                if m:
                    y = m.group(3)
                    day = (int(m.group(1)), int(m.group(2)), (int(y) + 2000 if len(y) == 2 else int(y)) if y else None)
        if isinstance(day, tuple):
            d, mo, y = day
            try:
                cand = datetime(y or now.year, mo, d).date()
                if not y and cand < now.date() - timedelta(days=60):
                    cand = cand.replace(year=now.year + 1)     # "Jan 10" said in December
                day = cand
            except ValueError:
                day = None
    if day is None:
        m = re.search(r"\b(?:el|on|this|este|next|próximo|proximo)?\s*(" + "|".join(sorted(WEEKDAYS, key=len, reverse=True)) + r")\b", t)
        if m and re.search(r"due|vence|entrega|para el", t):
            ahead = (WEEKDAYS[m.group(1)] - now.weekday()) % 7 or 7
            day = now.date() + timedelta(days=ahead)
    if day is None:
        return None
    hh, mm = 23, 59
    m = re.search(r"\b(\d{1,2}):(\d{2})\s*(a\.?\s*m\.?|p\.?\s*m\.?|am|pm)?", t)
    if m:
        hh, mm = int(m.group(1)), int(m.group(2))
        ap = (m.group(3) or "").replace(".", "").replace(" ", "")
        if ap == "pm" and hh < 12:
            hh += 12
        elif ap == "am" and hh == 12:
            hh = 0
    try:
        return datetime(day.year, day.month, day.day, hh, mm).astimezone()
    except ValueError:
        return None


def note():
    try:
        n = json.load(sys.stdin)
    except ValueError:
        sys.exit("note: JSON on stdin")
    text = " · ".join(str(n.get(k) or "") for k in ("summary", "body"))
    text = re.sub(r"<[^>]+>", " ", text)
    # About an assignment and announcing it; or just something due ("Lab report
    # is due Friday"): better one reminder too many than one forgotten
    if not ((TASK.search(text) and ANNOUNCE.search(text)) or DUE.search(text)):
        print("{}")
        return
    now = datetime.now().astimezone()
    body = re.sub(r"<[^>]+>", " ", str(n.get("body") or "")).strip()
    # "Lab report is due Friday": what comes before "is due" / "vence"
    m = re.match(r"(.{3,100}?)\s+(?:is due|due|vence|se entrega)\b", body, re.I)
    title = title_of(text) or (m.group(1).strip(" .:") if m else "") \
        or re.sub(r"\s+", " ", str(n.get("summary") or "Tarea de Teams")).strip()[:100]
    due = due_of(text, now)
    NOTES_LOG.parent.mkdir(parents=True, exist_ok=True)
    with open(NOTES_LOG, "a") as f:
        f.write(json.dumps({"at": now.isoformat(), "in": n, "title": title,
                            "due": due.isoformat() if due else None}, ensure_ascii=False) + "\n")
    if not due:
        print(json.dumps({"todo": title}, ensure_ascii=False))
        return
    st = load_state()
    key = re.sub(r"[^a-z0-9]+", "-", title.lower()).strip("-")[:60] or "tarea"
    notes = [x for x in st.get("notes", []) if x["key"] != key]
    notes.append({"key": key, "title": title, "due": due.astimezone(timezone.utc).isoformat(),
                  "class": "", "notes": text.strip()[:500], "url": ""})
    st["notes"] = notes
    render(st)
    save_state(st)
    print(json.dumps({"event": title, "due": due.isoformat()}, ensure_ascii=False))


def done(uid, handed_in=True):
    """Handed in: the event (its uid in Teams.ics) leaves the calendar; undone: back."""
    st = load_state()
    hidden = set(st.get("hidden", []))
    hidden = hidden | {uid} if handed_in else hidden - {uid}
    # Forget the ones neither source has anymore
    alive = {"teams-" + g["id"] for g in st.get("graph", [])} | {"teams-note-" + n["key"] for n in st.get("notes", [])}
    st["hidden"] = sorted(hidden & alive)
    render(st)
    save_state(st)


def status():
    st = load_state()
    print(json.dumps({"signedIn": TOKEN.exists(), "synced": st.get("synced"),
                      "fromTeams": len(st.get("graph", [])), "fromNotifications": len(st.get("notes", []))}))


def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else ""
    if cmd == "login":
        login()
    elif cmd == "sync":
        try:
            sync()
        except (RuntimeError, urllib.error.URLError) as e:
            sys.exit(str(e))
    elif cmd == "done" and len(sys.argv) > 2:
        done(sys.argv[2])
    elif cmd == "undone" and len(sys.argv) > 2:
        done(sys.argv[2], False)
    elif cmd == "note":
        note()
    elif cmd == "status":
        status()
    else:
        sys.exit(__doc__)


if __name__ == "__main__":
    main()
