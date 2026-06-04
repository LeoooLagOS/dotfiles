# ==============================================================================
# 🛡️ LEVEL 4: SECURITY & IDENTITY (lagOS-station Core)
# ==============================================================================

# Fix file permissions on interactive shell startup
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519 2>/dev/null
chmod -R go-rwx ~/.keychain 2>/dev/null

# Initialize SSH Agent via Keychain using static host assignment
if command -v keychain &>/dev/null; then
    eval $(keychain --eval --quiet --host lagOS-station id_ed25519)
fi

# GPG Identity Helper: Refreshes agent TTY for automated signed commits
# Mandatory for Wayland/Hyprland environment stability
function gpg-refresh() {
  gpgconf --launch gpg-agent
  gpg-connect-agent \
    "setenviron DISPLAY=$DISPLAY" \
    "setenviron WAYLAND_DISPLAY=$WAYLAND_DISPLAY" \
    "updatestartuptty" /bye > /dev/null 2>&1
}
