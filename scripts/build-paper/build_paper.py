#!/usr/bin/env python3
import argparse
import datetime
import re
import shutil
import subprocess
import sys
import tempfile
import zipfile
from pathlib import Path
from xml.sax.saxutils import escape

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
        "lua_filters": [str(TEMPLATES_DIR / "table-captions.lua")],
        "default_csl": "apa",
    },
    "ieee": {
        "type": "latex",
        "path": str(TEMPLATES_DIR / "ieee" / "ieee.latex"),
        "engine": "xelatex",
        "lua_filters": [str(TEMPLATES_DIR / "table-captions.lua")],
        "default_csl": "ieee",
    },
    "academic": {  # Modular Eisvogel Template
        "type": "latex",
        "path": str(TEMPLATES_DIR / "academic" / "academic.latex"),
        "engine": "xelatex",
        "default_csl": "apa",
    },
    "aa-report": {  # A&A practice/research report (Word template from the Networks area)
        "type": "docx",
        "path": str(TEMPLATES_DIR / "aa-report" / "reference.docx"),
        "lua_filters": [str(TEMPLATES_DIR / "aa-report" / "aa-report.lua")],
        "default_csl": "ieee",
        "pdf": True,  # also export a PDF with LibreOffice
    },
}


def read_metadata(input_path, keys):
    """Reads frontmatter fields through Pandoc itself (no YAML dependency)."""
    sep = "\x1f"
    with tempfile.NamedTemporaryFile("w", suffix=".txt", delete=False) as tpl:
        tpl.write(sep.join(f"${k}$" for k in keys))
    try:
        out = subprocess.run(
            ["pandoc", str(input_path), "--to", "plain", "--template", tpl.name],
            capture_output=True, text=True, check=True,
        ).stdout
    finally:
        Path(tpl.name).unlink()
    values = out.rstrip("\n").split(sep)
    return {k: v.strip() for k, v in zip(keys, values + [""] * len(keys))}


def headings_numbered_by_hand(input_path):
    """True when most headings already start with a number ("## 1. Intro", "# 2 Results"),
    so adding Pandoc's numbers would give "1 1. Intro"."""
    text = Path(input_path).read_text(encoding="utf8")
    # Skip the YAML frontmatter: its "# comments" are not headings
    frontmatter = re.match(r"---\n.*?\n(---|\.\.\.)\n", text, re.S)
    if frontmatter:
        text = text[frontmatter.end():]
    in_code = False
    headings = numbered = 0
    for line in text.splitlines():
        if line.startswith(("```", "~~~")):
            in_code = not in_code
        if in_code or not re.match(r"#{1,6} ", line):
            continue
        headings += 1
        if re.match(r"#{1,6} +([0-9]+|[IVXLC]+)(\.[0-9]+)*\.? ", line):
            numbered += 1
    return headings > 0 and numbered * 2 >= headings


def find_resource(name, base_dir, search_dirs):
    """Absolute path of a file named in the frontmatter: as written (relative to the
    note), then in each resource directory, by its path and then by its file name."""
    candidate = Path(name).expanduser()
    if candidate.is_absolute():
        return candidate if candidate.exists() else None
    if (base_dir / candidate).exists():
        return (base_dir / candidate).resolve()
    for folder in search_dirs:
        for option in (Path(folder) / candidate, Path(folder) / candidate.name):
            if option.exists():
                return option.resolve()
    return None


def default_periodo(today=None):
    """BUAP periods: Primavera (Jan-May), Verano (Jun-Jul), Otoño (Aug-Dec)."""
    today = today or datetime.date.today()
    if today.month <= 5:
        season = "Primavera"
    elif today.month <= 7:
        season = "Verano"
    else:
        season = "Otoño"
    return f"{season} {today.year}"


def build_command(input_file, template_name, custom_csl=None, verbose=False):
    """Generates the Pandoc command with robust resource and bibliography detection."""
    if template_name not in TEMPLATES:
        print(f"❌ Error: Template '{template_name}' is not defined. Options: {', '.join(TEMPLATES)}")
        return None

    tmpl = TEMPLATES[template_name]
    input_path = Path(input_file).resolve()
    current_dir = input_path.parent
    template_subdir = Path(tmpl["path"]).parent

    # Deterministic output naming, next to the Markdown file
    output_ext = "pdf" if tmpl["type"] == "latex" else tmpl["type"]
    output_file = current_dir / f"{input_path.stem}_{template_name}.{output_ext}"

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
    # The vault's root holds shared images (e.g. Logo_BUAP_lightBlue.png)
    cs_notes_root = HOME / "Documents/my-cs-notes"
    if cs_notes_root.exists():
        resource_paths.add(str(cs_notes_root))

    resource_path_str = ":".join(resource_paths)

    # 2. DETERMINISTIC BIBLIOGRAPHY DETECTION
    # The frontmatter's "bibliography" wins; otherwise a .bib with the same name
    # as the markdown file, otherwise the first .bib in the project directory
    meta = read_metadata(input_path, ["bibliography", "number-sections", "titlepage-logo"])
    bib_arg = []
    if not meta["bibliography"]:
        target_bib = input_path.with_suffix(".bib")
        bib_files = [target_bib] if target_bib.exists() else sorted(current_dir.glob("*.bib"))
        if bib_files:
            bib_arg = ["--bibliography", str(bib_files[0])]

    # 3. SECTION NUMBERS
    # Pandoc ignores "number-sections" in the frontmatter; it's a command-line option.
    # The docx templates number headings in their Lua filter instead.
    number_arg = []
    if tmpl["type"] == "latex" and meta["number-sections"] == "true":
        if headings_numbered_by_hand(input_path):
            print("ℹ️  Headings are already numbered by hand: not adding section numbers.")
        else:
            number_arg = ["--number-sections"]

    # 4. TITLE PAGE LOGO
    # LaTeX reads it relative to the note, not through Pandoc's resource path:
    # look for it like an image, and drop it with a warning instead of failing
    logo_arg = []
    if tmpl["type"] == "latex" and meta["titlepage-logo"]:
        logo = find_resource(meta["titlepage-logo"], current_dir, resource_paths)
        if logo:
            logo_arg = ["-M", f"titlepage-logo={logo}"]
        else:
            print(f"⚠️ Logo '{meta['titlepage-logo']}' not found: building without it.")
            logo_arg = ["-M", "titlepage-logo="]

    # 5. COMMAND CONSTRUCTION
    cmd = ["pandoc", str(input_path)] + number_arg + logo_arg

    # Lua filters run before citeproc so they can set e.g. the references title
    for lua_filter in [str(TEMPLATES_DIR / "clean-metadata.lua")] + tmpl.get("lua_filters", []):
        cmd += ["--lua-filter", lua_filter]

    cmd += ["--citeproc", "--resource-path", resource_path_str] + bib_arg

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

    cmd += ["-o", str(output_file)]

    if verbose:
        print(f"🛠️  Debug - Resource Path: {resource_path_str}")
        print(f"🛠️  Debug - Full Command: {' '.join(cmd)}")

    return cmd, output_file


def fill_docx_placeholders(input_path, docx_path):
    """Writes subject, period and area into the headers/footers of the aa-report template."""
    meta = read_metadata(input_path, ["materia", "periodo", "area"])
    materia = meta["materia"] or "NOMBRE DE LA MATERIA"
    periodo = meta["periodo"] or default_periodo()
    area = meta["area"] or "Área de Redes"
    values = {
        "{{HEADER_MATERIA}}": f"{materia.upper()} PERIODO {periodo.upper()}",
        "{{PERIODO}}": periodo,
        "{{AREA}}": area,
    }

    tmp_path = docx_path.with_suffix(".tmp.docx")
    with zipfile.ZipFile(docx_path) as src, zipfile.ZipFile(tmp_path, "w", zipfile.ZIP_DEFLATED) as dst:
        for item in src.infolist():
            data = src.read(item.filename)
            name = item.filename
            if name.startswith("word/header") or name.startswith("word/footer"):
                xml = data.decode("utf8")
                for key, value in values.items():
                    xml = xml.replace(key, escape(value))
                data = xml.encode("utf8")
            dst.writestr(item, data)
    tmp_path.replace(docx_path)


def export_pdf(docx_path):
    """Converts the DOCX to PDF with LibreOffice, using a private profile so an
    open LibreOffice window does not block the headless conversion."""
    soffice = shutil.which("soffice") or shutil.which("libreoffice")
    if not soffice:
        print("⚠️ LibreOffice not found: only the DOCX was generated.")
        return None
    with tempfile.TemporaryDirectory() as profile:
        subprocess.run(
            [soffice, f"-env:UserInstallation=file://{profile}", "--headless",
             "--convert-to", "pdf", "--outdir", str(docx_path.parent), str(docx_path)],
            check=True, capture_output=True,
        )
    pdf_path = docx_path.with_suffix(".pdf")
    return pdf_path if pdf_path.exists() else None


def main():
    parser = argparse.ArgumentParser(description="lagOS-station Academic Build System")
    parser.add_argument("file", help="The Markdown file to compile")
    # DEFAULT: Automatically uses std-report for standard documentation tasks
    parser.add_argument(
        "--type", default="std-report", help=f"Template type: {', '.join(TEMPLATES)} (default: std-report)"
    )
    parser.add_argument(
        "--csl", help="Override the default citation style (e.g., apa, ieee)"
    )
    parser.add_argument(
        "--no-open", action="store_true", help="Do not open the result when done"
    )
    parser.add_argument(
        "-v", "--verbose", action="store_true", help="Print debug information"
    )

    args = parser.parse_args()

    if not Path(args.file).exists():
        print(f"❌ Error: File '{args.file}' not found.")
        sys.exit(1)

    if not shutil.which("pandoc"):
        print("❌ Error: pandoc is not installed or not on PATH.")
        sys.exit(1)

    result = build_command(args.file, args.type, args.csl, args.verbose)

    if result is None:
        sys.exit(1)

    command, output_file = result
    input_path = Path(args.file).resolve()
    tmpl = TEMPLATES[args.type]
    print(f"🏗️  Building '{args.file}' using {args.type} template...")

    try:
        # Run from the document's folder so relative paths (logos, images) resolve
        subprocess.run(command, check=True, cwd=input_path.parent)

        if tmpl["type"] == "docx":
            fill_docx_placeholders(input_path, output_file)
            pdf = export_pdf(output_file) if tmpl.get("pdf") else None
            if pdf:
                print(f"✅ Success! Generated: {output_file.name} and {pdf.name}")
                output_file = pdf
            else:
                print(f"✅ Success! Generated: {output_file.name}")
        else:
            print(f"✅ Success! Generated: {output_file.name}")

        # Automatic preview using xdg-open for Fedora
        if not args.no_open:
            subprocess.run(["xdg-open", str(output_file)])
    except subprocess.CalledProcessError:
        print(
            "❌ Error: the build failed. Check the document syntax or use -v for more info."
        )
        sys.exit(1)


if __name__ == "__main__":
    main()
