# 🎓 lagOS Academic Build System

A robust, Python-based CLI tool designed to automate the academic publishing pipeline for the **lagOS-station**. This system streamlines the conversion of Markdown-based research—authored in **Obsidian** or **Neovim**—into professional, high-fidelity PDFs using **Pandoc**, **XeLaTeX**, and a modular template engine.

## 🏗️ Architecture: Separation of Concerns (SoC)

The system is decoupled into three layers to ensure that style changes never interfere with your research content:

1.  **Content Layer**: Markdown files (`.md`) and research drafts located in your project or vault directories.
2.  **Logic Layer**: A centralized Python engine (`build_paper.py`) that manages command construction, deterministic bibliography detection, and resource paths.
3.  **Asset Layer**: Localized **CSL** (Citation Style Language) and **Modular LaTeX** templates stored within this dotfiles directory for full version control.

---

## 📂 Project Structure

Templates are organized into encapsulated subdirectories to prevent file collisions and allow for granular customization of the LaTeX environment.

```text
build-paper/
├── build_paper.py        # Core Python engine and path manager
├── README.md             # This documentation
├── csl/                  # Citation Style Language folder
│   ├── apa.csl           # APA 7th Edition (Default for Academic)
│   └── ieee.csl          # IEEE Standard (Default for IEEE)
├── cv-ats-classic/       # ATS-friendly CV template (standalone, see below)
└── templates/            # Encapsulated LaTeX templates
    ├── std-report/       # Daily Driver: Two-column academic layout
    │   └── std-report.latex # Stability-focused template for BUAP reports
    ├── academic/         # Modular Eisvogel Engine (BUAP Branded)
    │   ├── academic.latex  # Main loader/orchestrator
    │   ├── template_academic.md # Starter document with frontmatter
    │   └── ...             # Modular components (fonts, titles, etc.)
    ├── ieee/             # Monolithic IEEE Template
    │   ├── ieee.latex    # Single-file IEEEtran template (conference mode)
    │   └── template_ieee.md # Starter document with frontmatter
    ├── aa-report/        # A&A practice report (Word template, Networks area)
    │   ├── plantilla_original.docx # Template as handed out in class
    │   ├── make_reference.py      # Builds reference.docx from it
    │   ├── reference.docx         # Styles, headers and footers used by Pandoc
    │   ├── aa-report.lua          # Title block, section/figure/table numbers
    │   └── template_aa-report.md  # Starter document with frontmatter
    ├── table-captions.lua # Table captions for std-report and ieee
    └── clean-metadata.lua # Runs first for every template (e.g. an empty bibliography)
```

## 🛠️ Prerequisites

To maintain the high-fidelity rendering required for engineering, academic or investigation reports, ensure the following are installed on your  host:
- Pandoc 3.x: The core document converter.
- TeX Live (Full Scheme): Essential for modular LaTeX components like footnotebackref.sty.
    - Install via: sudo dnf install texlive-scheme-full.
- Python 3.10+: To run the automation logic.
- Zotero + Better BibTeX: For managing your My Library.bib research database.

## 🚀 Installation & Setup

The `links` step of the repository's `install.sh` links `build_paper.py` to `~/.local/bin/build-paper`:

```Bash
~/dotfiles/install.sh --only links
```

`~/.local/bin` is already on `PATH` through `zsh/conf.d/00-env.zsh`.

## 📖 Usage

Citations are resolved with Pandoc citeproc. The bibliography is the `bibliography:` field of the frontmatter; if there is none, `<name>.bib` next to the Markdown file, otherwise the first `.bib` file in that directory. The output is written next to the Markdown file, whatever the current directory. Add `-v` / `--verbose` to print the generated Pandoc command and `--no-open` to skip opening the result.

1. Standard Academic Report (Default)

Optimized for daily documentation and laboratory reports. Uses a clean two-column layout.
```Bash
build-paper my_report.md
```
2. IEEE Paper

IEEEtran in conference mode (two columns, Roman section numbers with `number-sections: true`) for technical papers.
```Bash
build-paper my_research.md --type ieee
```

3. Universal Modular Engine

Uses the Eisvogel foundation for high-customization reports. Settings like title page colors and logos are managed via the Markdown YAML frontmatter.
```Bash
build-paper draft.md --type academic --csl apa
```

4. A&A Practice Report (DOCX + PDF)

Reproduces the Word template of the Networks area (`Plantilla_A&A_ReportesPractica e Investigación2025.docx`): Spanish and English titles, numbered affiliations, "Resumen", keywords, numbered sections ("1 Introducción", "1.1 ..."), "Figura 1." / "Tabla 1." captions and IEEE references. Generates `<name>_aa-report.docx` and, through LibreOffice, `<name>_aa-report.pdf`.
```Bash
build-paper reporte.md --type aa-report
```
Start from `templates/aa-report/template_aa-report.md`. Frontmatter fields:

| Field | Use |
|---|---|
| `title`, `title-en` | Spanish and English titles (`subtitle` is accepted instead of `title-en`) |
| `author` | List of `{name, affiliation, location, email}`; equal affiliations share a number |
| `affiliations` | Optional explicit list; then `author.affiliation` is its number (1, 2, ...) |
| `abstract`, `keywords` | "Resumen" and "Keywords and phrases" |
| `materia`, `periodo`, `area` | Page headers/footers (default period from the date, e.g. "Otoño 2026") |
| `number-sections` | `false` if the headings are already numbered by hand |

Write headings without numbers (`# Introducción`); the filter numbers them. If the class template changes, replace `plantilla_original.docx` and run `python3 templates/aa-report/make_reference.py`.

**The template itself is not in this repo:** the `.docx` belongs to the A&A Networks area (its authors, logo and example text). Put the file your professor gives you at `templates/aa-report/plantilla_original.docx` and run `make_reference.py` once to create `reference.docx`; both are git-ignored.

5. Custom Styles

Override the default citation style on the fly:
```bash
build-paper draft.md --type academic --csl ieee
```

## 🧾 Frontmatter Behavior
- **`number-sections: true`** numbers the headings (Pandoc only accepts it on the command line, so build-paper passes it). If most headings are already numbered by hand (`## 1. Introducción`, `# I. INTRODUCCIÓN`), nothing is added and a note says so. Mark a heading as unnumbered with `# Resumen {-}`.
- **`lang: es`** translates captions and labels ("Cuadro", "Figura", "Índice", "Resumen") in every template.
- **An empty `bibliography:`** is ignored instead of failing the build.
- **`std-report`** reads `subtitle`, `toc`, `number-sections`, `lang`, and authors written as plain names or as `{name, affiliation, email}`.
- **`academic`** keeps headings with the table or text that follows (they move to the next page together). Turn it off with `allow-orphan-headings: true`.

## ⚠️ Known Issues & Troubleshooting
- **"You have requested release 2026/06/01 of LaTeX" warning:** harmless; a package is newer than the installed LaTeX kernel.
- **The PDF of `aa-report`** comes from LibreOffice and may substitute fonts (Calibri, Consolas) that aren't installed; the `.docx` is the file to hand in.

## 🎨 Asset Management
- **Images:** The script looks for images in an `attachments/` folder next to your Markdown file, and in the Obsidian vault (`~/Documents/my-cs-notes/attachments` and its root) when it exists.
- **Stability Bridge:** The `std-report` template includes logic to ensure wide tables are scaled to fit within a single column.
- **Logos:** `titlepage-logo: Logo_BUAP_lightBlue.png` is looked up like an image: next to the note, in `attachments/`, then in the vault (its root and `attachments/`). If it isn't found, the build goes on without it and prints a warning.
- **Customization:** To edit the cover page layout, modify templates/academic/eisvogel-title-page.latex. 

## 📄 CV Template (cv-ats-classic)

`cv-ats-classic/` holds an ATS-friendly résumé template. It is not one of the `--type` options; build it with Pandoc directly:

```Bash
cd ~/dotfiles/scripts/build-paper/cv-ats-classic
cp template_ats-classic.md ~/cv.md   # fill in the frontmatter and sections
pandoc ~/cv.md --template ats-classic.latex --pdf-engine=xelatex -o ~/cv.pdf
```

## 🤝 Acknowledgements

This build system is powered by excellent community-driven templates. Special thanks to:
- **Pascal Wagler (Wandmalfarbe)**: Creator of the Eisvogel template, which provides the modular foundation for our academic reports.

- **Sanyam Khurana (stsewd)**: For the ieee-pandoc-template, which provides the robust IEEE LaTeX template and the corresponding CSL file.

- **The Pandoc Community**: For building the "Swiss-army knife" of document conversion.
