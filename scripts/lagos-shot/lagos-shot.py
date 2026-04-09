#!/usr/bin/env python3
import subprocess
import time
import shutil
from pathlib import Path


def run_command(command):
    """Utility to execute shell commands and return exit status."""
    return subprocess.run(command, shell=True)


def main():
    # --- DYNAMIC CONFIGURATION ---
    try:
        pictures_dir = Path(
            subprocess.check_output(["xdg-user-dir", "PICTURES"]).decode().strip()
        )
    except subprocess.CalledProcessError:
        pictures_dir = Path.home() / "Pictures"

    default_dir = pictures_dir / "Screenshots"

    # Volatile intermediate files in /tmp
    timestamp = int(time.time())
    temp_raw = Path(f"/tmp/raw_shot_{timestamp}.png")
    temp_edited = Path(f"/tmp/edited_shot_{timestamp}.png")

    try:
        # 1. CAPTURE
        capture = run_command(f'grim -g "$(slurp)" {temp_raw}')
        if capture.returncode != 0:
            return

        # 2. EDITING
        run_command(f"swappy -f {temp_raw} -o {temp_edited}")

        # 3. GUI SAVE DIALOG
        if temp_edited.exists():
            suggested_filename = f"screenshot_{time.strftime('%Y%m%d_%H%M%S')}.png"
            zenity_cmd = [
                "zenity",
                "--file-selection",
                "--save",
                "--confirm-overwrite",
                "--title=Save Capture - lagOS station",
                f"--filename={default_dir / suggested_filename}",
                "--file-filter=PNG Images | *.png",
            ]

            result = subprocess.run(zenity_cmd, capture_output=True, text=True)
            final_path_str = result.stdout.strip()

            if final_path_str:
                final_path = Path(final_path_str)
                if final_path.suffix.lower() != ".png":
                    final_path = final_path.with_suffix(".png")

                # Cross-device move (RAM to Disk)
                shutil.move(str(temp_edited), str(final_path))

                # --- UPDATED CLIPBOARD LOGIC ---
                # Using the full path instead of just .name
                md_link = f"![]({final_path.absolute()})"
                subprocess.run(f"echo -n '{md_link}' | wl-copy", shell=True)

                subprocess.run(
                    [
                        "notify-send",
                        "📸 Capture Saved",
                        "Full path Markdown link copied to clipboard.",
                    ]
                )
    finally:
        # 4. CLEANUP
        if temp_raw.exists():
            temp_raw.unlink()
        if temp_edited.exists():
            try:
                temp_edited.unlink()
            except FileNotFoundError:
                pass


if __name__ == "__main__":
    main()
