#!/usr/bin/env python3
import argparse
import subprocess
import os
import sys
from pathlib import Path

# --- PORTABLE PATH LOGIC ---
SCRIPT_DIR = Path(__file__).resolve().parent
TEMPLATES_DIR = SCRIPT_DIR / "templates"
CSL_DIR = SCRIPT_DIR / "csl"
HOME = Path.home()

# Template Configuration
TEMPLATES = {
    "ieee": {
        "type": "latex",
        "path": str(TEMPLATES_DIR / "ieee.latex"),
        "engine": "xelatex",
        "csl": CSL_DIR / "ieee.csl",
    },
    "academia": {
        "type": "odt",
        "path": str(TEMPLATES_DIR / "academia_template.odt"),
        "engine": None,
        "csl": None,
    },
}


def build_command(input_file, template_name):
    if template_name not in TEMPLATES:
        print(f"❌ Error: Template '{template_name}' not defined.")
        return None

    tmpl = TEMPLATES[template_name]
    input_path = Path(input_file).resolve()
    current_dir = input_path.parent
    output_ext = "pdf" if tmpl["type"] == "latex" else "odt"
    output_file = f"{input_path.stem}_{template_name}.{output_ext}"

    # --- IMAGE MANAGEMENT (Resource Path) ---
    # We tell Pandoc to search for images in these locations:
    # 1. Current working directory (.)
    # 2. The directory where the Markdown file lives
    # 3. An 'attachments' folder inside the Markdown file's directory
    # 4. Your global Obsidian attachments folder
    resource_paths = [
        ".",
        str(current_dir),
        str(current_dir / "attachments"),
        str(HOME / "Documents/my-cs-notes/attachments"),
    ]
    resource_path_str = ":".join(resource_paths)

    # Bibliography detection
    bib_files = list(Path(".").glob("*.bib"))
    bib_arg = ["--bibliography", str(bib_files[0])] if bib_files else []

    # Base Command
    cmd = [
        "pandoc",
        str(input_path),
        "--citeproc",
        "--resource-path",
        resource_path_str,
    ] + bib_arg

    # CSL and Template logic
    if tmpl.get("csl") and tmpl["csl"].exists():
        cmd += ["--csl", str(tmpl["csl"])]

    if tmpl["type"] == "latex":
        cmd += ["--template", tmpl["path"], "--pdf-engine", tmpl["engine"]]
    else:
        cmd += ["--reference-doc", tmpl["path"]]

    cmd += ["-o", output_file]
    return cmd, output_file


def main():
    parser = argparse.ArgumentParser(description="lagOS Academic Build System")
    parser.add_argument("file", help="Markdown file to compile")
    parser.add_argument("--type", default="ieee", help="Template (ieee/academia)")
    args = parser.parse_args()

    if not os.path.exists(args.file):
        print(f"❌ Error: File '{args.file}' not found.")
        sys.exit(1)

    result = build_command(args.file, args.type)
    if result:
        command, output_name = result
        print(f"🏗️  Building '{args.file}' with all images...")
        try:
            subprocess.run(command, check=True)
            print(f"✅ Success! Generated: {output_name}")
            subprocess.run(["xdg-open", output_name])
        except subprocess.CalledProcessError:
            print("❌ Error: Pandoc failed to compile.")


if __name__ == "__main__":
    main()
