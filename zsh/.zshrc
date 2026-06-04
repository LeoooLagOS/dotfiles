# ==============================================================================
# 🚀 lagOS-station Master Shell Bootstrapper
# ==============================================================================

# Iteratively parse and source all layered core components sequentially
if [ -d "$HOME/dotfiles/zsh/conf.d" ]; then
  for config_file in "$HOME/dotfiles/zsh/conf.d/"*.zsh; do
    source "$config_file"
  done
fi

# Initialize Starship Layout Prompt (Must load last)
eval "$(starship init zsh)"

# Active Environmental Version Managers
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"
