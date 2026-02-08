#!/bin/bash

# Define paths
DOTFILES_DIR="$HOME/dotfiles"
CONFIG_DIR="$HOME/.config"

echo "🚀 Starting Leo's System Restore..."

# --- PHASE 1: REPO CHECKS ---
if [ ! -d "$DOTFILES_DIR" ]; then
  echo "❌ Error: $DOTFILES_DIR not found. Please clone your repo first."
  exit 1
fi

# --- PHASE 2: SYSTEM REPOS & PKGS ---
echo "📦 Adding Flathub & Installing Packages..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# Use xargs for cleaner DNF install
grep -v '^#' pkglist.txt | xargs sudo dnf install -y

# --- PHASE 3: FLATPAKS ---
echo "🚚 Installing Flatpaks..."
while read -r app; do
  if [[ -n "$app" && "$app" != "Application" && ! "$app" =~ ^# ]]; then
    flatpak install -y flathub "$app"
  fi
done <flatpaks.txt

# --- PHASE 4: THE SYMLINK MAGIC ---
echo "🔗 Linking Configuration Files..."

# Link Zsh Configs
ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
# If you eventually add .p10k.zsh back, uncomment the line below:
# ln -sf "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"

# Link Hyprland Config
mkdir -p "$CONFIG_DIR/hypr"
ln -sf "$DOTFILES_DIR/hypr/"* "$CONFIG_DIR/hypr/"

# --- PHASE 5: POST-INSTALL HOOKS ---
echo "🐚 Changing default shell to Zsh..."
if [ "$SHELL" != "$(which zsh)" ]; then
  chsh -s "$(which zsh)"
fi

echo "✅ All set! Your cockpit is ready."
echo "👉 Run 'source ~/.zshrc' or restart your terminal to see changes."

