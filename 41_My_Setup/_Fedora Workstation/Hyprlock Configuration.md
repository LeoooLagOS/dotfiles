---
tags:
  - concept
  - setup
  - configuration
  - hyprland
category: setup
status: active
related: "[[_Fedora Workstation]]"
date: 2025-12-08
---
# Hyprlock Configuration

## 📝 One-Sentence Summary
A custom configuration for the Hyprlock screen locker, designed to mimic the Apple/macOS aesthetic with specific integrations for dynamic media controls and weather data.

## 💡 Analogy
This configuration acts as the **Doorman** of the system. It doesn't just check ID (passwords); it also holds a clipboard showing the current weather and plays the music currently running in the club (system), changing its uniform (wallpaper) to match the interior decor instantly.

## 🔑 Key Details
- **What it is:** A declarative configuration file (`hyprlock.conf`) combined with external Bash scripts to render a UI on the lock screen.
- **Why it exists:** To provide a secure yet visually informative lock screen that matches the "Glassmorphism" aesthetic of the desktop environment without manual intervention.

### Core Components

#### 1. The "Apple Style" Aesthetic
- **Font:** Uses `SF Pro Display` (San Francisco) or `Inter` for a clean, humanistic sans-serif look.
- **Visuals:** High blur (`blur_size = 5`) and noise (`noise = 0.01`) on the background create a "frosted glass" effect, improving text readability on any wallpaper.
- **Layout:** Centralized time/date, stacked media controls, and bottom-corner system status.

#### 2. Music Integration (`Music.sh`)
A custom script located at `~/.config/hypr/scripts/Music.sh` that handles media metadata.
- **Logic:**
    1.  Detects active players using `playerctl -p spotify,%any`.
    2.  **If Playing:** Downloads album art, uses `ImageMagick` to resize it to 200x200 and burn a white border into the image file.
    3.  **If Stopped:** Generates a transparent 200x200 pixel image to "hide" the art without causing Hyprlock render errors.
- **Stacking:** The UI separates Title (Bold), Artist (Regular), and Album (Light/Transparent) into vertical layers.

#### 3. Weather & Location
- Bypasses local caching to fetch data directly via `curl "wttr.in?m"`.
- Uses `?m` flag to force **Metric (Celsius)** units regardless of IP location.
- Auto-detects location (currently resolves to **Amozoc de Mota**).

#### 4. Wallpaper Sync (`AutoLockscreen.sh`)
- A daemon script that watches for changes in the desktop wallpaper.
- Copies the current desktop background to a static location (`~/Pictures/lockscreen.png`) that Hyprlock is hardcoded to read.
- Prevents the "Black Screen" bug by ensuring the file is always a valid PNG before Hyprlock loads.

## 🔗 Connections & Implementations
- **Parent System:** [[_Fedora Workstation]]
- **Tools Used:** [[ImageMagick]] (for art processing), [[Playerctl]] (for media status).

## 👍 Pros & 👎 Cons
- **Pros:** High visual appeal; completely automated (no manual wallpaper changing); "At a glance" information.
- **Cons:** Slight dependency chain (needs specific scripts to run); Album art download relies on internet connection for Spotify URLs.

## See Also
- [[Hyprland]]
- [[_Bash_Scripting]]