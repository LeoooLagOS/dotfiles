---
tags:
  - overview
  - setup
  - linux
  - fedora
  - hyprland
category: setup
status: active
related: "[[_Linux]]"
date: 2025-12-08
---
# _Fedora Workstation_

## 📝 One-Sentence Summary
My primary development and academic environment running on Fedora Linux, configured with a [[Hyprland]] [[Window Manager]] and a strict "[[IaC|Infrastructure as Code]]" philosophy for configuration management.

## 💡 Analogy
This workstation is my **Digital Workshop**. Just as a carpenter organizes their physical tools (saws, hammers) into specific, labeled areas and keeps their blueprints safe, this system organizes my data (`Documents`), my active construction sites (`Development`), and the instructions for how the workshop itself behaves (`dotfiles`).

## 📜 History & Creator
* **Curator:** lagOS
* **Evolution:** Migrated from a standard layout to a developer-centric structure to support Computer Science studies and self-taught AI/Engineering projects.
* **Current Iteration:** Fedora 43 (target) running a custom Hyprland environment with Apple-inspired aesthetics.

## 🔑 Core Philosophy & Design
* **Separation of Concerns:** Data (Notes), Code (Projects), and Configuration (System) are strictly separated to prevent clutter and data loss.
* **Reproducibility:** The system configuration is version-controlled via Git, allowing the entire environment to be restored or replicated on a new machine instantly.
* **Aesthetics meets Function:** A visual style (Apple-like lock screen, blurred glass) that encourages usage without sacrificing the speed of a tiling window manager.

## 🌳 System Structure 
A visual representation of the directory hierarchy separating Configuration, Code, and Data. 
```text 
/home/lag-os/ 
│ 
├── ⚙️ dotfiles/     (Git Repository: System Configuration) 
│ ├── .git/          (Version Control) 
│ ├── hypr/ 
│ │ ├── hyprland.conf             (Window Manager Settings) 
│ │ ├── hyprlock.conf             (Lock Screen Styling) 
│ │ └── scripts/  (Automation: Music.sh, AutoLockscreen.sh) │ └── README.md                   (System Documentation) 
│ 
├── 🚀 Development/               (Active Projects & Code) 
│ ├── proyects-ai/                (AI & Machine Learning) 
│ ├── uni-cs-projects/            (University Coursework) 
│ └── websites/                  (Web Development Practice) 
│ 
├── 🏛️ Documents/                 (Static Data & Knowledge) 
│ └── Obsidian-Vault/             (Second Brain / CS Notes) 
│ 
└── 📥 Downloads/                 (Temporary Intake Buffer)
```


## ⚙️ Key Details

### 1. The Home Directory Structure 🏠
My `$HOME` directory is organized to separate "consumption" from "creation":

- **`~/dotfiles/`**: The Git repository containing system configurations (Hyprland, Waybar, Scripts). This is the "brain" of the setup.
- **`~/Development/`**: The workspace for active coding.
    - `proyects-ai/`: Artificial Intelligence projects.
    - `uni-cs-projects/`: University coursework.
    - `websites/`: Web development practice.
- **`~/Documents/`**: Static knowledge and data.
    - `Obsidian-Vault/`: The "Second Brain" and CS Notes.
- **`~/Downloads/`**: Temporary intake buffer (regularly purged).

### 2. The Dotfiles (Configuration) 🛠️
Managed in `~/dotfiles`, these configurations control the behavior and look of the system:

* **Window Manager:** [[Hyprland]] (Tiling WM).
* **Lock Screen:** [[Hyprlock]] (Custom Apple-style aesthetic with weather and music integration).
* **Color Scheme:** [[Wallust]] (Generates colors from wallpapers).
* **Automation Scripts:**
    * `Music.sh`: extracts metadata and album art for the lock screen.
    * `AutoLockscreen.sh`: syncs the lock screen background with the desktop wallpaper.

## 🔗 Connections & Implementations
* **OS Base:** [[Linux Distros|Fedora Linux]]
* **Shell:** [[Shell|Zsh]] (Likely, or Bash depending on preference)
* **Version Control:** [[_Git]] (Used to manage the `dotfiles` folder)

## See Also
- [[_Linux]]
- [[_Git]]
- [[Hyprland]]