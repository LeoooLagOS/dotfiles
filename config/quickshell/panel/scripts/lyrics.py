#!/usr/bin/env python3
"""Lyrics for the Media tab (services/Lyrics.qml), as JSON.

  lyrics.py ARTIST TITLE ALBUM DURATION [FILE]

Looks, in order:
  1. FILE's own: a .lrc next to it (same name), else its LYRICS tag (ffprobe)
  2. LRCLIB (lrclib.net): free, open, no account; synced (timed) lyrics when
     it has them. Exact match by artist, title, album and duration, else a
     search by artist and title (closest duration).
Prints {"synced": bool, "instrumental": bool, "lines": [{"t": seconds, "text"}],
"source": "file" | "tags" | "lrclib"}, or {"none": true}. Results are cached
in ~/.cache/quickshell-panel/lyrics (not-found for a day).
"""

import hashlib
import json
import re
import subprocess
import sys
import time
import urllib.parse
import urllib.request
from pathlib import Path

CACHE = Path.home() / ".cache/quickshell-panel/lyrics"
MUSIC = Path.home() / "Music"
API = "https://lrclib.net/api"
AGENT = "lagos-panel/1.0 (Quickshell panel, lyrics view)"
TIME = re.compile(r"\[(\d+):(\d+(?:[.:]\d+)?)\]")


def parse(text, source):
    """LRC ("[01:02.50] words") or plain text -> lines."""
    lines, synced = [], False
    for raw in (text or "").splitlines():
        stamps = TIME.findall(raw)
        words = TIME.sub("", raw).strip()
        if stamps:
            synced = True
            for m, s in stamps:
                lines.append({"t": int(m) * 60 + float(s.replace(":", ".")), "text": words})
        elif not re.match(r"^\[[a-z]+:.*\]$", raw.strip()):   # skip [ar:…] [ti:…] headers
            lines.append({"t": -1, "text": raw.strip()})
    if synced:
        lines = sorted((l for l in lines if l["t"] >= 0), key=lambda l: l["t"])
    # No empty lines at the start or end
    while lines and not lines[0]["text"]:
        lines.pop(0)
    while lines and not lines[-1]["text"]:
        lines.pop()
    return {"synced": synced, "instrumental": False, "lines": lines, "source": source} if lines else None


def from_file(path):
    if not path:
        return None
    f = Path(path)
    if not f.is_absolute():
        f = MUSIC / f
    lrc = f.with_suffix(".lrc")
    if lrc.is_file():
        return parse(lrc.read_text(errors="replace"), "file")
    try:
        out = subprocess.run(["ffprobe", "-v", "quiet", "-print_format", "json", "-show_entries",
                              "format_tags:stream_tags", str(f)], capture_output=True, text=True, timeout=10).stdout
        d = json.loads(out or "{}")
        tags = dict(d.get("format", {}).get("tags", {}))
        for s in d.get("streams", []):
            tags.update(s.get("tags", {}))
        for k, v in tags.items():
            if k.lower() in ("lyrics", "unsyncedlyrics", "syncedlyrics") or k.lower().startswith("lyrics-"):
                return parse(v, "tags")
    except Exception:
        pass
    return None


def get(endpoint, **params):
    url = f"{API}/{endpoint}?" + urllib.parse.urlencode({k: v for k, v in params.items() if v})
    req = urllib.request.Request(url, headers={"User-Agent": AGENT})
    try:
        with urllib.request.urlopen(req, timeout=10) as r:
            return json.load(r)
    except urllib.error.HTTPError as e:
        if e.code == 404:
            return None
        raise


def clean(title):
    """'Song - Remastered 2011' / 'Song (feat. X)' -> 'Song', for the search."""
    t = re.sub(r"\s+-\s+.*(remaster|version|live|mono|stereo|edit|mix).*$", "", title, flags=re.I)
    return re.sub(r"\s*[(\[](feat|ft|with|remaster)[^)\]]*[)\]]", "", t, flags=re.I).strip()


def from_lrclib(artist, title, album, duration):
    """The exact match, unless it has no timing and a search finds a timed
    version of about the same length."""
    exact = None
    if duration > 0:
        exact = get("get", artist_name=artist, track_name=title, album_name=album, duration=round(duration))
    found = []
    if not exact or not exact.get("syncedLyrics"):
        found = get("search", artist_name=artist, track_name=clean(title)) or []
        if duration > 0:
            found = [x for x in found if abs((x.get("duration") or 0) - duration) <= 4]
    found.sort(key=lambda x: (not x.get("syncedLyrics"), abs((x.get("duration") or 0) - duration)))
    r = exact if exact and (exact.get("syncedLyrics") or not (found and found[0].get("syncedLyrics"))) else (found[0] if found else None)
    if not r:
        return None
    if r.get("instrumental"):
        return {"synced": False, "instrumental": True, "lines": [], "source": "lrclib"}
    return parse(r.get("syncedLyrics") or r.get("plainLyrics") or "", "lrclib")


def main():
    if len(sys.argv) < 5:
        print(__doc__)
        return 2
    artist, title, album, duration = sys.argv[1], sys.argv[2], sys.argv[3], float(sys.argv[4] or 0)
    path = sys.argv[5] if len(sys.argv) > 5 else ""
    local = from_file(path)
    if local:
        print(json.dumps(local))
        return 0

    CACHE.mkdir(parents=True, exist_ok=True)
    key = hashlib.sha1(f"{artist}|{title}|{album}|{round(duration)}".encode()).hexdigest()[:20]
    cached = CACHE / f"{key}.json"
    if cached.is_file():
        d = json.loads(cached.read_text())
        if not d.get("none") or time.time() - cached.stat().st_mtime < 86400:
            print(json.dumps(d))
            return 0
    try:
        d = from_lrclib(artist, title, album, duration) or {"none": True}
    except Exception as e:
        print(json.dumps({"error": str(e)}))     # offline: not cached, tried again next time
        return 1
    cached.write_text(json.dumps(d))
    print(json.dumps(d))
    return 0


if __name__ == "__main__":
    sys.exit(main())
