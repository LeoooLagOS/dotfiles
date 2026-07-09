# ==============================================================================
# 🛰️  lagOS Layered Shell Configuration: High-Velocity Interfaces
# ==============================================================================

# --- 🌍 GLOBAL STRIPPED COMPRESSION PARSERS ---
alias -g G='| grep --color=always'
alias -g L='| less'
alias -g B='| bat'
alias -g NE='2>/dev/null'

# --- 🛰️  NAVIGATION & CLEANING HANDLERS ---
alias ls='lsd'
alias l='lsd -l'
alias la='lsd -a'
alias ll='lsd -lh'
alias lla='lsd -la'
alias lsa='lsd -lah'
alias lt='lsd --tree'
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# --- 🏗️  SENIOR GIT DESK ENGINE WORKFLOWS ---
alias st='git status -sb'
alias ad='git add'
alias aa='git add .'
alias cm='git commit -m'
alias psh='git push origin $(git branch --show-current)'
alias pll='git pull origin $(git branch --show-current)'
alias sync='git pull --rebase origin $(git branch --show-current)'
alias gl="git log --graph --topo-order --pretty=format:'%C(auto)%h%d %s %C(magenta)%C(bold)%ad %C(cyan)%an' --date=short"
alias gd='git diff'
alias gds='git diff --staged'
alias rs='git restore'
alias rss='git restore --staged'
alias unstage='git restore --staged .'
alias undo='git reset --soft HEAD~1'

# --- 💻 CORE PROGRAMMING PORTS ---
alias py='python3'
alias python='python3'
alias nv='nvim'
compdef nv=nvim 2>/dev/null   
alias sv='sudo nvim'
compdef sv=nvim 2>/dev/null
alias idea='(~/.local/bin/idea . &>/dev/null &!)'
alias studio='/opt/android-studio/bin/studio > /dev/null 2>&1 &!'

# --- 📚 THE KNOWLEDGE LIBRARIAN (Rerouted directly to Python Engines) ---
alias vt='python3 $HOME/dotfiles/scripts/ops/sync-vault --vtree'
alias vsync='python3 $HOME/dotfiles/scripts/ops/sync-vault --vtree'
alias gerlog='python3 $HOME/dotfiles/scripts/ops/sync-vault --gerlog'
alias dsalog='python3 $HOME/dotfiles/scripts/ops/sync-vault --dsalog'
alias cards='python3 $HOME/dotfiles/scripts/ops/sync-vault --cards'
alias dots='python3 $HOME/dotfiles/scripts/ops/sync-dots'
alias update='system_update_sync'

# --- 🚀 SANDBOX APPLICATIONS ---
alias spotify='python3 $HOME/dotfiles/scripts/ops/repair-spotify'
alias pt="QT_QPA_PLATFORM=xcb /opt/pt/packettracer.AppImage > /dev/null 2>&1 &!"
alias f="fvm flutter"
alias eeg="cd $HOME/Development/BCI-Robotic-Arm && source venv/bin/activate && python src/EEG_Studio/run.py > /dev/null 2>&1 &!"
