# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"

# We disable the OMZ theme because Starship handles it later
ZSH_THEME=""

# Only load standard OMZ plugins here
plugins=( 
    git
    dnf
    ssh-agent
)

source $ZSH/oh-my-zsh.sh

# -----------------------------------------------------------
# 🧠 Fedora System Plugins (Installed via DNF)
# -----------------------------------------------------------
# We source these manually because they live in /usr/share, not inside OMZ
[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# -----------------------------------------------------------
# 🔒 Private Configs
# -----------------------------------------------------------
# local/private configurations (Not tracked by Git)
# later create ~/.zshrc.local for anything secret 
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# -----------------------------------------------------------
# 🎨 Visuals (Pokemon & Fastfetch)
# -----------------------------------------------------------
# Display Pokemon-colorscripts piped into Fastfetch
pokemon-colorscripts --no-title -s -r | fastfetch -c $HOME/.config/fastfetch/config-pokemon.jsonc --logo-type file-raw --logo-height 10 --logo-width 5 --logo -


# -----------------------------------------------------------
# ⚡ Utilities & Keybinds
# -----------------------------------------------------------
# Set-up FZF key bindings (CTRL R for fuzzy history finder)
source <(fzf --zsh)

HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# Set-up icons for files/directories in terminal using lsd
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'
alias update='sudo dnf update'

# Android Studio Alias (Native Launcher)
alias studio='/opt/android-studio/bin/studio > /dev/null 2>&1 &!'

# Add Spicetify to Path
export PATH="$PATH:$HOME/.spicetify"
# Add Spotify alias  
alias spotify='flatpak run com.spotify.Client'
##export PATH=$PATH:/home/lag-os/.spicetify

# fix ssh permissions on startup
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod -R go-rwx ~/.keychain

# Start SSH Agent via Keychain
eval $(keychain --eval --quiet id_ed25519)

# -----------------------------------------------------------
# 🚀 Prompt & Languages
# -----------------------------------------------------------
# Start zsh with starship
eval "$(starship init zsh)"

# Bun setup
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "/home/lag-os/.bun/_bun" ] && source "/home/lag-os/.bun/_bun"

function sentinel() {
    # Environment-agnostic variables
    local DEV_USER="$USER"
    local VAULT_DIR="$HOME/Documents/my-cs-notes/"
    
    # ANSI Color Codes for Professional UI
    local B='\033[1;34m' # Info
    local G='\033[0;32m' # Success
    local R='\033[0;31m' # Fail
    local Y='\033[1;33m' # Action
    local NC='\033[0m'   # No Color

    echo -e "${B}===[ 🛡️  SENTINEL SYSTEM CHECK | User: ${DEV_USER} ]===${NC}"

    # 1. IDEMPOTENT SECURITY POLICY
    # Fixes lax permissions common in dual-boot setups automatically.
    printf "🔐 Security: "
    if [[ -d ~/.ssh ]]; then
        chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_ed25519* 2>/dev/null
        chmod -R go-rwx ~/.keychain 2>/dev/null
        echo -e "${G}POLICY_ENFORCED${NC}"
    else
        echo -e "${R}SSH_DIR_NOT_FOUND${NC}"
    fi

    # 2. VIRTUALIZATION ENGINE (KVM/QEMU)
    # Required for GNS3 and Network Administration labs.
    printf "🌐 Virtual:  "
    if systemctl is-active --quiet libvirtd; then
        echo -e "${G}KVM_ACTIVE${NC}"
    else
        echo -e "${Y}STARTING_LIBVIRTD...${NC}"
        sudo systemctl start libvirtd && echo -e "   ↳ ${G}Daemon spawned successfully.${NC}"
    fi

    # 3. RUNTIME INVENTORY
    # Dynamic versioning for Bun and Go.
    printf "⚡ Runtimes: "
    command -v bun &>/dev/null && echo -ne "${G}Bun($(bun --version))${NC} | " || echo -ne "${R}NO_BUN${NC} | "
    command -v go &>/dev/null && echo -e "${G}Go(Ready)${NC}" || echo -e "${R}NO_GO${NC}"

    # 4. GIT IDENTITY VALIDATION
    # Uses dynamic lookup to ensure the current shell matches your global config.
    printf "🐙 Git Auth: "
    local CURRENT_GIT_USER=$(git config --global user.name)
    if [[ -n "$CURRENT_GIT_USER" ]]; then
        echo -e "${G}${CURRENT_GIT_USER}${NC}"
    else
        echo -e "${R}IDENTITY_NOT_SET${NC}"
    fi

    # 5. REPOSITORY INTEGRITY
    # Checks the status of your "Second Brain" Obsidian Vault.
    if [[ -d "$VAULT_DIR/.git" ]]; then
        printf "📚 Vault:    "
        if [[ -z $(git -C "$VAULT_DIR" status --porcelain) ]]; then
            echo -e "${G}CLEAN${NC}"
        else
            echo -e "${Y}DIRTY_PENDING_SYNC${NC}"
        fi
    fi

    echo -e "${B}=================================================${NC}"
}

# Execute sentinel on shell initialization
sentinel

# Auto-Backup Function
save-dots() {
    # 1. Environment & Path Setup
    local DOTS_DIR="$HOME/dotfiles"
    local PKG_LIST="$DOTS_DIR/pkglist.txt"
    local FLAT_LIST="$DOTS_DIR/flatpaks.txt"
    local CURRENT_DATE=$(date +'%Y-%m-%d')
    local DEFAULT_MSG="build(sys): snapshot system packages & configs for $CURRENT_DATE"

    # 2. Guard Clause: Directory verification
    if [[ ! -d "$DOTS_DIR" ]]; then
        echo "Error: Dotfiles directory not found at $DOTS_DIR" >&2
        return 1
    fi

    echo "Status: Snapshotting System Packages..."

    # 3. Defensive Package Exporting
    # We use temporary files to ensure we don't overwrite the old list if the command fails
    if ! sudo dnf repoquery --userinstalled --queryformat '%{name}\n' > "$PKG_LIST.tmp"; then
        echo "Error: Failed to query DNF packages." >&2
    else
        mv "$PKG_LIST.tmp" "$PKG_LIST"
    fi

    if ! flatpak list --app --columns=application > "$FLAT_LIST.tmp"; then
        echo "Error: Failed to query Flatpak list." >&2
    else
        mv "$FLAT_LIST.tmp" "$FLAT_LIST"
    fi

    # 4. Git Transaction
    pushd "$DOTS_DIR" > /dev/null || return 1

    # Check for actual changes (don't push if nothing changed)
    if [[ -z "$(git status --porcelain .)" ]]; then
        echo "System: Environment state is already up to date. Skipping push."
        popd > /dev/null
        return 0
    fi

    git add .
    local COMMIT_MSG="${1:-$DEFAULT_MSG}"

    if git commit -m "$COMMIT_MSG"; then
        echo "Status: Pushing environment state to GitHub..."
        git push
        echo "Success: System state synchronized!"
    else
        echo "Error: Git commit failed." >&2
    fi

    popd > /dev/null
}

restore-dots() {
    local DOTS_DIR="$HOME/dotfiles"
    local PKG_LIST="$DOTS_DIR/pkglist.txt"
    local FLAT_LIST="$DOTS_DIR/flatpaks.txt"

    # 1. Guard Clause
    if [[ ! -f "$PKG_LIST" ]]; then
        echo "Error: Package list not found at $PKG_LIST" >&2
        return 1
    fi

    # 2. Detect Package Manager
    local PKG_MANAGER=""
    if command -v dnf &> /dev/null; then PKG_MANAGER="dnf"
    elif command -v pacman &> /dev/null; then PKG_MANAGER="pacman"
    elif command -v apt &> /dev/null; then PKG_MANAGER="apt"
    fi

    echo "System: Detected $PKG_MANAGER as the primary package manager."

    # 3. Restore Core Packages
    echo "Status: Restoring system packages..."
    case $PKG_MANAGER in
        dnf)
            sudo dnf install -y $(cat "$PKG_LIST")
            ;;
        pacman)
            # Arch needs --needed to skip already installed packages
            sudo pacman -S --needed --noconfirm - < "$PKG_LIST"
            ;;
        apt)
            sudo apt update
            xargs -a "$PKG_LIST" sudo apt install -y
            ;;
        *)
            echo "Warning: Unsupported package manager. Please install manually."
            ;;
    esac

    # 4. Restore Flatpaks (Distro-Agnostic)
    if command -v flatpak &> /dev/null && [[ -f "$FLAT_LIST" ]]; then
        echo "Status: Restoring Flatpaks..."
        xargs -a "$FLAT_LIST" flatpak install -y
    fi

    echo "Success: Restore process complete!"
}

check-links() {
    local DOTS_DIR="$HOME/dotfiles"
    local BROKEN_COUNT=0
    local TOTAL_LINKS=0
    
    echo "Status: Verifying Symlink Integrity..."
    
    # We use 'readlink' which is much more reliable than parsing 'ls'
    while read -r link; do
        ((TOTAL_LINKS++))
        local target=$(readlink -f "$link")
        
        if [[ ! -e "$target" ]]; then
            echo "❌ Broken Link: $link -> $target"
            ((BROKEN_COUNT++))
        fi
    done < <(find "$HOME" -maxdepth 2 -type l -exec ls -d {} + | grep "$DOTS_DIR")

    if [[ $BROKEN_COUNT -eq 0 && $TOTAL_LINKS -gt 0 ]]; then
        echo "✅ All $TOTAL_LINKS links are healthy."
    elif [[ $TOTAL_LINKS -eq 0 ]]; then
        echo "❓ No dotfile links found in $HOME."
    else
        echo "⚠️ Found $BROKEN_COUNT broken links out of $TOTAL_LINKS."
    fi
}

# Auto-Backup Function for German obsidian vault Logs 
save-deutsch-log() {
    # 1. Scope variables locally to avoid environment pollution
    local LOG_DIR="$HOME/Documents/my-cs-notes/40_Natural_Languages/German/99_Daily_Output"
    local CURRENT_DATE=$(date +'%Y-%m-%d')
    local DEFAULT_MSG="docs(de): update system German-log for $CURRENT_DATE"

    # 2. Guard Clause: Verify directory existence before navigation
    if [[ ! -d "$LOG_DIR" ]]; then
        echo "Error: Target directory does not exist at $LOG_DIR" >&2
        return 1
    fi

    # 3. Use pushd for cleaner directory stack management
    pushd "$LOG_DIR" > /dev/null || return 1

    # 4. The "Porcelain" Check: Only proceed if there are actual changes
    # This prevents creating empty 'garbage' commits
    if [[ -z "$(git status --porcelain .)" ]]; then
        echo "System: No changes detected in the German log. Skipping commit."
        popd > /dev/null
        return 0
    fi

    echo "Status: Staging changes for $CURRENT_DATE..."
    git add .

    # 5. Bash Parameter Expansion: Use $1 if provided, otherwise use DEFAULT_MSG
    local COMMIT_MSG="${1:-$DEFAULT_MSG}"

    # 6. Atomic Operation: Only push if the commit is successful
    if git commit -m "$COMMIT_MSG"; then
        echo "Status: Syncing with remote origin..."
        git push
        echo "Success: German log saved professionally."
    else
        echo "Error: Git commit failed." >&2
        popd > /dev/null
        return 1
    fi

    popd > /dev/null
}

# Auto-Backup Function for DSA Daily Logs 
save-dsa-log() {
    # 1. Scope variables locally
    # Note: Quotes are critical here because "03 Practice Log" contains spaces
    local LOG_DIR="$HOME/Documents/my-cs-notes/05_Algorithms_and_Data_Structures/03 Practice Log/99_Daily_Output"
    local CURRENT_DATE=$(date +'%Y-%m-%d')
    local DEFAULT_MSG="docs(dsa): update DSA daily log for $CURRENT_DATE"

    # 2. Guard Clause: Verify directory existence
    if [[ ! -d "$LOG_DIR" ]]; then
        echo "Error: Target directory does not exist at $LOG_DIR" >&2
        return 1
    fi

    # 3. Use pushd for cleaner directory stack management
    pushd "$LOG_DIR" > /dev/null || return 1

    # 4. The "Porcelain" Check: Prevent empty commits
    if [[ -z "$(git status --porcelain .)" ]]; then
        echo "System: No changes detected in the DSA log. Skipping commit."
        popd > /dev/null
        return 0
    fi

    echo "Status: Staging DSA logs for $CURRENT_DATE..."
    git add .

    # 5. Commit with default or custom message ($1)
    local COMMIT_MSG="${1:-$DEFAULT_MSG}"

    # 6. Atomic Operation
    if git commit -m "$COMMIT_MSG"; then
        echo "Status: Syncing with remote origin..."
        git push
        echo "Success: DSA log saved professionally. Keep grinding!"
    else
        echo "Error: Git commit failed." >&2
        popd > /dev/null
        return 1
    fi

    popd > /dev/null
}

vault-tree() {
    local VAULT_DIR="$HOME/Documents/my-cs-notes/"
    local DOTS_DIR="$HOME/dotfiles"
    local CURRENT_DATE=$(date +'%Y-%m-%d')
    
    # 🎯 TARGETS: These are the ONLY files we will touch in git
    local FILE_TXT="VAULT-STRUCTURE.txt"
    local FILE_MD="VAULT-STRUCTURE.md"
    
    local TXT_DOTS="$DOTS_DIR/vault-architecture.txt"
    local TXT_VAULT="$VAULT_DIR/$FILE_TXT"
    local MD_VAULT="$VAULT_DIR/$FILE_MD"

    if [[ ! -d "$VAULT_DIR" ]]; then
        echo "Error: Vault not found at $VAULT_DIR" >&2
        return 1
    fi

    echo "Status: Generating Multi-Format Vault Maps..."

    # 1. Generate TXT
    lsd --group-directories-first --tree -I ".git" --color=never "$VAULT_DIR" > "$TXT_DOTS"
    cp "$TXT_DOTS" "$TXT_VAULT"

    # 2. Generate Markdown
    {
        echo "---"
        echo "tags: #system/meta"
        echo "last_updated: $(date +'%Y-%m-%d %H:%M')"
        echo "---"
        echo "# 🌳 Vault Structure Map"
        echo ""
        echo '```text'
        cat "$TXT_DOTS"
        echo '```'
    } > "$MD_VAULT"

    echo "📦 Step 2: Atomic Sync (Structure Files Only)..."
    pushd "$VAULT_DIR" > /dev/null || return 1
    
    # --- 🛡️ CRITICAL: THE CLEAN SLATE ---
    # We must unstage any "ghosts" from previous manual 'git add' commands.
    # This ensures the staging area is EMPTY before we pick our files.
    git reset > /dev/null 2>&1
    
    # Now we add ONLY the two generated files explicitly. 
    git add "$FILE_TXT" "$FILE_MD"

    # We check if those specific files actually changed before committing
    if ! git diff --cached --quiet; then
        git commit -m "docs(meta): update vault structure maps $CURRENT_DATE"
        git push && echo "✅ Atomic update complete."
    else
        echo "ℹ️  Structure maps unchanged. Skipping commit."
    fi
    # -----------------------
    
    popd > /dev/null

    echo "⚙️  Step 3: Syncing Dotfiles..."
    save-dots "build(sys): sync architecture map and system state $CURRENT_DATE"

    # 3. Print result
    lsd --group-directories-first --tree -I ".git" --color=always "$VAULT_DIR"
    echo "✨ GLOBAL SYNC COMPLETE."
}

# --- 🚑 Spotifix: The Self-Healing Spotify Launcher ---
spotifix() {
    echo "🛑 Terminating Spotify instances..."
    pkill -9 spotify
    pkill -9 -f "com.spotify.Client"

    echo "🩹 Attempting graceful theme patch..."
    # Try the standard fix first. If it returns 0 (success), skip the heavy stuff.
    if spicetify restore backup apply; then
        echo "✅ Patch Successful!"
    else
        echo "⚠️ Standard patch failed. Escalating to Root Fix..."
        
        # Fix the notorious Flatpak permission drift
        echo "🔑 Fixing Write Permissions..."
        sudo chmod a+wr -R /var/lib/flatpak/app/com.spotify.Client/x86_64/stable/active/files/extra/share/spotify
        
        echo "🧹 Resetting Corrupted Backup State..."
        spicetify restore backup
        
        echo "🎨 Re-injecting Theme..."
        spicetify apply
    fi

    echo "🚀 Launching Spotify..."
    # Run in background & disown so closing terminal doesn't kill music
    flatpak run com.spotify.Client > /dev/null 2>&1 & disown
    
    echo "✨ Done. Enjoy the music, $USER."
}

function fix_spotify(){
  #1. configurations (IaC)
  local APP_ID="com.spotify.Client"
  local DATA_PATH="$HOME/.var/app/$APP_ID"
  local RED='\033[0;31m'
  local GREEN='\033[0;32m'
  local BLUE='\033[0;34m'
  local NC='\033[0m'

  echo -e "${BLUE}[INFO] Starting Spotify Recovery Protocol...${NC}"

  #2. Process management
  if pgrep -f "spotify" > /dev/null; then
    echo -e "${BLUE}[INFO] Process found. Terminating active instances...${NC}"
    pkill -f "spotify"
    sleep 1 #wait for sigterm
  else
    echo -e "${BLUE}[INFO] No active Spotify processes found.${NC}"
  fi

  #3 Idempotent uninstall
  if flatpak list | grep -q "$APP_ID"; then
    echo -e "${BLUE}[INFO] uninstalling package: $APP_ID...${NC}"
    flatpak uninstall "$APP_ID" -y > /dev/null
  else
    echo -e "${BLUE}[INFO] Package not installed. Skipping uninstall.${NC}"
  fi

  #4 Deep Cleaning
  if [[ -d "$DATA_PATH" && -n "$DATA_PATH" ]]; then
    echo -e "${BLUE}[INFO] Plugin Corrupted cache at: $DATA_PATH${NC}"
    rm -rf "$DATA_PATH"
  else
    echo -e "${BLUE}[INFO]No residual data found${NC}"
  fi

  #5 Reinstall & verification
  echo -e "${BLUE}[INFO]Fetching fresh binaries from Flathub... ${NC}"
  if flatpak install flathub "$APP_ID" -y > /dev/null; then
    echo -e "${GREEN}[Success] Spotify restored successfully${NC}"
  else
    echo -e "${RED}[ERROR] Installation failed. Check your network or flatpak repo.${NC}"
    return 1
  fi
}

# --- 🧹 System Janitor ---
sys-clean() {
    echo "🧹 Cleaning DNF (Fedora Package Manager)..."
    sudo dnf autoremove -y
    sudo dnf clean all

    echo "📦 Cleaning Unused Flatpak Runtimes..."
    # Removes huge runtimes (like old Nvidia drivers) that nothing uses anymore
    flatpak uninstall --unused -y

    echo "📔 Vacuuming System Logs (older than 2 weeks)..."
    # Keeps logs for debugging, but deletes ancient history
    sudo journalctl --vacuum-time=2weeks

    echo "🗑️ Clearing user cache..."
    rm -rf ~/.cache/thumbnails/*
    
    echo "✨ System Cleaned. Free space reclaimed."
}

# -----------------------------------------------------------
# 🏷️ Custom Command Aliases
# -----------------------------------------------------------
##---Git Shortcuts---
alias st='git status'
alias ad='git add .'
alias cm='git commit -m'
alias psh='git push origin main'
alias pll='git pull origin main'

##---Custom Functions--
alias vt='vault-tree'
alias vsync='vault-tree'
alias gerlog='save-deutsch-log'
alias dsalog='save-dsa-log'
alias dots='save-dots'
alias check='check-links'

alias mklab='f(){ mkdir -p "Lab_$1" && touch "Lab_$1/Notes.md"; unset -f f; }; f'
