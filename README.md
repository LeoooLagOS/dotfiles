🍙 LeoooLagOS / Dotfiles

![Fedora](https://img.shields.io/badge/Fedora-Workstation-blue?style=for-the-badge&logo=fedora)
![Hyprland](https://img.shields.io/badge/Hyprland-Wayland-00a4a6?style=for-the-badge&logo=archlinux)
![Bash](https://img.shields.io/badge/Scripting-Bash-4EAA25?style=for-the-badge&logo=gnu-bash)

My personal configuration files for a high-performance **Fedora Hyprland** environment.

Focused on a clean, **Apple-inspired aesthetic** for the lock screen with robust backend automation for music and weather integration.

---

## ✨ Key Features

### 🔒 Custom Hyprlock (Apple Style)
A fully customized lock screen written in `hyprlang` featuring:
- **Frosted Glass UI:** Heavy blur and noise textures to mimic macOS.
- **Dynamic Music Player:**
  - Uses `playerctl` to detect Spotify/YouTube playback.
  - **Stacked Text:** Bold Title, lighter Artist, and transparent Album name.
  - **Album Art:** Automatically downloads, crops, and renders album art with a border (using `ImageMagick`).
- **Auto-Weather:** Fetches real-time temperature (Celsius) and conditions for **Amozoc** via `wttr.in`.
- **System Stats:** Minimalist battery, keyboard layout, and uptime indicators.

### 🤖 Automation Scripts
Custom Bash scripts located in `hypr/scripts/`:
* **`Music.sh`**: The brain behind the lock screen media player. Handles metadata extraction, art downloading, and conditional rendering.
* **`AutoLockscreen.sh`**: A daemon that watches for wallpaper changes (via `playerctl` or `swww`) and instantly updates the lock screen background to match the desktop.

---

## 📂 Repository Structure

```text
~/dotfiles/
├── hypr/
│   ├── hyprland.conf       # Main window manager config
│   ├── hyprlock.conf       # Lock screen layout & styling
│   ├── wallust/            # Color scheme generation
│   └── scripts/
│       ├── Music.sh        # Media logic
│       └── AutoLockscreen.sh # Wallpaper sync
└── README.md
```

## 🛠 Dependencies

These configurations rely on the following packages (Fedora):
```Bash

sudo dnf install hyprland hyprlock playerctl imagemagick inotify-tools curl
```

## 🚀 Usage

### To apply these configurations to a new system:   

Clone the repository:
```bash
git clone git@github.com:LeoooLagOS/dotfiles.git ~/dotfiles
```

Link the files (Manual):
```Bash
cp ~/dotfiles/hypr/hyprlock.conf ~/.config/hypr/
cp -r ~/dotfiles/hypr/scripts ~/.config/hypr/
```