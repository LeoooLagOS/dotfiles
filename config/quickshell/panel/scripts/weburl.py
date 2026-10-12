#!/usr/bin/env python3
"""The page behind a browser window's title, for the bar (services/WebPages.qml),
as JSON.

  weburl.py APP_ID TITLE

Browsers don't tell the compositor their URL, only the page's title; their
own files say which URL has that title:
  Firefox family (Firefox, LibreWolf, Zen, Floorp, Waterfox): the session
      (sessionstore-backups/recovery.jsonlz4, rewritten every ~15 s: every
      open tab's title and URL), else the history (places.sqlite); icons from
      favicons.sqlite
  Chromium family (Brave, Chrome, Chromium, Vivaldi, Edge, Opera, Thorium):
      the history (History: the latest visit with that title, any profile);
      icons from Favicons
Native and Flatpak installs. Databases are read from copies (the browser
keeps them locked). A site's icon is saved once in ~/.cache/quickshell-panel/favicons.
Prints {"url", "domain", "title" (the page's), "icon": path or "",
"search": a search results page}, or {"none": true} (not found yet: a page
just opened; a browser's own page; not a browser).
"""

import configparser
import json
import re
import shutil
import sqlite3
import sys
import tempfile
from pathlib import Path
from urllib.parse import parse_qs, urlsplit

HOME = Path.home()
CACHE = HOME / ".cache/quickshell-panel/favicons"

# app id (regex) → where its profiles live
FIREFOX = [
    (r"firefox", [".config/mozilla/firefox", ".mozilla/firefox",
                  ".var/app/org.mozilla.firefox/config/mozilla/firefox", ".var/app/org.mozilla.firefox/.mozilla/firefox"]),
    (r"librewolf", [".librewolf", ".config/librewolf/librewolf", ".var/app/io.gitlab.librewolf-community/.librewolf"]),
    (r"zen", [".zen", ".config/zen", ".var/app/app.zen_browser.zen/.zen"]),
    (r"floorp", [".floorp", ".var/app/one.ablaze.floorp/.floorp"]),
    (r"waterfox", [".waterfox", ".var/app/net.waterfox.waterfox/.waterfox"]),
]
CHROMIUM = [
    (r"brave", [".config/BraveSoftware/Brave-Browser", ".var/app/com.brave.Browser/config/BraveSoftware/Brave-Browser"]),
    (r"chrome", [".config/google-chrome", ".var/app/com.google.Chrome/config/google-chrome"]),
    (r"chromium", [".config/chromium", ".var/app/org.chromium.Chromium/config/chromium"]),
    (r"vivaldi", [".config/vivaldi", ".var/app/com.vivaldi.Vivaldi/config/vivaldi"]),
    (r"edge", [".config/microsoft-edge", ".var/app/com.microsoft.Edge/config/microsoft-edge"]),
    (r"opera", [".config/opera", ".var/app/com.opera.Opera/config/opera"]),
    (r"thorium", [".config/thorium"]),
]

# Search results pages: the browser's own icon fits them better than the engine's
SEARCH = [
    (r"(^|\.)google\.[a-z.]+$", r"^/search"), (r"(^|\.)bing\.com$", r"^/search"),
    (r"(^|\.)duckduckgo\.com$", None), (r"^search\.brave\.com$", None),
    (r"(^|\.)startpage\.com$", r"^/(do/|sp/)?search"), (r"(^|\.)ecosia\.org$", r"^/search"),
    (r"(^|\.)yandex\.[a-z.]+$", r"^/search"), (r"^search\.yahoo\.com$", r"^/search"),
    (r"(^|\.)kagi\.com$", r"^/search"), (r"(^|\.)qwant\.com$", None), (r"^search\.marginalia\.nu$", None),
]


def copy_db(src, tmp):
    """A copy of an SQLite file (with its WAL / journal), opened."""
    for suffix in ("", "-wal", "-journal"):
        f = Path(str(src) + suffix)
        if f.exists():
            shutil.copy(f, Path(tmp) / f.name)
    return sqlite3.connect(Path(tmp) / Path(src).name)


def candidates(title):
    """The title whole, then without each ending: browsers add their name
    (" — Mozilla Firefox", " - Brave") and Firefox the profile's (" — Work")."""
    out, t = [title], title
    while True:
        m = re.match(r"^(.*\S)\s+[—–-]\s+[^—–-]*$", t)
        if not m:
            return out
        t = m.group(1)
        out.append(t)


# ---------------- Firefox family ----------------

def ff_profiles(dirs):
    """Profiles by preference: each install's default (installs.ini), the
    Default=1 one (profiles.ini), then the rest."""
    seen = []
    for d in dirs:
        root = HOME / d
        if not root.is_dir():
            continue
        for name, key in (("installs.ini", "Default"), ("profiles.ini", "Path")):
            ini = configparser.ConfigParser()
            try:
                ini.read(root / name)
            except configparser.Error:
                continue
            for sec in ini.sections():
                if name == "profiles.ini" and ini[sec].get("Default") != "1":
                    continue
                p = ini[sec].get(key)
                if p and (root / p).is_dir() and root / p not in seen:
                    seen.append(root / p)
        seen += [p for p in root.iterdir() if (p / "places.sqlite").exists() and p not in seen]
    return seen


def unlz4(src, size):
    """An LZ4 block (what mozlz4 wraps after its 12-byte header)."""
    out = bytearray()
    i, n = 0, len(src)
    while i < n:
        token = src[i]
        i += 1
        lit = token >> 4
        if lit == 15:
            while True:
                b = src[i]
                i += 1
                lit += b
                if b != 255:
                    break
        out += src[i:i + lit]
        i += lit
        if i >= n:
            break
        off = src[i] | src[i + 1] << 8
        i += 2
        mlen = token & 15
        if mlen == 15:
            while True:
                b = src[i]
                i += 1
                mlen += b
                if b != 255:
                    break
        mlen += 4
        start = len(out) - off
        if off >= mlen:
            out += out[start:start + mlen]
        else:                                   # overlapping: repeats the last `off` bytes
            chunk = out[start:]
            out += (chunk * (mlen // off + 1))[:mlen]
    return bytes(out[:size])


def ff_session(prof):
    for name in ("recovery.jsonlz4", "recovery.baklz4"):
        try:
            data = (prof / "sessionstore-backups" / name).read_bytes()
        except OSError:
            continue
        if data[:8] == b"mozLz40\0":
            return json.loads(unlz4(data[12:], int.from_bytes(data[8:12], "little")))
    return None


def ff_session_url(sess, title):
    hits = []                                   # the windows' selected tabs first
    for w in (sess or {}).get("windows", []):
        sel = w.get("selected", 1) - 1
        for k, tab in enumerate(w.get("tabs", [])):
            entries = tab.get("entries") or []
            idx = tab.get("index", len(entries)) - 1
            if 0 <= idx < len(entries) and entries[idx].get("title", "").strip() == title:
                hits.append((k != sel, entries[idx].get("url", "")))
    return sorted(hits)[0][1] if hits else ""


def ff_icon(prof, url, host, tmp):
    scheme = urlsplit(url).scheme
    try:
        db = copy_db(prof / "favicons.sqlite", tmp)
        row = db.execute(
            """SELECT i.data FROM moz_icons i
               JOIN moz_icons_to_pages ip ON ip.icon_id = i.id
               JOIN moz_pages_w_icons p ON p.id = ip.page_id
               WHERE p.page_url = ? OR p.page_url LIKE ? OR p.page_url LIKE ?
               ORDER BY p.page_url = ? DESC, i.width DESC LIMIT 1""",
            (url, f"{scheme}://{host}/%", f"{scheme}://www.{host}/%", url)).fetchone()
        if not row:                             # a root /favicon.ico Firefox keeps without pages
            row = db.execute("SELECT data FROM moz_icons WHERE icon_url LIKE ? OR icon_url LIKE ? "
                             "ORDER BY width DESC LIMIT 1",
                             (f"%://{host}/favicon.ico", f"%://www.{host}/favicon.ico")).fetchone()
        db.close()
        return bytes(row[0]) if row and row[0] else b""
    except sqlite3.Error:
        return b""


def firefox(dirs, title, tmp):
    profs = ff_profiles(dirs)
    # The open tabs first (every profile), then the history
    for prof in profs:
        sess = ff_session(prof)
        for t in candidates(title):
            url = ff_session_url(sess, t)
            if url:
                return t, url, lambda host, prof=prof, url=url: ff_icon(prof, url, host, tmp)
    for n, prof in enumerate(profs):
        sub = Path(tmp) / f"ff{n}"
        sub.mkdir()
        try:
            db = copy_db(prof / "places.sqlite", sub)
            for t in candidates(title):
                row = db.execute("SELECT url FROM moz_places WHERE title = ? ORDER BY last_visit_date DESC LIMIT 1",
                                 (t,)).fetchone()
                if row:
                    db.close()
                    return t, row[0], lambda host, prof=prof, url=row[0]: ff_icon(prof, url, host, tmp)
            db.close()
        except sqlite3.Error:
            continue
    return "", "", None


# ---------------- Chromium family ----------------

def chromium(dirs, title, tmp):
    profs = [p for d in dirs if (HOME / d).is_dir() for p in (HOME / d).iterdir() if (p / "History").exists()]
    best = None                                 # (last visit, title, url, profile)
    for n, prof in enumerate(profs):
        sub = Path(tmp) / f"cr{n}"
        sub.mkdir()
        try:
            db = copy_db(prof / "History", sub)
            for t in candidates(title):
                row = db.execute("SELECT url, last_visit_time FROM urls WHERE title = ? "
                                 "ORDER BY last_visit_time DESC LIMIT 1", (t,)).fetchone()
                if row:
                    if not best or row[1] > best[0]:
                        best = (row[1], t, row[0], prof)
                    break
            db.close()
        except sqlite3.Error:
            continue
    if not best:
        return "", "", None
    _, t, url, prof = best

    def icon(host):
        scheme = urlsplit(url).scheme
        sub = Path(tmp) / "icons"
        sub.mkdir(exist_ok=True)
        try:
            db = copy_db(prof / "Favicons", sub)
            row = db.execute(
                """SELECT b.image_data FROM icon_mapping m
                   JOIN favicon_bitmaps b ON b.icon_id = m.icon_id
                   WHERE m.page_url = ? OR m.page_url LIKE ? OR m.page_url LIKE ?
                   ORDER BY m.page_url = ? DESC, b.width DESC LIMIT 1""",
                (url, f"{scheme}://{host}/%", f"{scheme}://www.{host}/%", url)).fetchone()
            db.close()
            return bytes(row[0]) if row and row[0] else b""
        except sqlite3.Error:
            return b""
    return t, url, icon


# ---------------- ----------------

def save_icon(host, fetch):
    CACHE.mkdir(parents=True, exist_ok=True)
    for ext in ("png", "svg", "ico"):
        if (CACHE / f"{host}.{ext}").exists():
            return str(CACHE / f"{host}.{ext}")
    data = fetch(host) if fetch else b""
    ext = "png" if data[:4] == b"\x89PNG" else "ico" if data[:4] == b"\0\0\1\0" else \
          "svg" if b"<svg" in data[:512] else ""
    if not ext:
        return ""
    out = CACHE / f"{host}.{ext}"
    out.write_bytes(data)
    return str(out)


def is_search(parts, host):
    for h, path in SEARCH:
        if re.search(h, host) and (re.search(path, parts.path) if path else "q" in parse_qs(parts.query)):
            return True
    return False


def main():
    app = (sys.argv[1] if len(sys.argv) > 1 else "").lower()
    title = (sys.argv[2] if len(sys.argv) > 2 else "").strip()
    family = next(((f, dirs) for f, table in (("ff", FIREFOX), ("cr", CHROMIUM))
                   for pat, dirs in table if re.search(pat, app)), None)
    if family and title:
        with tempfile.TemporaryDirectory() as tmp:
            page, url, fetch = (firefox if family[0] == "ff" else chromium)(family[1], title, tmp)
            parts = urlsplit(url)
            if parts.scheme in ("http", "https") and parts.hostname:
                host = parts.hostname.removeprefix("www.")
                print(json.dumps({"url": url, "domain": host, "title": page, "search": is_search(parts, host),
                                  "icon": save_icon(host, fetch)}))
                return
    print(json.dumps({"none": True}))


if __name__ == "__main__":
    main()
