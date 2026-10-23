#!/usr/bin/env python3
"""Fill an INI file with a flavor's settings, without overriding the user's.

  ini-fill.py FRAGMENT TARGET [--dry-run]

Every `key=value` of FRAGMENT whose key is missing from the same [section] of
TARGET is added at the end of that section (the section is created if
missing; TARGET too). Keys already in TARGET are left alone: a flavor only
sets a starting point, your own changes win.

Lines are copied as text, not parsed into values: apps like Picard store Qt's
own encoding (`@Variant(\\0\\0…)`), which configparser would mangle. Comment
lines (`;` or `#`) in FRAGMENT are documentation and aren't copied.
Prints one line per key added, nothing when there was nothing to do.
"""

import sys
from pathlib import Path


def sections(lines):
    """[(section, [lines])] in file order; lines before any section go under ""."""
    out, name, body = [], "", []
    for line in lines:
        if line.startswith("[") and line.rstrip().endswith("]"):
            out.append((name, body))
            name, body = line.strip(), []
        else:
            body.append(line)
    out.append((name, body))
    return out


def key_of(line):
    return line.split("=", 1)[0].strip() if "=" in line else None


def main():
    args = [a for a in sys.argv[1:] if a != "--dry-run"]
    dry = "--dry-run" in sys.argv
    if len(args) != 2:
        print(__doc__)
        return 2
    fragment, target = Path(args[0]), Path(args[1])
    # surrogateescape: keep whatever bytes the app wrote, even if not UTF-8
    wanted = sections(fragment.read_text(errors="surrogateescape").splitlines())
    current = sections(target.read_text(errors="surrogateescape").splitlines()) if target.is_file() else [("", [])]

    added = []
    for name, body in wanted:
        lines = [l for l in body if key_of(l) and not l.lstrip().startswith((";", "#"))]
        if not lines:
            continue
        found = next((b for n, b in current if n == name), None)
        if found is None:
            found = []
            current.append((name, found))
        have = {key_of(l) for l in found}
        new = [l for l in lines if key_of(l) not in have]
        # After the section's last setting, before its trailing blank lines
        end = len(found)
        while end > 0 and not found[end - 1].strip():
            end -= 1
        found[end:end] = new
        added += [f"{name} {key_of(l)}" for l in new]

    if added and not dry:
        text = []
        for name, body in current:
            if name:
                text.append(name)
            text += body
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text("\n".join(text).strip("\n") + "\n", errors="surrogateescape")
    for a in added:
        print(("would add " if dry else "added ") + a)
    return 0


if __name__ == "__main__":
    sys.exit(main())
