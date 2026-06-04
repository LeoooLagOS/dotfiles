# ==============================================================================
# 🎨 lagOS Aesthetic & Subsystem Initialization
# ==============================================================================

# Oh My Zsh Initialization Hooks
ZSH_THEME=""
plugins=(git dnf)
source $ZSH/oh-my-zsh.sh

# Fedora System Plugins (Sourced from /usr/share)
[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Load private/local un-tracked configurations if available
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# FZF Search Subsystem Bindings
source <(fzf --zsh)

# Visual Dashboard Engine Output (Fires on every interactive shell)
if [ -n "$PS1" ]; then
  pokemon-colorscripts --no-title -s -r | fastfetch -c $HOME/.config/fastfetch/config-pokemon.jsonc --logo-type file-raw --logo-height 10 --logo-width 5 --logo -
  
  # Trigger the sentinel audit check directly underneath the dashboard graphics
  sentinel
fi
