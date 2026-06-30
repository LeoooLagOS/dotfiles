# ==============================================================================
# 🚀 lagOS Station Environmental Context Core
# ==============================================================================

# --- 🛡️ PATH HYGIENE ---
# Ensures PATH variables are unique, preventing duplication upon reloading (source).
typeset -U PATH path

# ------------------------------------------------------------------------------
# PATH CONSTRUCTION (From lowest to highest priority via stacking)
# ------------------------------------------------------------------------------

# 3. SYSTEM LAYER: Standard binaries
# Establish the system base.
export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:/usr/bin:$PATH"
export PATH="$PATH:$HOME/.spicetify"

# 2. FRAMEWORK LAYER: Runtimes and Language Toolchains
# Executed afterwards so they can override operating system versions.

# FVM / Flutter
export PATH="$HOME/fvm/bin:$PATH"

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

# SDKMAN (Java, Gradle, Kotlin Management)
# SDKMAN automatically prepends its paths upon execution, which is why we initialize it here.
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# 1. PRIORITY LAYER: High-velocity local scripts (WM, Ops, Libs)
# Executed LAST to ensure these scripts have absolute priority over SDKMAN, FVM, and the System.
export PATH="$HOME/dotfiles/scripts/wm:$HOME/dotfiles/scripts/ops:$HOME/dotfiles/scripts/lib:$PATH"

# ------------------------------------------------------------------------------
# STATIC ENVIRONMENT VARIABLES
# ------------------------------------------------------------------------------

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
