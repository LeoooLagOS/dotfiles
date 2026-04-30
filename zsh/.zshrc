# ===========================================================
# 🏗️ LEVEL 1: ENVIRONMENT & PATHS
# ===========================================================
# Build PATH incrementally for clarity
export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH"
export PATH="$PATH:$HOME/.spicetify"

# Bun Setup
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "/home/lag-os/.bun/_bun" ] && source "/home/lag-os/.bun/_bun"

# .NET Setup (Optional but recommended for your path)
[ -d "$HOME/.dotnet/tools" ] && export PATH="$PATH:$HOME/.dotnet/tools"

# XDG & Zsh Internals
export ZSH="$HOME/.oh-my-zsh"
export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump"

# ===========================================================
# 🧩 LEVEL 2: FRAMEWORK & PLUGINS
# ===========================================================
# Disable OMZ theme (Starship handles the prompt)
ZSH_THEME=""

# OMZ Core Plugins
plugins=(git dnf)

# Initialize Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Fedora System Plugins (DNF-installed)
# Sourced manually as they live in /usr/share
[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ===========================================================
# ⚙️ LEVEL 3: UTILITIES & PRIVATE CONFIGS
# ===========================================================
# Load local/private configurations (Not tracked by Git)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# FZF initialization (CTRL-R history finder)
source <(fzf --zsh)

# History Management
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory

# ===========================================================
# 🛡️ LEVEL 4: SECURITY & IDENTITY (lagOS-station Core)
# ===========================================================
# Fix permissions on startup
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod -R go-rwx ~/.keychain

# Initialize SSH Agent via Keychain
# Uses static hostname to prevent directory bloat
eval $(keychain --eval --quiet --host lagOS-station id_ed25519)

# GPG Environment Setup
export GPG_TTY=$(tty)

# GPG Identity Helper: Refreshes agent TTY for automated commits
# Mandatory for Wayland/Hyprland stability
function gpg-refresh() {
  gpgconf --launch gpg-agent
  gpg-connect-agent \
    "setenviron DISPLAY=$DISPLAY" \
    "setenviron WAYLAND_DISPLAY=$WAYLAND_DISPLAY" \
    "updatestartuptty" /bye > /dev/null 2>&1
}

# ===========================================================
# 🎨 LEVEL 5: VISUALS & PROMPT
# ===========================================================
# Pokémon Colorscripts + Fastfetch (DankMaterial Aesthetic)
if [[ -o interactive ]]; then
  pokemon-colorscripts --no-title -s -r | fastfetch -c $HOME/.config/fastfetch/config-pokemon.jsonc --logo-type file-raw --logo-height 10 --logo-width 5 --logo -
fi

# Initialize Starship (Must be last for full shell control)
eval "$(starship init zsh)"

function sentinel() {
    local DEV_USER="$USER"
    
    # ANSI Color Codes
    local B='\033[1;34m' # Info
    local G='\033[0;32m' # Success
    local R='\033[0;31m' # Fail
    local Y='\033[1;33m' # Action
    local NC='\033[0m'   # No Color

    echo -e "${B}===[ 🛡️  SENTINEL SYSTEM CHECK | User: ${DEV_USER} ]===${NC}"

    # 1. SECURITY POLICY
    printf "🔐 Security: "
    if [[ -d ~/.ssh/credentials ]]; then
        # These are local path operations and do not require sudo
        chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_ed25519* 2>/dev/null
        echo -e "${G}POLICY_ENFORCED${NC}"
    else
        echo -e "${R}DIR_MISSING${NC}"
    fi
    
    # 2. VIRTUALIZATION (The logic gate)
    printf "🌐 Virtual:  "
    if systemctl is-active --quiet libvirtd; then
        # Status check is unprivileged; no password requested here
        echo -e "${G}KVM_ACTIVE${NC}"
    else
        # Only now is sudo invoked, and only once per boot/daemon crash
        echo -e "${Y}STARTING_LIBVIRTD...${NC}"
        sudo systemctl start libvirtd && echo -e "    ↳ ${G}Daemon spawned successfully.${NC}"
    fi

    # 3. RUNTIME INVENTORY (Bullet Points)
    printf "🐍 Python:   "
    command -v python3 &>/dev/null && echo -e "${G}$(python3 --version | awk '{print $2}')${NC}" || echo -e "${R}NOT_FOUND${NC}"

    printf "☕ Java:     "
    command -v java &>/dev/null && echo -e "${G}$(java -version 2>&1 | awk -F '\"' '/version/ {print $2}')${NC}" || echo -e "${R}NOT_FOUND${NC}"
    
    printf "🔷 .NET:     "
    command -v dotnet &>/dev/null && echo -e "${G}$(dotnet --version)${NC}" || echo -e "${R}NOT_FOUND${NC}"

    # 4. FAST RUNTIMES (Inline)
    printf "⚡ Runtimes: "
    command -v bun &>/dev/null && echo -ne "${G}Bun($(bun --version))${NC} | " || echo -ne "${R}NO_BUN${NC} | "
    command -v go &>/dev/null && echo -e "${G}Go($(go version | awk '{print $3}' | sed 's/go//'))${NC}" || echo -e "${R}NO_GO${NC}"

    # 5. GIT IDENTITY
    printf "🐙 Git Auth: "
    echo -e "${G}$(git config --global user.name)${NC}"

    echo -e "${B}=================================================${NC}"
}

# Execute sentinel on shell initialization
sentinel

# --- 🛠️ Senior DevOps System Synchronization Engine ---
function system_update_sync() {
    local B='\033[1;34m' G='\033[0;32m' R='\033[0;31m' Y='\033[1;33m' NC='\033[0m'
    local LOG_PREFIX="[SYSTEM-SYNC]"
    local START_TIME=$(date +%s)
    
    # Internal Logging Helpers
    log_info()    { echo -e "${B}${LOG_PREFIX}${NC} $1"; }
    log_success() { echo -e "${G}${LOG_PREFIX} SUCCESS:${NC} $1"; }
    log_warn()    { echo -e "${Y}${LOG_PREFIX} WARNING:${NC} $1"; }
    log_error()   { echo -e "${R}${LOG_PREFIX} ERROR:${NC} $1"; }

    echo -e "${B}🔍 Analyzing System State & Calculating Transaction...${NC}"

    # 1. PRE-FLIGHT: Refresh administrative credentials for the analysis
    sudo -v || return 1

    # 2. PLAN PHASE: Capture metadata via Dry-Runs
    log_info "Calculating DNF infrastructure changes..."
    local DNF_SUMMARY=$(sudo dnf upgrade --refresh --assumeno 2>/dev/null | grep -E "Transaction Summary|Install|Upgrade|Remove|Total download size|Is this ok")
    
    log_info "Calculating Flatpak application changes..."
    local FP_SUMMARY=$(flatpak update --dry-run 2>/dev/null | grep -E "Total download|Install|Update")

    # 3. PRESENT THE DEPLOYMENT PLAN
    echo -e "\n${B}📋 DEPLOYMENT PLAN${NC}"
    echo -e "-------------------------------------------------"
    
    if [[ -n "$DNF_SUMMARY" && ! "$DNF_SUMMARY" =~ "Nothing to do" ]]; then
        echo -e "${Y}[DNF System Packages]${NC}"
        echo "$DNF_SUMMARY" | grep -v "Is this ok" | sed 's/^/  /'
    else
        echo -e "${G}  DNF: System is already up to date.${NC}"
    fi

    echo ""

    if [[ -n "$FP_SUMMARY" ]]; then
        echo -e "${Y}[Flatpak Applications]${NC}"
        echo "$FP_SUMMARY" | sed 's/^/  /'
    else
        echo -e "${G}  Flatpak: All applications are up to date.${NC}"
    fi
    echo -e "-------------------------------------------------"

    # 4. SHORT-CIRCUIT: Skip transaction if the system is current
    if [[ "$DNF_SUMMARY" =~ "Nothing to do" && -z "$FP_SUMMARY" ]]; then
        log_success "System state is already optimized."
        echo -ne "${Y}❓ Run maintenance cleanup anyway? [y/N]: ${NC}"
        read -r response
        if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
            [[ -n "$(whence sys-clean)" ]] && sys-clean || log_error "sys-clean function not found."
        fi
        return 0
    fi

    # 5. THE GATEKEEPER
    echo -ne "${Y}❓ Proceed with the deployment? [y/N]: ${NC}"
    read -r response
    if [[ ! "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        log_warn "Deployment aborted by user."
        return 0
    fi

    # 6. EXECUTION PHASE
    echo -e "\n${B}🚀 Executing Transaction...${NC}"
    
    # Fire-and-forget background sudo keep-alive (Disowned to hide PID)
    while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &!

    # Execute system package upgrades
    sudo dnf upgrade -y
    
    # Execute application-layer updates
    flatpak update -y

    # Post-deployment cleanup logic
    if whence sys-clean >/dev/null; then
        log_info "Initializing post-deployment cleanup..."
        sys-clean
    fi

    local END_TIME=$(date +%s)
    echo -e "\n${G}✨ SYSTEM SYNCHRONIZED SUCCESSFULLY ($((END_TIME - START_TIME))s)${NC}"
}

# Auto-Backup Function
save-dots() {
    # 1. Environment & Path Setup
    local DOTS_DIR="$HOME/dotfiles"
    local PKG_LIST="$DOTS_DIR/System/pkglist.txt"
    local FLAT_LIST="$DOTS_DIR/System/flatpaks.txt"
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

# Surgical Sync for German Vocabulary only
save-cards() {
    local VAULT_DIR="$HOME/Documents/my-cs-notes"
    local VOCAB_PATH="40_Natural_Languages/German/01_Vocabulary_DB"
    local CURRENT_DATE=$(date +'%Y-%m-%d')
    local DEFAULT_MSG="docs(vocab): flashcard sync $CURRENT_DATE"

    if [[ ! -d "$VAULT_DIR" ]]; then
        echo "❌ Vault not found at $VAULT_DIR" >&2
        return 1
    fi

    pushd "$VAULT_DIR" > /dev/null || return 1

    # 1. Unstage everything first to prevent "accidental" commits
    git reset > /dev/null 2>&1

    # 2. Stage ONLY the vocabulary subfolder
    git add "$VOCAB_PATH"

    # 3. Check if that specific folder has changes
    if [[ -z "$(git status --porcelain "$VOCAB_PATH")" ]]; then
        echo "System: No changes in Vocabulary DB. Skipping."
        popd > /dev/null
        return 0
    fi

    # 4. Commit and Push
    local COMMIT_MSG="${1:-$DEFAULT_MSG}"
    if git commit -m "$COMMIT_MSG"; then
        echo "🚀 Syncing Vocabulary DB..."
        git push
        echo "✅ German flashcards synchronized."
    else
        echo "❌ Git commit failed." >&2
    fi

    popd > /dev/null
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

# Auto-Backup Function for DSA Daily Logs & Blank Screen Tests
save-dsa-log() {
    # 1. Scope variables locally
    # Target the parent Output folder to capture both 01_Practice_Logs and 02_Blank_Screen_Tests
    local LOG_DIR="$HOME/Documents/my-cs-notes/05_Algorithms_and_Data_Structures/03_Practice_Log/99_Daily_Output"
    local CURRENT_DATE=$(date +'%Y-%m-%d')
    local DEFAULT_MSG="docs(dsa): update DSA daily logs and tests for $CURRENT_DATE"

    # 2. Guard Clause: Verify directory existence
    if [[ ! -d "$LOG_DIR" ]]; then
        echo "Error: Target directory does not exist at $LOG_DIR" >&2
        return 1
    fi

    # 3. Use pushd for cleaner directory stack management
    pushd "$LOG_DIR" > /dev/null || return 1

    # 4. The "Porcelain" Check: Prevent empty commits
    if [[ -z "$(git status --porcelain .)" ]]; then
        echo "System: No changes detected in the DSA logs or tests. Skipping."
        popd > /dev/null
        return 0
    fi

    echo "Status: Staging DSA activity for $CURRENT_DATE..."
    git add .

    # 5. Commit with default or custom message ($1)
    local COMMIT_MSG="${1:-$DEFAULT_MSG}"

    # 6. Atomic Operation
    if git commit -m "$COMMIT_MSG"; then
        echo "Status: Syncing with remote origin..."
        git push
        echo "Success: DSA journals and tests synchronized. Keep grinding!"
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
    
   #local TXT_DOTS="$DOTS_DIR/vault-architecture.txt"
    local TXT_VAULT="$VAULT_DIR/$FILE_TXT"
    local MD_VAULT="$VAULT_DIR/$FILE_MD"

    if [[ ! -d "$VAULT_DIR" ]]; then
        echo "Error: Vault not found at $VAULT_DIR" >&2
        return 1
    fi

    echo "Status: Generating Multi-Format Vault Maps..."

    # 1. Generate TXT
    lsd --group-directories-first --tree -I ".git" --color=never "$VAULT_DIR" > "$TXT_VAULT"

    # 2. Generate Markdown
    {
        echo "---"
        echo "tags: #system/meta"
        echo "last_updated: $(date +'%Y-%m-%d %H:%M')"
        echo "---"
        echo "# 🌳 Vault Structure Map"
        echo -e "\n\`\`\`text"
        cat "$TXT_VAULT"
        echo "\`\`\`"
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

# --- 🧹 System Janitor (v2.1) ---
sys-clean() {
    local B='\033[1;34m' G='\033[0;32m' NC='\033[0m'
    
    echo -e "${B}🧹 Cleaning DNF (Fedora Package Manager)...${NC}"
    sudo dnf autoremove -y && sudo dnf clean all

    echo -e "${B}📦 Cleaning Unused Flatpak Runtimes...${NC}"
    flatpak uninstall --unused -y

    echo -e "${B}📔 Vacuuming System Logs (older than 2 weeks)...${NC}"
    sudo journalctl --vacuum-time=2weeks

    echo -e "${B}🗑️  Clearing user cache...${NC}"
    if [[ -d "$HOME/.cache/thumbnails" ]]; then
        find "$HOME/.cache/thumbnails" -mindepth 1 -delete 2>/dev/null
        echo -e "${G}✨ Thumbnail cache purged.${NC}"
    fi
    
    # Packet Tracer specific maintenance
    if [[ -d "$HOME/pt/logs" ]]; then
        echo -e "${B}🚀 Purging Packet Tracer debug logs...${NC}"
        find "$HOME/pt/logs" -type f -name "*.log" -delete 2>/dev/null
        echo -e "${G}✨ PT logs cleared.${NC}"
    fi

    echo -e "\n${G}✅ System Janitor: Sanitation Complete.${NC}"
}

# -----------------------------------------------------------
# 🏷️ Custom Command Aliases
# -----------------------------------------------------------

# --- 🌍 GLOBAL ALIASES (Works anywhere in the command) ---
alias -g G='| grep --color=always'      # Quick filtering
alias -g L='| less'                   # Quick paging
alias -g H='| head'                   # Show top results
alias -g T='| tail'                   # Show bottom results
alias -g NE='2>/dev/null'             # Silence errors (Nuke Errors)
alias -g CJ='| jq -C'                 # Colored JSON (if you work with APIs)
alias -g B='| bat'                    # High-performance pager/highlighting

# --- 🛰️ NAVIGATION (lsd setup) ---
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'
alias lah='ls -lAh'
alias dev='cd ~/Development'

# --- 🛡️ SYSTEM SAFETY ---
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias update='system_update_sync'

# --- 🏗️ SENIOR GIT WORKFLOW ---
alias st='git status -sb'
alias ad='git add'
alias aa='git add .'
alias cm='git commit -m'
alias psh='git push origin $(git branch --show-current)'
alias pll='git pull origin $(git branch --show-current)'
alias sync='git pull --rebase origin $(git branch --show-current)'
alias gl="git log --graph --topo-order --pretty=format:'%C(auto)%h%d %s %C(magenta)%C(bold)%ad %C(cyan)%an' --date=short"

# 🔍 Inspection (Powered by Delta via .gitconfig)
alias gd='git diff'
alias gds='git diff --staged'

# 🛠️ Restoration & Undo
alias rs='git restore'               # Restore files in working directory
alias rss='git restore --staged'     # Alternative for unstage
alias unstage='git restore --staged .'
alias undo='git reset --soft HEAD~1'

# --- 💻 PROGRAMMING ---
alias py='python3'
alias python='python3'
alias nv='nvim'
alias sv='sudo nvim'
alias idea='(~/.local/bin/idea . &>/dev/null &!)'
alias studio='/opt/android-studio/bin/studio > /dev/null 2>&1 &!'

# --- 📚 THE KNOWLEDGE LIBRARIAN ---
alias vt='vault-tree'
alias vsync='vault-tree'
alias gerlog='save-deutsch-log'
alias dsalog='save-dsa-log'
alias dots='save-dots'
alias cards='save-cards'
alias check='check-links'
alias update='system_update_sync'

# --- 🚀 APPS ---
alias spotify='flatpak run com.spotify.Client'

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
