# 🎓 lagOS Academic Build System

A robust, Python-based CLI tool designed to automate the academic publishing pipeline for the **lagOS-station**. This system streamlines the conversion of Markdown-based research—authored in Obsidian or Neovim—into professional, high-fidelity PDFs using **Pandoc**, **XeLaTeX**, and a modular template engine.

## 🏗️ Architecture: Separation of Concerns (SoC)

The system is decoupled into three layers to ensure that style changes never interfere with your research content:

1.  **Content Layer**: Markdown files (`.md`) and research drafts located in your research directories (e.g., `Documents/uni/research/`).
2.  **Logic Layer**: A centralized Python engine (`build_paper.py`) that manages command construction and resource paths.
3.  **Asset Layer**: Localized **CSL** (Citation Style Language) and **Modular LaTeX** templates stored within your dotfiles for full version control.

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
    ├── academic/         # Modular Eisvogel Engine (BUAP Branded)
    │   ├── academic.latex  # Main loader/orchestrator
    │   ├── common.latex    # Global LaTeX logic
    │   ├── eisvogel-title-page.latex # Title page logic
    │   └── ...             # Modular components (fonts, hypersetup, etc.)
    └── ieee/             # Monolithic IEEE Template
        └── ieee.latex    # Single-file IEEE transaction format
```

## 🛠️ Prerequisites

To maintain the high-fidelity rendering required for BUAP engineering reports, ensure the following are installed on your Fedora host:
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

The tool automatically detects any .bib files in your current working directory to resolve citations via the Pandoc citeproc engine.
1. Generate IEEE Paper (Standard)

Optimized for technical protocols and engineering submissions following IEEE standards.
```Bash
build-paper my_research.md --type ieee
```
2. Generate Academic Report (BUAP Branded)

Uses the modular Eisvogel engine with an "Azul Institucional" (003b5c) cover page and APA citations.
```Bash
build-paper draft.md --type academic
```

3. Custom Citation Styles

Override the template's default citation style on the fly (e.g., using IEEE style for an academic report):
```Bash
build-paper draft.md --type academic --csl ieee
```
## 🎨 Asset Management
- Images: The script automatically looks for images in an attachments/ folder relative to your Markdown file.
- Logos: For the academic template, ensure Logo_BUAP_lightBlue.png is in your project's attachments folder to appear on the title page.
- Customization: To edit the cover page layout, modify templates/academic/eisvogel-title-page.latex. Your changes are tracked by Git within your dotfiles.

## 🤝 Acknowledgements

This build system is powered by excellent community-driven templates. Special thanks to:
- **Pascal Wagler (Wandmalfarbe)**: Creator of the Eisvogel template, which provides the modular foundation for our academic reports.

- **Sanyam Khurana (stsewd)**: For the ieee-pandoc-template, which provides the robust IEEE LaTeX template and the corresponding CSL file.

- **The Pandoc Community**: For building the "Swiss-army knife" of document conversion.
