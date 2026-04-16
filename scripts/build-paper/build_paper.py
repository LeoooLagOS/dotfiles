#!/usr/bin/env python3
import argparse
import subprocess
import os
import sys
from pathlib import Path

# --- PORTABLE PATH LOGIC (lagOS-station Infrastructure) ---
# Resolve script directory dynamically for dotfiles portability
SCRIPT_DIR = Path(__file__).resolve().parent
TEMPLATES_DIR = SCRIPT_DIR / "templates"
CSL_DIR = SCRIPT_DIR / "csl"
HOME = Path.home()

# Template Configuration - Optimized for daily academic documentation
TEMPLATES = {
    "std-report": {
        "type": "latex",
        "path": str(TEMPLATES_DIR / "std-report" / "std-report.latex"),
        "engine": "xelatex",
        "default_csl": "apa",
    },
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
        "default_csl": "apa",
    },
}


def build_command(input_file, template_name, custom_csl=None, verbose=False):
    """Generates the Pandoc command with robust resource and bibliography detection."""
    if template_name not in TEMPLATES:
        print(f"❌ Error: Template '{template_name}' is not defined.")
        return None

    tmpl = TEMPLATES[template_name]
    input_path = Path(input_file).resolve()
    current_dir = input_path.parent
    template_subdir = Path(tmpl["path"]).parent

    # Deterministic output naming
    output_ext = "pdf" if tmpl["type"] == "latex" else "odt"
    output_file = f"{input_path.stem}_{template_name}.{output_ext}"

    # 1. ROBUST RESOURCE PATHS (Preventing silent failures in XeLaTeX)
    # Uses a set to ensure unique paths for images and modular LaTeX headers
    resource_paths = {
        ".",
        str(current_dir),
        str(template_subdir),
        str(current_dir / "attachments"),
    }

    # Obsidian Attachment Integration - Validates existence before adding
    cs_notes_attachments = HOME / "Documents/my-cs-notes/attachments"
    if cs_notes_attachments.exists():
        resource_paths.add(str(cs_notes_attachments))

    resource_path_str = ":".join(resource_paths)

    # 2. DETERMINISTIC BIBLIOGRAPHY DETECTION
    # Prioritizes a .bib file with the same name as the markdown file
    target_bib = input_path.with_suffix(".bib")
    if target_bib.exists():
        bib_arg = ["--bibliography", str(target_bib)]
    else:
        # Fallback to the first available .bib in the project directory
        bib_files = list(current_dir.glob("*.bib"))
        bib_arg = ["--bibliography", str(bib_files[0])] if bib_files else []

    # 3. COMMAND CONSTRUCTION
    cmd = [
        "pandoc",
        str(input_path),
        "--citeproc",
        "--resource-path",
        resource_path_str,
    ] + bib_arg

    # Citation Style Logic
    style_name = custom_csl if custom_csl else tmpl["default_csl"]
    csl_path = CSL_DIR / f"{style_name}.csl"
    if csl_path.exists():
        cmd += ["--csl", str(csl_path)]
    elif verbose:
        print(f"⚠️ Warning: CSL '{style_name}' not found. Using Pandoc defaults.")

    # Engine and Template logic
    if tmpl["type"] == "latex":
        cmd += ["--template", tmpl["path"], "--pdf-engine", tmpl["engine"]]
    else:
        cmd += ["--reference-doc", tmpl["path"]]

    cmd += ["-o", output_file]

    if verbose:
        print(f"🛠️  Debug - Resource Path: {resource_path_str}")
        print(f"🛠️  Debug - Full Command: {' '.join(cmd)}")

    return cmd, output_file


def main():
    parser = argparse.ArgumentParser(description="lagOS-station Academic Build System")
    parser.add_argument("file", help="The Markdown file to compile")
    # DEFAULT: Automatically uses std-report for standard documentation tasks
    parser.add_argument(
        "--type", default="std-report", help="Template type (default: std-report)"
    )
    parser.add_argument(
        "--csl", help="Override the default citation style (e.g., apa, ieee)"
    )
    parser.add_argument(
        "-v", "--verbose", action="store_true", help="Print debug information"
    )

    args = parser.parse_args()

    if not Path(args.file).exists():
        print(f"❌ Error: File '{args.file}' not found.")
        sys.exit(1)

    result = build_command(args.file, args.type, args.csl, args.verbose)

    if result:
        command, output_name = result
        print(f"🏗️  Building '{args.file}' using {args.type} template...")

        try:
            # Execute Pandoc subprocess
            subprocess.run(command, check=True)
            print(f"✅ Success! Generated: {output_name}")

            # Automatic preview using xdg-open for Fedora
            subprocess.run(["xdg-open", output_name])
        except subprocess.CalledProcessError:
            print(
                "❌ Error: Pandoc failed to compile. Check LaTeX syntax or use -v for more info."
            )


if __name__ == "__main__":
    main()
