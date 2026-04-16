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
└── templates/            # Encapsulated LaTeX templates
    ├── std-report/       # Daily Driver: Two-column academic layout
    │   └── std-report.latex # Stability-focused template for BUAP reports
    ├── academic/         # Modular Eisvogel Engine (BUAP Branded)
    │   ├── academic.latex  # Main loader/orchestrator
    │   └── ...             # Modular components (fonts, titles, etc.)
    └── ieee/             # Monolithic IEEE Template
        └── ieee.latex    # Single-file IEEE transaction format
```

## 🛠️ Prerequisites

To maintain the high-fidelity rendering required for engineering, academic or investigation reports, ensure the following are installed on your  host:
- Pandoc 3.x: The core document converter.
- TeX Live (Full Scheme): Essential for modular LaTeX components like footnotebackref.sty.
    - Install via: sudo dnf install texlive-scheme-full.
- Python 3.10+: To run the automation logic.
- Zotero + Better BibTeX: For managing your My Library.bib research database.

## 🚀 Installation & Setup
1. Grant execution permissions:

    ```Bash
    chmod +x ~/dotfiles/scripts/build-paper/build_paper.py
    ```
2. Create a symbolic link to your local bin (ensure ~/.local/bin is in your $PATH):

    ```Bash
    ln -s ~/dotfiles/scripts/build-paper/build_paper.py ~/.local/bin/build-paper
    ```

## 📖 Usage

The tool automatically detects any `.bib` files in the current working directory to resolve citations via the Pandoc citeproc engine.

1. Standard Academic Report (Default)

Optimized for daily documentation and laboratory reports. Uses a clean two-column layout.
```Bash
build-paper my_report.md
```
2. IEEE Paper

Follows the official IEEE transaction format for technical protocols and engineering submissions.
```Bash
build-paper my_research.md --type ieee
```

3. Universal Modular Engine

Uses the Eisvogel foundation for high-customization reports. Settings like title page colors and logos are managed via the Markdown YAML frontmatter.
```Bash
build-paper draft.md --type academic --csl apa
```

4. Custom Styles

Override the default citation style on the fly:
```bash
build-paper draft.md --type academic --csl ieee
```

## ⚠️ Known Issues & Troubleshooting
### APA "Phantom Brackets" (std-report)

In the current MVP version of the std-report template, using APA (author-date) citations can cause an alignment drift in the bibliography.
- **Symptom:** Citations are pushed into the gutter or display "phantom" indentation where a numeric label would normally be.
- **Status:** Under investigation for version 1.1.
- **Workaround:** For mission-critical alignment, use --csl ieee or switch to the academic template type.

## 🎨 Asset Management
- **Images:** The script automatically looks for images in an attachments/ folder relative to your Markdown file.
- **Stability Bridge:** The `std-report` template includes logic to ensure wide tables are scaled to fit within a single column.
- **Logos:** For the academic template, ensure your Logo (`eg. Logo_BUAP_lightBlue.png`) is in your project's attachments folder to appear on the title page.
- **Customization:** To edit the cover page layout, modify templates/academic/eisvogel-title-page.latex. 

## 🤝 Acknowledgements

This build system is powered by excellent community-driven templates. Special thanks to:
- **Pascal Wagler (Wandmalfarbe)**: Creator of the Eisvogel template, which provides the modular foundation for our academic reports.

- **Sanyam Khurana (stsewd)**: For the ieee-pandoc-template, which provides the robust IEEE LaTeX template and the corresponding CSL file.

- **The Pandoc Community**: For building the "Swiss-army knife" of document conversion.
