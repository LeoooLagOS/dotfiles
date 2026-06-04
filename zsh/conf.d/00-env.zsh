# ==============================================================================
# 🚀 lagOS Station Environmental Context Core
# ==============================================================================

# 1. PRIORITY LAYER: High-velocity local scripts (WM, Ops, Libs)
export PATH="$HOME/dotfiles/scripts/wm:$HOME/dotfiles/scripts/ops:$HOME/dotfiles/scripts/lib:$PATH"

# 2. SYSTEM LAYER: Standard binaries
export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:/usr/bin:$PATH"
export PATH="$PATH:$HOME/.spicetify"

# 3. FRAMEWORK LAYER: Runtimes and Language Toolchains
# These are placed last to prevent unexpected shadowing of system binaries.
# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$PATH:$BUN_INSTALL/bin"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# .NET
[ -d "$HOME/.dotnet/tools" ] && export PATH="$PATH:$HOME/.dotnet/tools"

# Go
export GOPATH="$HOME/go"
export GOBIN="$GOPATH/bin"
export PATH="$PATH:/usr/local/go/bin:$GOBIN"

# --- 📚 THE MAESTRO LIBRARY CORE ANCHOR ---
export VAULT_DIR="$HOME/Documents/my-cs-notes"

# --- ⚙️ ENGINE INTERNALS & SECURITY ---
export ZSH="$HOME/.oh-my-zsh"
export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump"
export GPG_TTY=$(tty)

# --- 📜 HISTORY MANAGEMENT ---
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
