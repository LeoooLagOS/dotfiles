#!/usr/bin/env python3
"""Music library for the panel (Media → Library view, services/Library.qml).

Talks to MPD over its socket (~/.local/state/mpd/socket, config/mpd/mpd.conf)
and prints JSON. Needs ffmpeg (embedded covers, verify); verify also numpy.

  library.py albums                 every album: artist, title, year, cover,
                                    format ("FLAC 24/96"), tracks (with files),
                                    artwork (the folder's images: booklet, back…),
                                    added (ISO date), played (epoch, 0 = never)
  library.py verify ARTIST ALBUM    is each track really lossless? per track:
                                    ok · fake (an MP3/AAC in a .flac) · lossy
                                    (transcoded from one) · upsampled (a CD
                                    passed off as Hi-Res) · padded (16 bits in 24)
  library.py spectrum FILE          a spectrogram of FILE, opened in the image
                                    viewer (to judge a doubtful track by eye)
  library.py status                 what's playing, MPD's output format, the
                                    sound card's real rate and bit-perfect
  library.py play ARTIST ALBUM [N]  replace the queue with the album, play track N
  library.py queue ARTIST ALBUM     add the album to the queue
  library.py toggle | next | prev | stop | update | seek SECONDS

Covers: cover/folder/front.(jpg|png) in the album's folder, else the picture
embedded in the first file, extracted once to ~/.cache/quickshell-panel/covers.
The album list is cached in ~/.cache/quickshell-panel/library.json and rebuilt
when MPD's database changes (db_update, song count).
"""

import glob
import hashlib
import json
import os
import socket
import subprocess
import sys
import time
from pathlib import Path

HOME = Path.home()
SOCKET = HOME / ".local/state/mpd/socket"
MUSIC = HOME / "Music"
CACHE = HOME / ".cache/quickshell-panel"
COVERS = CACHE / "covers"
ALBUMS_CACHE = CACHE / "library.json"
CACHE_FORMAT = 3                     # bump when an album gains a field: rebuilds the cache
VERIFY_CACHE = CACHE / "verify.json"
PLAYED = HOME / ".local/state/quickshell-panel/library-played.json"   # album → last played (state, not cache)
SPECTRA = CACHE / "spectra"
COVER_NAMES = ["cover", "folder", "front", "Cover", "Folder", "Front", "album", "Album"]
IMAGE_EXTS = {".jpg", ".jpeg", ".png", ".webp"}


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
            elif k in ("directory", "playlist"):
                cur = None           # not a song: what follows isn't the last song's
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
    # MPD's last update time and song count: a list read mid-update (auto_update
    # while files arrive) has the same time but fewer songs
    st = dict(mpd.cmd("stats"))
    db = f'{st.get("db_update", "")}:{st.get("songs", "")}:{CACHE_FORMAT}'
    if ALBUMS_CACHE.is_file():
        try:
            cached = json.loads(ALBUMS_CACHE.read_text())
            if cached.get("db_update") == db:
                # Images aren't in MPD's database: read them each time (cheap)
                return with_extras(cached["albums"])
        except Exception:
            pass
    groups = {}
    for s in mpd.songs("listallinfo"):
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
            # Sort keys: "Calamaro, Andrés" for by-artist; when it reached the library
            "artistSort": songs[0].get("AlbumArtistSort") or songs[0].get("ArtistSort") or artist,
            "added": max(s.get("Added") or s.get("Last-Modified") or "" for s in songs),
            "quality": q["label"],
            "hires": q["hires"],
            "tracks": [{
                "title": s.get("Title") or Path(s["file"]).stem,
                "track": str(s.get("Track", "")).split("/")[0],
                "disc": str(s.get("Disc", "")).split("/")[0],
                "artist": s.get("Artist", ""),
                "duration": float(s.get("duration") or s.get("Time") or 0),
                "file": s["file"],
            } for s in songs],
        })
    out.sort(key=lambda a: (a["artist"].lower(), a["year"], a["album"].lower()))
    CACHE.mkdir(parents=True, exist_ok=True)
    ALBUMS_CACHE.write_text(json.dumps({"db_update": db, "albums": out}))
    return with_extras(out)


def with_extras(albums):
    """What isn't in MPD's database, so not in its cache: the folder's images,
    and when each album was last played from the panel (for "Recents")."""
    try:
        played = json.loads(PLAYED.read_text())
    except Exception:
        played = {}
    for a in albums:
        a["artwork"] = artwork_for(a)
        a["played"] = played.get(a["artist"] + "\n" + a["album"], 0)
    return albums


def remember_played(artist, album):
    try:
        played = json.loads(PLAYED.read_text())
    except Exception:
        played = {}
    played[artist + "\n" + album] = int(time.time())
    PLAYED.parent.mkdir(parents=True, exist_ok=True)
    PLAYED.write_text(json.dumps(played))


def album_dir(album):
    """The folder holding all of an album's tracks (CD1/, CD2/… share a parent)."""
    dirs = {str(Path(t["file"]).parent) for t in album["tracks"]}
    return MUSIC / os.path.commonpath(sorted(dirs)) if dirs else None


def artwork_for(album):
    """Every image in the album's folder and its subfolders (Artwork/, Scans/…):
    the cover first, then by name."""
    folder = album_dir(album)
    if not folder or folder == MUSIC or not folder.is_dir():
        return []
    images = [p for p in folder.rglob("*")
              if p.suffix.lower() in IMAGE_EXTS and not p.name.startswith(".")]
    images.sort(key=lambda p: (str(p) != album.get("cover"), str(p.relative_to(folder)).lower()))
    return [str(p) for p in images]


# ---------------------------------------------------------------- verify
# A ".flac" proves nothing: anyone can rename an MP3, or decode one and save it
# as FLAC. What the file holds tells:
#   - the real codec (ffprobe), whatever the extension says;
#   - the spectrum: MP3/AAC encoders throw away the highs above a fixed
#     frequency (16 kHz at 128k, ~19.5 at 256k), a cliff tens of dB deep.
#     A CD's own filter cuts at 20-22 kHz, so only cliffs below 19.5 kHz count
#     (a 320k MP3 cuts at ~20 and can't be told apart: the spectrogram helps);
#   - Hi-Res: a CD resampled to 96 kHz still stops at ~22 kHz;
#   - 24 bits: a 16-bit recording padded with zeros keeps its low 8 bits at 0.

LOSSLESS_CODECS = {"flac", "alac", "wavpack", "ape", "tta", "mlp", "truehd"}
CLIFF_DB = 25          # how deep a drop must be to be an encoder's cut, not the music


def probe(path):
    out = subprocess.run(["ffprobe", "-v", "quiet", "-of", "json", "-show_format", "-show_streams",
                          "-select_streams", "a:0", str(path)], capture_output=True, text=True).stdout
    d = json.loads(out or "{}")
    s = (d.get("streams") or [{}])[0]
    return {
        "container": d.get("format", {}).get("format_name", ""),
        "codec": s.get("codec_name", ""),
        "rate": int(s.get("sample_rate") or 0),
        "bits": int(s.get("bits_per_raw_sample") or s.get("bits_per_sample") or 0),
        "duration": float(d.get("format", {}).get("duration") or 0),
    }


def decode(path, start, seconds, fmt, mono=True):
    """PCM from the middle of the track, as raw bytes. Mono averages the
    channels: fine for the spectrum, not for counting bits (it invents some)."""
    return subprocess.run(["ffmpeg", "-v", "quiet", "-ss", str(start), "-t", str(seconds), "-i", str(path)]
                          + (["-ac", "1"] if mono else []) + ["-f", fmt, "-"],
                          capture_output=True, timeout=60).stdout


def cliff(np, pcm, rate):
    """The steepest drop in the averaged spectrum above 11 kHz: (Hz, dB)."""
    x = np.frombuffer(pcm, dtype=np.float32)
    n = 8192
    frames = len(x) // n
    if frames < 4:
        return 0, 0
    window = np.hanning(n)
    power = np.zeros(n // 2 + 1)
    for i in range(frames):
        power += np.abs(np.fft.rfft(x[i * n:(i + 1) * n] * window)) ** 2
    db = 10 * np.log10(power / frames + 1e-20)
    hz = rate / n                                      # width of one bin
    smooth = np.convolve(db, np.ones(int(250 / hz)) / int(250 / hz), mode="same")
    step = int(600 / hz)                               # compare 600 Hz below with 600 Hz above
    lo, hi = int(11000 / hz), len(db) - int(1000 / hz)
    drops = smooth[lo - step:hi - step] - smooth[lo + step:hi + step]
    i = int(np.argmax(drops))
    return (lo + i) * hz, float(drops[i])


def padded_bits(np, path, start):
    """True if a 24-bit file only holds 16 bits (the low 8 always zero)."""
    x = np.frombuffer(decode(path, start, 10, "s32le", mono=False), dtype=np.int32)
    # s32 puts 24-bit samples in the top 24 bits: their bits 8-15 are the low 8
    return len(x) > 0 and not np.any(np.bitwise_and(x, 0xFF00))


def check(np, path):
    p = probe(path)
    res = {"codec": p["codec"], "rate": p["rate"], "bits": p["bits"], "cutoff": 0}
    if not p["codec"].startswith("pcm_") and p["codec"] not in LOSSLESS_CODECS:   # pcm_* = WAV / AIFF
        return {**res, "verdict": "fake" if p["codec"] else "error"}
    start = max(0, min(30, p["duration"] / 3))
    hz, drop = cliff(np, decode(path, start, 30, "f32le"), p["rate"])
    res["cutoff"] = round(hz / 1000, 1)
    if drop >= CLIFF_DB and hz < 19500:
        return {**res, "verdict": "lossy"}
    if drop >= CLIFF_DB and p["rate"] > 48000 and hz < 24500:
        return {**res, "verdict": "upsampled"}
    if p["bits"] > 16 and padded_bits(np, path, start):
        return {**res, "verdict": "padded"}
    return {**res, "verdict": "ok"}


def verify(mpd, artist, album):
    try:
        import numpy as np
    except ImportError:
        return {"error": "numpy"}
    try:
        cache = json.loads(VERIFY_CACHE.read_text())
    except Exception:
        cache = {}
    out = []
    for f in album_files(mpd, artist, album):
        path = MUSIC / f
        try:
            st = path.stat()
        except OSError:
            continue
        key = f"{f}:{st.st_size}:{int(st.st_mtime)}"       # a re-tagged or replaced file is checked again
        if key not in cache:
            try:
                cache[key] = check(np, path)
            except Exception:
                cache[key] = {"verdict": "error"}
        out.append({"file": f, **cache[key]})
    CACHE.mkdir(parents=True, exist_ok=True)
    VERIFY_CACHE.write_text(json.dumps(cache))
    return out


def spectrum(f):
    """Spectrogram PNG of a track (time → frequency, brightness = energy), opened
    in the image viewer: a lossy file shows a flat ceiling where the highs end."""
    path = MUSIC / f
    SPECTRA.mkdir(parents=True, exist_ok=True)
    out = SPECTRA / (hashlib.sha1(str(path).encode()).hexdigest()[:16] + ".png")
    if not out.is_file():
        subprocess.run(["ffmpeg", "-v", "quiet", "-y", "-i", str(path), "-lavfi",
                        "showspectrumpic=s=1600x800:legend=1:scale=log:fscale=lin", str(out)],
                       timeout=120, check=False)
    if out.is_file():
        subprocess.Popen(["xdg-open", str(out)], start_new_session=True,
                         stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return str(out) if out.is_file() else ""


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
        elif what == "verify":
            print(json.dumps(verify(mpd, args[0], args[1])))
        elif what == "spectrum":
            print(json.dumps({"image": spectrum(args[0])}))
        elif what in ("play", "queue"):
            files = album_files(mpd, args[0], args[1])
            cmds = ([("clear",)] if what == "play" else []) + [("add", f) for f in files]
            if what == "play":
                cmds.append(("play", int(args[2]) if len(args) > 2 else 0))
            mpd.batch(cmds)
            remember_played(args[0], args[1])
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
