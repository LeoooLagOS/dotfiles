# 🎓 lagOS Academic Build System

A robust, Python-based CLI tool designed to automate the academic publishing pipeline for the lagOS-station. This system streamlines the conversion of Markdown-based research drafts—authored in Obsidian, Neovim (or your favourite Text Editor)—into professional IEEE-formatted PDFs or ODT reports using Pandoc and XeLaTeX.

## 🏗️ Architecture: Separation of Concerns (SoC)

The system is architected into three decoupled layers to ensure scalability and maintainability:

1. **Content Layer**: Markdown files (.md) and research drafts located in the Obsidian Vault or dedicated research directories.

2. **Logic Layer**: A centralized Python engine (build_paper.py) managed within the dotfiles repository.

3. **Tooling Layer**: Global Pandoc templates (~/.local/share/pandoc/templates/) and system-wide binaries (~/.local/bin/).

## 🛠️ Prerequisites

To ensure successful compilation, the following dependencies must be present on the system:
- Pandoc 3.x: The core document converter.
- TeX Live (XeLaTeX): Required for high-fidelity PDF rendering and IEEE typography.
- Zotero + Better BibTeX: For dynamic .bib file generation and bibliography management.
- IEEE Pandoc Template: Installed in the global Pandoc data directory.

## 🚀 Installation & Setup

The script is integrated into the shell environment via a symbolic link, allowing for global execution without path hardcoding:
Bash

### 1. Grant execution permissions
`chmod +x build_paper.py`

### 2. Link the script to your local binaries directory
`ln -s $(pwd)/build_paper.py ~/.local/bin/build-paper`

*Note: Ensure ~/.local/bin is exported in your $PATH within your .zshrc.*

## 📖 Usage

The tool automatically detects .bib files in the working directory to resolve citations via the Pandoc citeproc engine.
1. Generate **IEEE** Paper (**Default**)

Optimized for final research protocols.
```Bash
build-paper my_research.md
```

2. Generate Academic Report (ODT)

Uses the academia_template.odt reference document for editable drafts in LibreOffice.
```Bash
build-paper draft.md --type academia
```

## 📂 Project Structure
- build_paper.py: Core logic for command construction and subprocess management.
- README.md: System documentation and maintenance guide.
- `~/.local/share/pandoc/templates/ieee.latex`: The global LaTeX template used for PDF generation.