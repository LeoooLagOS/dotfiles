# 📸 lagOS-shot

A Python-powered Wayland screenshot utility designed for high-fidelity technical documentation and seamless integration with **Obsidian** research vaults.

## 🚀 Overview

**lagOS-shot** abstracts the complexity of regional screen capture and image annotation into a single, deterministic workflow. Developed to support the **NetAdmin** and **Cybersecurity** laboratory reports at **BUAP**, this utility ensures that every screenshot is properly annotated and linked with absolute system paths.

## ✨ Features

* **Regional Selection**: Precise area targeting using `slurp` and `grim`.
* **Live Annotations**: Instant technical markup (arrows, text, blurring) via `swappy`.
* **Dynamic Save Architecture**: Utilizes `zenity` to provide a GUI-driven save dialog, defaulting to `Pictures/Screenshots` while maintaining zero hardcoding for maximum portability.
* **Obsidain Ready**: Automatically injects a Markdown-compatible absolute path (`![](/path/to/image.png)`) into the **Wayland** clipboard upon saving.
* **EXDEV Robustness**: Engineered with `shutil` to handle cross-device file movements between RAM-based `/tmp` storage and physical disks.

## 🛠️ Prerequisites

Ensure your **Fedora** host is provisioned with the following dependencies:

```zsh
sudo dnf install grim slurp swappy zenity wl-clipboard xdg-user-dirs
```

## 📂 Installation
1. Clone/Move the script to your dotfiles directory: `~/dotfiles/scripts/lagos-shot/lagos-shot.py`

2. Make it executable:
    
    ```Bash
    chmod +x ~/dotfiles/scripts/lagos-shot/lagos-shot.py
    ```

3. Create a Symbolic Link:
    
    ```Bash
    ln -s ~/dotfiles/scripts/lagos-shot/lagos-shot.py ~/.local/bin/lagos-shot
    ```

## 📖 Usage

Invoke the utility from any terminal instance:

```Bash
lagos-shot
```

## 🚧 Known Issues & Roadmap

-    **GUI Blocking:** Currently, the zenity save dialog may require the user to manually exit or focus-switch from the swappy interface due to sequential process execution.

- **Hyprland Integration:** Keybind conflicts have been observed with JaKooLit's Super+Shift+S implementation; manual binding via hyprland.conf is recommended for future iterations.

- **Asynchronous Execution:** Future versions will explore multi-threading to prevent the UI from hanging between the editing and saving phases.