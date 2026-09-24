#!/bin/bash
# Script to set the Hyprlock avatar

# Destination path for the avatar
DEST_PATH="$HOME/.config/hypr/avatar.jpg"

# If an argument is provided (e.g., from Thunar), use it. Otherwise, open a GUI file picker (Zenity)
if [ -z "$1" ]; then
  IMAGE=$(zenity --file-selection --title="Select your profile picture" --file-filter="Images | *.png *.jpg *.jpeg")
else
  IMAGE="$1"
fi

# Exit if the user canceled the selection
if [ -z "$IMAGE" ]; then
  exit 0
fi

# Copy the image and overwrite the current avatar
cp "$IMAGE" "$DEST_PATH"

# Send a system notification
notify-send -u low -a "Hyprlock" -i "$DEST_PATH" "Avatar Updated" "Your new profile picture is set."
