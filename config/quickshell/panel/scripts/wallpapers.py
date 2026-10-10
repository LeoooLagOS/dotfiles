#!/usr/bin/env python3
"""List wallpapers for the panel's Wallpapers tab.

Usage: wallpapers.py DIR
Prints JSON: {"items": [{path, name, folder, thumb}], "current": path, "pending": N}

`thumb` is a small cached JPEG (~/.cache/quickshell-panel/thumbs/) when it
already exists, otherwise the original file. Missing thumbnails are generated
in a detached background process (ImageMagick), so the next listing is fast.
"""

import hashlib
import json
import os
import subprocess
import sys
from pathlib import Path

EXTS = {".jpg", ".jpeg", ".png", ".webp", ".bmp", ".gif"}
THUMBS = Path.home() / ".cache/quickshell-panel/thumbs"
CURRENT_LINK = Path.home() / ".config/hypr/rofi/.current_wallpaper"
THUMB_SIZE = "480x270"


def thumb_path(p: Path) -> Path:
    st = p.stat()
    key = f"{p}:{st.st_mtime_ns}:{st.st_size}".encode()
    return THUMBS / (hashlib.sha1(key).hexdigest() + ".jpg")


def main():
    root = Path(os.path.expandvars(os.path.expanduser(sys.argv[1])))
    files = sorted(
        (p for p in root.rglob("*") if p.suffix.lower() in EXTS and p.is_file()),
        key=lambda p: (str(p.parent.relative_to(root)).lower(), p.name.lower()),
    )

    items, missing = [], []
    for p in files:
        t = thumb_path(p)
        if not t.exists():
            missing.append((p, t))
        rel = p.parent.relative_to(root)
        items.append({
            "path": str(p),
            "name": p.stem,
            "folder": "" if str(rel) == "." else str(rel),
            "thumb": str(t) if t.exists() else str(p),
        })

    if missing:
        THUMBS.mkdir(parents=True, exist_ok=True)
        # One detached shell job: 4 parallel ImageMagick workers, low priority
        jobs = "\n".join(f"{p}\t{t}" for p, t in missing)
        script = (
            "while IFS=$'\\t' read -r src dst; do printf '%s\\0%s\\0' \"$src\" \"$dst\"; done | "
            f"xargs -0 -n2 -P4 sh -c 'magick \"$0[0]\" -auto-orient -thumbnail {THUMB_SIZE}^ "
            f"-gravity center -extent {THUMB_SIZE} -quality 82 \"$1\" 2>/dev/null'"
        )
        proc = subprocess.Popen(["nice", "-n", "15", "bash", "-c", script],
                                stdin=subprocess.PIPE, stdout=subprocess.DEVNULL,
                                stderr=subprocess.DEVNULL, start_new_session=True)
        proc.stdin.write(jobs.encode())
        proc.stdin.close()

    current = ""
    try:
        current = str(CURRENT_LINK.resolve()) if CURRENT_LINK.exists() else ""
    except OSError:
        pass

    print(json.dumps({"items": items, "current": current, "pending": len(missing)}))


if __name__ == "__main__":
    main()
