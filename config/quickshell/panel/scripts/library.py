#!/usr/bin/env python3
"""Music library for the panel (Media → Library view, services/Library.qml).

Talks to MPD over its socket (~/.local/state/mpd/socket, config/mpd/mpd.conf)
and prints JSON. No dependencies besides ffmpeg (embedded covers).

  library.py albums                 every album: artist, title, year, cover,
                                    format ("FLAC 24/96"), tracks (with files)
  library.py status                 what's playing, MPD's output format, the
                                    sound card's real rate and bit-perfect
  library.py play ARTIST ALBUM [N]  replace the queue with the album, play track N
  library.py queue ARTIST ALBUM     add the album to the queue
  library.py toggle | next | prev | stop | update | seek SECONDS

Covers: cover/folder/front.(jpg|png) in the album's folder, else the picture
embedded in the first file, extracted once to ~/.cache/quickshell-panel/covers.
The album list is cached in ~/.cache/quickshell-panel/library.json and rebuilt
when MPD's database changes (db_update).
"""

import glob
import hashlib
import json
import os
import socket
import subprocess
import sys
from pathlib import Path

HOME = Path.home()
SOCKET = HOME / ".local/state/mpd/socket"
MUSIC = HOME / "Music"
CACHE = HOME / ".cache/quickshell-panel"
COVERS = CACHE / "covers"
ALBUMS_CACHE = CACHE / "library.json"
COVER_NAMES = ["cover", "folder", "front", "Cover", "Folder", "Front", "album", "Album"]


# ---------------------------------------------------------------- MPD protocol

class MPD:
    def __init__(self):
        self.s = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
        self.s.settimeout(10)
        self.s.connect(str(SOCKET))
        self.f = self.s.makefile("rwb")
        self.f.readline()  # "OK MPD 0.24.x"

    @staticmethod
    def quote(arg):
        return '"' + str(arg).replace("\\", "\\\\").replace('"', '\\"') + '"'

    def cmd(self, name, *args):
        """Run a command; return its "key: value" pairs as a list."""
        line = " ".join([name] + [self.quote(a) for a in args]) + "\n"
        self.f.write(line.encode())
        self.f.flush()
        out = []
        while True:
            raw = self.f.readline().decode("utf-8", "replace").rstrip("\n")
            if raw == "OK":
                return out
            if raw.startswith("ACK"):
                raise RuntimeError(raw)
            key, _, value = raw.partition(": ")
            out.append((key, value))

    def songs(self, name, *args):
        """Group the pairs into dicts, one per "file:"."""
        songs, cur = [], None
        for k, v in self.cmd(name, *args):
            if k == "file":
                cur = {"file": v}
                songs.append(cur)
            elif cur is not None and k not in cur:
                cur[k] = v
        return songs

    def batch(self, commands):
        """Several commands at once (command_list)."""
        self.f.write(b"command_list_begin\n")
        for name, *args in commands:
            self.f.write((" ".join([name] + [self.quote(a) for a in args]) + "\n").encode())
        self.f.write(b"command_list_end\n")
        self.f.flush()
        while True:
            raw = self.f.readline().decode("utf-8", "replace").rstrip("\n")
            if raw == "OK":
                return
            if raw.startswith("ACK"):
                raise RuntimeError(raw)


# ---------------------------------------------------------------- formats

LOSSLESS = {"FLAC", "WAV", "AIFF", "AIF", "ALAC", "M4A", "WV", "APE", "DSF", "DFF"}


def fmt_quality(fmt, path=""):
    """MPD's '96000:24:2' + the file's extension -> 'FLAC 24/96'.
    Bits are '24' for PCM, 'f' (float) for lossy decoders (MP3, AAC…): those
    show only the rate. Hi-Res = lossless, 24 bits or more."""
    ext = Path(path).suffix.lstrip(".").upper() or "?"
    p = (fmt or "").split(":")
    if p[0].startswith("dsd"):                       # e.g. dsd64:2
        return {"label": f"{ext} {p[0].upper()}", "rate": 0, "bits": 1, "hires": True}
    rate = int(p[0]) if p[0].isdigit() else 0
    bits = int(p[1]) if len(p) > 1 and p[1].isdigit() else 0
    khz = f"{rate / 1000:g}" if rate else "?"
    label = f"{ext} {bits}/{khz}" if bits and ext in LOSSLESS else f"{ext} {khz} kHz"
    return {"label": label, "rate": rate, "bits": bits, "hires": ext in LOSSLESS and bits >= 24}


def cover_for(song_file):
    folder = MUSIC / Path(song_file).parent
    for name in COVER_NAMES:
        for ext in ("jpg", "jpeg", "png", "webp"):
            p = folder / f"{name}.{ext}"
            if p.is_file():
                return str(p)
    # Embedded picture, extracted once
    COVERS.mkdir(parents=True, exist_ok=True)
    out = COVERS / (hashlib.sha1(str(folder).encode()).hexdigest()[:16] + ".jpg")
    if out.is_file():
        return str(out) if out.stat().st_size > 0 else ""
    try:
        subprocess.run(["ffmpeg", "-v", "quiet", "-y", "-i", str(MUSIC / song_file), "-an",
                        "-vcodec", "copy", str(out)], timeout=15, check=False)
    except Exception:
        pass
    if not out.is_file():
        out.touch()  # remember there is none
    return str(out) if out.stat().st_size > 0 else ""


# ---------------------------------------------------------------- commands

def albums(mpd):
    db = dict(mpd.cmd("stats")).get("db_update", "")
    if ALBUMS_CACHE.is_file():
        try:
            cached = json.loads(ALBUMS_CACHE.read_text())
            if cached.get("db_update") == db:
                return cached["albums"]
        except Exception:
            pass
    groups = {}
    for s in mpd.songs("listallinfo"):
        if "directory" in s:
            continue
        artist = s.get("AlbumArtist") or s.get("Artist") or "Unknown artist"
        album = s.get("Album") or Path(s["file"]).parent.name or "Unknown album"
        groups.setdefault((artist, album), []).append(s)
    out = []
    for (artist, album), songs in groups.items():
        def order(x):
            def num(v):
                try:
                    return int(str(v).split("/")[0])
                except ValueError:
                    return 0
            return (num(x.get("Disc", 0)), num(x.get("Track", 0)), x["file"])
        songs.sort(key=order)
        q = fmt_quality(songs[0].get("Format", ""), songs[0]["file"])
        out.append({
            "artist": artist,
            "album": album,
            "year": (songs[0].get("Date") or songs[0].get("OriginalDate") or "")[:4],
            "cover": cover_for(songs[0]["file"]),
            "quality": q["label"],
            "hires": q["hires"],
            "tracks": [{
                "title": s.get("Title") or Path(s["file"]).stem,
                "track": str(s.get("Track", "")).split("/")[0],
                "artist": s.get("Artist", ""),
                "duration": float(s.get("duration") or s.get("Time") or 0),
                "file": s["file"],
            } for s in songs],
        })
    out.sort(key=lambda a: (a["artist"].lower(), a["year"], a["album"].lower()))
    CACHE.mkdir(parents=True, exist_ok=True)
    ALBUMS_CACHE.write_text(json.dumps({"db_update": db, "albums": out}))
    return out


def card_output():
    """The sound card's real format while playing: [(rate, format)] from ALSA."""
    out = []
    for f in glob.glob("/proc/asound/card*/pcm*p/sub*/hw_params"):
        try:
            text = Path(f).read_text()
        except OSError:
            continue
        if text.strip() == "closed":
            continue
        info = dict(line.split(": ", 1) for line in text.splitlines() if ": " in line)
        try:
            rate = int(info.get("rate", "0").split()[0])
        except ValueError:
            rate = 0
        out.append({"rate": rate, "format": info.get("format", "")})
    return out


def status(mpd):
    st = dict(mpd.cmd("status"))
    song = dict(mpd.cmd("currentsong")) if st.get("state") in ("play", "pause") else {}
    q = fmt_quality(st.get("audio", ""), song.get("file", ""))
    cards = card_output() if st.get("state") == "play" else []
    rate = q["rate"]
    # Bit-perfect: a sound card runs at the music's own rate (nothing resampled)
    bitperfect = bool(rate) and any(c["rate"] == rate for c in cards)
    return {
        "state": st.get("state", "stop"),
        "elapsed": float(st.get("elapsed", 0)),
        "duration": float(st.get("duration", 0)),
        "random": st.get("random") == "1",
        "repeat": st.get("repeat") == "1",
        "queue": int(st.get("playlistlength", 0)),
        "pos": int(st.get("song", -1)),
        "updating": "updating_db" in st,
        "title": song.get("Title") or (Path(song["file"]).stem if song.get("file") else ""),
        "artist": song.get("Artist", ""),
        "album": song.get("Album", ""),
        "albumArtist": song.get("AlbumArtist") or song.get("Artist", ""),
        "file": song.get("file", ""),
        "cover": cover_for(song["file"]) if song.get("file") else "",
        "quality": q["label"] if song else "",
        "hires": q["hires"] if song else False,
        "rate": rate,
        "bits": q["bits"],
        "cardRate": cards[0]["rate"] if cards else 0,
        "bitperfect": bitperfect,
    }


def album_files(mpd, artist, album):
    for a in albums(mpd):
        if a["artist"] == artist and a["album"] == album:
            return [t["file"] for t in a["tracks"]]
    return []


def main():
    if len(sys.argv) < 2:
        print(__doc__)
        return 2
    what, args = sys.argv[1], sys.argv[2:]
    try:
        mpd = MPD()
    except OSError as e:
        print(json.dumps({"error": "mpd", "detail": str(e)}))
        return 1
    try:
        if what == "albums":
            print(json.dumps(albums(mpd)))
        elif what == "status":
            print(json.dumps(status(mpd)))
        elif what in ("play", "queue"):
            files = album_files(mpd, args[0], args[1])
            cmds = ([("clear",)] if what == "play" else []) + [("add", f) for f in files]
            if what == "play":
                cmds.append(("play", int(args[2]) if len(args) > 2 else 0))
            mpd.batch(cmds)
        elif what == "toggle":
            st = dict(mpd.cmd("status")).get("state")
            mpd.cmd("pause", "1") if st == "play" else mpd.cmd("play")
        elif what in ("next", "stop", "update"):
            mpd.cmd(what)
        elif what == "prev":
            mpd.cmd("previous")
        elif what == "seek":
            mpd.cmd("seekcur", args[0])
        elif what == "random":
            mpd.cmd("random", args[0])
        elif what == "repeat":
            mpd.cmd("repeat", args[0])
        else:
            print(__doc__)
            return 2
    except RuntimeError as e:
        print(json.dumps({"error": "command", "detail": str(e)}))
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
