#!/bin/bash

echo "Starting System Restore..."

# 1. Setup Flathub (for Spotify, etc.)
echo "Adding Flathub Repository..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# 2. Install Fedora Packages (System Tools)
echo "Installing System Packages from pkglist.txt..."
# 'xargs' is safer than 'cat' for long lists
sudo dnf install -y $(cat pkglist.txt)

# 3. Install Flatpaks (Chat & Music)
echo "Installing Flatpaks from flatpaks.txt..."
while read app; do
    # Skip empty lines or headers if any exist
    if [[ "$app" != "" && "$app" != "Application" ]]; then
        echo "   -> Installing $app"
        flatpak install -y flathub $app
    fi
done < flatpaks.txt

echo "✅ Installation Complete! Please reboot."