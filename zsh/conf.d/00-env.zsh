# ==============================================================================
# 🚀 lagOS Station Environmental Context Core
# ==============================================================================

# Centralized Executable Path Bin Layer Definitions
export PATH="$HOME/dotfiles/scripts/wm:$HOME/dotfiles/scripts/ops:$HOME/dotfiles/scripts/lib:$PATH"
export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH"
export PATH="$PATH:$HOME/.spicetify"

# Runtime Development Framework Mappings
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "/home/lag-os/.bun/_bun" ] && source "/home/lag-os/.bun/_bun"
[ -d "$HOME/.dotnet/tools" ] && export PATH="$PATH:$HOME/.dotnet/tools"

# --- 📚 THE MAESTRO LIBRARY CORE ANCHOR ---
export VAULT_DIR="$HOME/Documents/my-cs-notes"

# Oh My Zsh Engine Internals & Cache Controls
export ZSH="$HOME/.oh-my-zsh"
export ZSH_COMPDUMP="$XDG_CACHE_HOME/zsh/zcompdump"
export GPG_TTY=$(tty)

# --- 📜 HISTORY MANAGEMENT ---
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt appendhistory
