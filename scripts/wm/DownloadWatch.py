#!/usr/bin/env python3
"""A notification when a download finishes, from any app (browsers, WhatsApp…).

Browsers on Linux show finished downloads only inside their own window, so
this watches the downloads folder itself. Run by lagos-downloads.service.

A file counts as finished when it is closed after writing (close_write) or
renamed into the folder (moved_to: Brave/Chrome write `x.crdownload`, Firefox
`x.part`, then rename to the real name). Temporary names are skipped, and a
file that keeps arriving within a few seconds is announced only once.

The notification's buttons: Open (default app) and Show in folder (the file
manager, with the file selected). It follows Do Not Disturb like any other.
"""

import mimetypes
import subprocess
import threading
import time
from pathlib import Path
from urllib.parse import quote

PARTIAL = (".crdownload", ".part", ".tmp", ".download", ".partial")
REPEAT_WINDOW = 5  # seconds: one notification per file in this window


def downloads_dir() -> Path:
    try:
        out = subprocess.run(["xdg-user-dir", "DOWNLOAD"], capture_output=True, text=True).stdout.strip()
        if out:
            return Path(out)
    except FileNotFoundError:
        pass
    return Path.home() / "Downloads"


def icon_for(path: Path) -> str:
    mime = mimetypes.guess_type(path.name)[0] or ""
    kind = mime.split("/")[0]
    if kind in ("image", "video", "audio"):
        return f"{kind}-x-generic"
    if "pdf" in mime:
        return "application-pdf"
    if any(w in mime for w in ("word", "opendocument.text", "rtf")):
        return "x-office-document"
    if any(w in mime for w in ("sheet", "excel", "csv")):
        return "x-office-spreadsheet"
    if any(w in mime for w in ("presentation", "powerpoint")):
        return "x-office-presentation"
    if any(w in mime for w in ("zip", "tar", "compressed", "7z", "rar")):
        return "package-x-generic"
    return "folder-download"


def human_size(n: int) -> str:
    for unit in ("B", "KB", "MB", "GB"):
        if n < 1024 or unit == "GB":
            return f"{n:.0f} {unit}" if unit == "B" else f"{n:.1f} {unit}"
        n /= 1024
    return ""


def show_in_folder(path: Path) -> None:
    uri = "file://" + quote(str(path))
    shown = subprocess.run([
        "gdbus", "call", "--session",
        "--dest", "org.freedesktop.FileManager1",
        "--object-path", "/org/freedesktop/FileManager1",
        "--method", "org.freedesktop.FileManager1.ShowItems", f"['{uri}']", "",
    ], capture_output=True).returncode == 0
    if not shown:
        subprocess.Popen(["xdg-open", str(path.parent)])


def notify(path: Path) -> None:
    """Runs in its own thread: notify-send -A waits until a button is clicked."""
    try:
        size = human_size(path.stat().st_size)
    except FileNotFoundError:
        return  # gone already (moved or deleted right away)
    answer = subprocess.run([
        "notify-send", "-a", "Downloads", "-i", icon_for(path),
        "-h", "string:category:transfer.complete",
        "-A", "default=Open", "-A", "open=Open", "-A", "folder=Show in folder",
        "Download complete", f"{path.name}\n{size}",
    ], capture_output=True, text=True).stdout.strip()
    if answer in ("default", "open"):
        subprocess.Popen(["xdg-open", str(path)])
    elif answer == "folder":
        show_in_folder(path)


def main() -> None:
    folder = downloads_dir()
    folder.mkdir(parents=True, exist_ok=True)
    watcher = subprocess.Popen(
        ["inotifywait", "-m", "-q", "-e", "close_write", "-e", "moved_to", "--format", "%f", str(folder)],
        stdout=subprocess.PIPE, text=True,
    )
    last_seen: dict[str, float] = {}
    for line in watcher.stdout:
        name = line.rstrip("\n")
        if not name or name.startswith(".") or name.lower().endswith(PARTIAL):
            continue
        path = folder / name
        if not path.is_file():
            continue
        now = time.monotonic()
        if now - last_seen.get(name, 0) < REPEAT_WINDOW:
            continue
        last_seen[name] = now
        threading.Thread(target=notify, args=(path,), daemon=True).start()


if __name__ == "__main__":
    main()
