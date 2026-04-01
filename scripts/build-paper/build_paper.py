#!/usr/bin/env python3
import argparse
import subprocess
import os
import sys
from pathlib import Path

# --- CONFIGURATION & PATHS ---
# Separation of Concerns (SoC): Centralizing global paths
HOME = Path.home()
PANDOC_DATA_DIR = HOME / ".local/share/pandoc"
OBSIDIAN_TEMPLATES = HOME / "Documents/my-cs-notes/91_Templates"

# Template Dictionary
# path: name of the latex file in pandoc/templates or absolute path for ODT
TEMPLATES = {
    "ieee": {
        "type": "latex",
        "path": "ieee",  # Found in ~/.local/share/pandoc/templates/ieee.latex
        "engine": "xelatex",
        "csl": PANDOC_DATA_DIR / "csl/ieee.csl",
    },
    "academia": {
        "type": "odt",
        "path": str(OBSIDIAN_TEMPLATES / "academia_template.odt"),
        "engine": None,
        "csl": None,
    },
}


def build_command(input_file, template_name):
    """Constructs the Pandoc command based on the selected template."""
    if template_name not in TEMPLATES:
        print(f"❌ Error: Template '{template_name}' is not defined in the script.")
        return None

    tmpl = TEMPLATES[template_name]
    input_path = Path(input_file)

    # Define output extension and filename
    output_ext = "pdf" if tmpl["type"] == "latex" else "odt"
    output_file = f"{input_path.stem}_{template_name}.{output_ext}"

    # Auto-detect bibliography (.bib) file in current working directory
    bib_files = list(Path(".").glob("*.bib"))
    bib_arg = ["--bibliography", str(bib_files[0])] if bib_files else []

    # Base Pandoc command with citeproc enabled
    cmd = ["pandoc", str(input_path), "--citeproc"] + bib_arg

    # Add CSL style if defined and file exists
    if tmpl.get("csl") and tmpl["csl"].exists():
        cmd += ["--csl", str(tmpl["csl"])]

    # Format specific arguments
    if tmpl["type"] == "latex":
        cmd += ["--template", tmpl["path"], "--pdf-engine", tmpl["engine"]]
    else:
        cmd += ["--reference-doc", tmpl["path"]]

    cmd += ["-o", output_file]
    return cmd, output_file


def main():
    parser = argparse.ArgumentParser(description="lagOS Academic Build System")
    parser.add_argument("file", help="Markdown (.md) file to compile")
    parser.add_argument(
        "--type", default="ieee", help="Template to use (ieee or academia)"
    )
    args = parser.parse_args()

    # Integrity check
    if not os.path.exists(args.file):
        print(f"❌ Error: File '{args.file}' not found.")
        sys.exit(1)

    result = build_command(args.file, args.type)
    if result:
        command, output_name = result
        print(f"🏗️  Compiling '{args.file}' using '{args.type}' format...")

        try:
            # Execute Pandoc
            subprocess.run(command, check=True)
            print(f"✅ Success! Generated: {output_name}")

            # Quality of Life: Auto-open the generated file (Linux/Fedora standard)
            print(f"👁️  Opening {output_name}...")
            subprocess.run(["xdg-open", output_name])

        except subprocess.CalledProcessError:
            print("❌ Error: Pandoc failed to compile the document.")
        except FileNotFoundError:
            print("⚠️  Warning: PDF generated but xdg-open was not found.")


if __name__ == "__main__":
    main()
