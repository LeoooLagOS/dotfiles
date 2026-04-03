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

# Template Configuration - Updated for Subfolder Structure
TEMPLATES = {
    "ieee": {
        "type": "latex",
        "path": str(TEMPLATES_DIR / "ieee" / "ieee.latex"),
        "engine": "xelatex",
        "default_csl": "ieee",
    },
    "academic": {  # Modular Eisvogel Template
        "type": "latex",
        "path": str(TEMPLATES_DIR / "academic" / "academic.latex"),
        "engine": "xelatex",
        "default_csl": "apa",  # Standard for academic essays
    },
}


def build_command(input_file, template_name, custom_csl=None):
    if template_name not in TEMPLATES:
        print(f"❌ Error: Template '{template_name}' is not defined.")
        return None

    tmpl = TEMPLATES[template_name]
    input_path = Path(input_file).resolve()
    current_dir = input_path.parent

    # Identify the specific subdirectory for this template's assets
    template_subdir = Path(tmpl["path"]).parent

    output_ext = "pdf" if tmpl["type"] == "latex" else "odt"
    output_file = f"{input_path.stem}_{template_name}.{output_ext}"

    # --- RESOURCE MANAGEMENT (Crucial for Modular Templates) ---
    # We add the template_subdir so Pandoc can find \input{common.latex}, etc.
    resource_paths = [
        ".",
        str(current_dir),
        str(template_subdir),
        str(current_dir / "attachments"),
        str(HOME / "Documents/my-cs-notes/attachments"),
    ]
    resource_path_str = ":".join(resource_paths)

    # Bibliography detection (finds the first .bib in the document directory)
    bib_files = list(current_dir.glob("*.bib"))
    bib_arg = ["--bibliography", str(bib_files[0])] if bib_files else []

    # Base Pandoc Command
    cmd = [
        "pandoc",
        str(input_path),
        "--citeproc",
        "--resource-path",
        resource_path_str,
    ] + bib_arg

    # --- CITATION STYLE LOGIC ---
    style_name = custom_csl if custom_csl else tmpl["default_csl"]
    csl_path = CSL_DIR / f"{style_name}.csl"

    if csl_path.exists():
        cmd += ["--csl", str(csl_path)]
    else:
        print(f"⚠️ Warning: Citation style '{style_name}' not found in {CSL_DIR}.")

    # --- TEMPLATE ENGINE LOGIC ---
    if tmpl["type"] == "latex":
        cmd += ["--template", tmpl["path"], "--pdf-engine", tmpl["engine"]]
    else:
        cmd += ["--reference-doc", tmpl["path"]]

    cmd += ["-o", output_file]
    return cmd, output_file


def main():
    parser = argparse.ArgumentParser(description="lagOS-station Academic Build System")
    parser.add_argument("file", help="Markdown file to compile")
    parser.add_argument("--type", default="ieee", help="Template type (ieee/academic)")
    parser.add_argument("--csl", help="Citation style (apa, ieee, chicago, etc.)")
    args = parser.parse_args()

    if not os.path.exists(args.file):
        print(f"❌ Error: File '{args.file}' not found.")
        sys.exit(1)

    result = build_command(args.file, args.type, args.csl)
    if result:
        command, output_name = result
        print(f"🏗️  Building '{args.file}' using {args.type} template...")
        try:
            subprocess.run(command, check=True)
            print(f"✅ Success! Generated: {output_name}")
            # Automatic preview on Fedora
            subprocess.run(["xdg-open", output_name])
        except subprocess.CalledProcessError:
            print("❌ Error: Pandoc failed to compile the document.")


if __name__ == "__main__":
    main()
