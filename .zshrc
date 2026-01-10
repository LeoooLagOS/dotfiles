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

# Add Spicetify to Path
export PATH="$PATH:$HOME/.spicetify"
# Add Spotify alias  
alias spotify='flatpak run com.spotify.Client'
export PATH=$PATH:/home/lag-os/.spicetify

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
    
    # We use a temporary file to store counts because pipes | create subshells
    while read -r line; do
        ((TOTAL_LINKS++))
        local link=$(echo "$line" | awk '{print $(NF-2)}')
        local target=$(echo "$line" | awk '{print $NF}')
        
        if [[ ! -e "$target" ]]; then
            echo "❌ Broken Link: $link -> $target"
            ((BROKEN_COUNT++))
        fi
    done < <(find "$HOME" -maxdepth 2 -type l -ls | grep "$DOTS_DIR")

    if [[ $BROKEN_COUNT -eq 0 ]]; then
        echo "✅ All $TOTAL_LINKS links are healthy."
    else
        echo "⚠️ Found $BROKEN_COUNT broken links out of $TOTAL_LINKS."
    fi
}

# Auto-Backup Function for German obsidian vault Logs 
save-deutsch-log() {
    # 1. Scope variables locally to avoid environment pollution
    local LOG_DIR="$HOME/Documents/My-CS-Notes/40_Natural_Languages/German/99_Daily_Output"
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

vault-tree() {
    local VAULT_DIR="$HOME/Documents/My-CS-Notes"
    local DOTS_DIR="$HOME/dotfiles"
    local CURRENT_DATE=$(date +'%Y-%m-%d')
    
    local TXT_DOTS="$DOTS_DIR/vault-architecture.txt"
    local TXT_VAULT="$VAULT_DIR/VAULT-STRUCTURE.txt"
    local MD_VAULT="$VAULT_DIR/VAULT-STRUCTURE.md"

    if [[ ! -d "$VAULT_DIR" ]]; then
        echo "Error: Vault not found at $VAULT_DIR" >&2
        return 1
    fi

    echo "Status: Generating Multi-Format Vault Maps... Mapping Vault Architecture..."

    # 1. Generate TXT files (Standardized flags)
    # We use -I to ignore the .git folder
    lsd --group-directories-first --tree -I ".git" --color=never "$VAULT_DIR" > "$TXT_DOTS"
    cp "$TXT_DOTS" "$TXT_VAULT"

    # 2. Generate the Markdown version
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

    echo "📦 Step 2: Syncing Knowledge Base (Obsidian)..."
    pushd "$VAULT_DIR" > /dev/null || return 1
    
    if [[ -n "$(git status --porcelain)" ]]; then
        git add .
        git commit -m "docs(meta): update vault structure and architecture maps $CURRENT_DATE"
        git push && echo "✅ Notes synchronized to GitHub."
    else
        echo "ℹ️  Notes already up to date."
    fi
    popd > /dev/null

    echo "⚙️  Step 3: Syncing System State (Dotfiles)..."
    # We call your existing save-dots function directly
    save-dots "build(sys): sync architecture map and system state $CURRENT_DATE"

    # 3. Print to terminal with color
    lsd --group-directories-first --tree -I ".git" --color=always "$VAULT_DIR"

    echo "------------------------------------------------"
    echo "✨ GLOBAL SYNC COMPLETE: Workstation is Secure."
    echo "------------------------------------------------"
    echo "✅ Structure synchronized across .txt and .md"
}