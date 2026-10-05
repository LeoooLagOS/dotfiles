#!/usr/bin/env bash
# ==============================================================================
#  lagOS-station bootstrapper
#
#  Provisions a Fedora workstation from this repository: repositories, DNF
#  packages, Flatpaks, configuration symlinks, machine-local files and the
#  login shell. Every step is idempotent and safe to re-run.
# ==============================================================================

set -Eeuo pipefail

readonly SCRIPT_NAME="$(basename "$0")"
readonly DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly EXPECTED_DIR="$HOME/dotfiles"
readonly CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
readonly STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/lagos"
readonly TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
readonly BACKUP_DIR="$STATE_DIR/backups/$TIMESTAMP"
readonly LOG_FILE="$STATE_DIR/install-$TIMESTAMP.log"

readonly PKG_LIST="$DOTFILES_DIR/System/pkglist.txt"
readonly COPR_LIST="$DOTFILES_DIR/System/coprs.txt"
readonly FLATPAK_LIST="$DOTFILES_DIR/System/flatpaks.txt"
readonly DEFAULT_STARSHIP_PROFILE="2-line-nixos"

# Packages from the system snapshot that must never be installed on a deployed
# host (live-ISO tooling, kernel-pinned kmods rebuilt by akmod) or that only
# apply to specific hardware.
readonly PKG_EXCLUDE_REGEX='^(anaconda.*|dracut-live|livesys-scripts|kmod-nvidia-.*)$'
readonly NVIDIA_PKG_REGEX='^(akmod-nvidia|xorg-x11-drv-nvidia.*|nvidia-.*)$'

readonly ALL_STEPS=(repos packages flatpaks links local shell)

# Source (relative to repo) -> destination. Directories are linked whole.
readonly LINKS=(
  "zsh/.zshrc:$HOME/.zshrc"
  "git/.gitconfig:$HOME/.gitconfig"
  "gpg/gpg-agent.conf:$HOME/.gnupg/gpg-agent.conf"
  "config/hypr:$CONFIG_DIR/hypr"
  "config/kitty:$CONFIG_DIR/kitty"
  "config/starship:$CONFIG_DIR/starship"
  "config/wlogout:$CONFIG_DIR/wlogout"
  "nvim:$CONFIG_DIR/nvim"
  "scripts/build-paper/build_paper.py:$HOME/.local/bin/build-paper"
  "scripts/lagos-shot/lagos-shot.py:$HOME/.local/bin/lagos-shot"
)

# Machine-specific files created from committed templates when missing.
readonly LOCAL_TEMPLATES=(
  "config/hypr/monitors.conf"
  "config/hypr/monitors.lua"
  "config/hypr/UserConfigs/monitors.lua"
)

DRY_RUN=0
ASSUME_YES=0
SELECTED_STEPS=("${ALL_STEPS[@]}")
WARNINGS=()

# ------------------------------------------------------------------------------
# Output
# ------------------------------------------------------------------------------

if [[ -t 1 ]]; then
  readonly C_RESET=$'\e[0m' C_BOLD=$'\e[1m' C_DIM=$'\e[2m'
  readonly C_BLUE=$'\e[34m' C_GREEN=$'\e[32m' C_YELLOW=$'\e[33m' C_RED=$'\e[31m'
else
  readonly C_RESET='' C_BOLD='' C_DIM='' C_BLUE='' C_GREEN='' C_YELLOW='' C_RED=''
fi

step() { printf '\n%s==> %s%s\n' "$C_BOLD$C_BLUE" "$*" "$C_RESET"; }
info() { printf '  %s•%s %s\n' "$C_DIM" "$C_RESET" "$*"; }
ok()   { printf '  %s✓%s %s\n' "$C_GREEN" "$C_RESET" "$*"; }
warn() { printf '  %s!%s %s\n' "$C_YELLOW" "$C_RESET" "$*" >&2; WARNINGS+=("$*"); }
die()  { printf '%serror:%s %s\n' "$C_RED$C_BOLD" "$C_RESET" "$*" >&2; exit 1; }

on_error() {
  local exit_code=$? line=$1
  printf '%serror:%s command failed (exit %d) at line %d: %s\n' \
    "$C_RED$C_BOLD" "$C_RESET" "$exit_code" "$line" "$BASH_COMMAND" >&2
  [[ $DRY_RUN -eq 0 ]] && printf 'Full log: %s\n' "$LOG_FILE" >&2
  exit "$exit_code"
}
trap 'on_error $LINENO' ERR

# Runs a command, or only prints it in dry-run mode.
run() {
  if [[ $DRY_RUN -eq 1 ]]; then
    printf '  %s[dry-run]%s %s\n' "$C_YELLOW" "$C_RESET" "$*"
  else
    "$@"
  fi
}

confirm() {
  [[ $ASSUME_YES -eq 1 ]] && return 0
  local reply
  read -r -p "  $1 [y/N] " reply
  [[ $reply =~ ^[Yy]([Ee][Ss])?$ ]]
}

# Prints the non-empty, non-comment lines of a list file.
read_list() {
  [[ -f $1 ]] || die "list not found: $1"
  grep -vE '^[[:space:]]*(#|$)' "$1" | sed 's/[[:space:]]*$//'
}

has_step() {
  local s
  for s in "${SELECTED_STEPS[@]}"; do [[ $s == "$1" ]] && return 0; done
  return 1
}

usage() {
  cat <<EOF
Usage: $SCRIPT_NAME [options]

Provision this Fedora workstation from the lagOS-station dotfiles.

Options:
  -n, --dry-run        Show what would be done without changing anything
  -y, --yes            Do not prompt for confirmation
      --only STEPS     Run only these comma-separated steps
      --skip STEPS     Skip these comma-separated steps
  -h, --help           Show this help

Steps (in order):
  repos      Enable RPM Fusion, Flathub and the COPRs in System/coprs.txt
  packages   Install DNF packages from System/pkglist.txt
  flatpaks   Install Flatpaks from System/flatpaks.txt
  links      Symlink configs into \$HOME (existing files are backed up)
  local      Create machine-specific files from *.example templates
  shell      Install Oh My Zsh and set zsh as the login shell

Examples:
  $SCRIPT_NAME --dry-run
  $SCRIPT_NAME --only links,local
  $SCRIPT_NAME --yes --skip flatpaks

Backups go to $STATE_DIR/backups/<timestamp>/ and logs to $STATE_DIR/.
EOF
}

validate_steps() {
  local s valid
  for s in "$@"; do
    valid=0
    for v in "${ALL_STEPS[@]}"; do [[ $s == "$v" ]] && valid=1; done
    [[ $valid -eq 1 ]] || die "unknown step '$s' (valid: ${ALL_STEPS[*]})"
  done
}

parse_args() {
  local -a only=() skip=()
  while [[ $# -gt 0 ]]; do
    case $1 in
      -n|--dry-run) DRY_RUN=1 ;;
      -y|--yes) ASSUME_YES=1 ;;
      --only) [[ $# -ge 2 ]] || die "--only needs a value"; IFS=, read -ra only <<<"$2"; shift ;;
      --skip) [[ $# -ge 2 ]] || die "--skip needs a value"; IFS=, read -ra skip <<<"$2"; shift ;;
      -h|--help) usage; exit 0 ;;
      *) die "unknown option '$1' (see --help)" ;;
    esac
    shift
  done

  if [[ ${#only[@]} -gt 0 ]]; then
    validate_steps "${only[@]}"
    SELECTED_STEPS=()
    for s in "${ALL_STEPS[@]}"; do
      for o in "${only[@]}"; do [[ $s == "$o" ]] && SELECTED_STEPS+=("$s"); done
    done
  fi
  if [[ ${#skip[@]} -gt 0 ]]; then
    validate_steps "${skip[@]}"
    local -a kept=()
    for s in "${SELECTED_STEPS[@]}"; do
      local skipped=0
      for k in "${skip[@]}"; do [[ $s == "$k" ]] && skipped=1; done
      [[ $skipped -eq 0 ]] && kept+=("$s")
    done
    SELECTED_STEPS=("${kept[@]}")
  fi
  [[ ${#SELECTED_STEPS[@]} -gt 0 ]] || die "no steps selected"
}

# ------------------------------------------------------------------------------
# Pre-flight
# ------------------------------------------------------------------------------

preflight() {
  step "Pre-flight checks"

  [[ $EUID -ne 0 ]] || die "run as your normal user, not root (sudo is used when needed)"

  if [[ -r /etc/os-release ]] && grep -q '^ID=fedora' /etc/os-release; then
    ok "Fedora $(rpm -E %fedora) detected"
  else
    warn "this script targets Fedora; package steps may fail on this system"
  fi

  if [[ $DOTFILES_DIR != "$EXPECTED_DIR" ]]; then
    warn "repo is at $DOTFILES_DIR, but configs hardcode $EXPECTED_DIR; clone it there"
  else
    ok "repository at $DOTFILES_DIR"
  fi

  if has_step repos || has_step packages || has_step shell; then
    if [[ $DRY_RUN -eq 0 ]]; then
      info "requesting sudo for system changes"
      sudo -v
      # Keep the sudo timestamp fresh until this script exits.
      while true; do sudo -n true; sleep 50; kill -0 "$$" 2>/dev/null || exit; done 2>/dev/null &
    fi
  fi

  info "steps: ${SELECTED_STEPS[*]}"
  [[ $DRY_RUN -eq 1 ]] && info "dry run: no changes will be made"
  return 0
}

# ------------------------------------------------------------------------------
# Steps
# ------------------------------------------------------------------------------

step_repos() {
  step "Repositories"
  local fedora
  fedora="$(rpm -E %fedora)"

  local repo
  for repo in free nonfree; do
    if rpm -q "rpmfusion-$repo-release" &>/dev/null; then
      ok "RPM Fusion $repo already enabled"
    else
      run sudo dnf install -y \
        "https://mirrors.rpmfusion.org/$repo/fedora/rpmfusion-$repo-release-$fedora.noarch.rpm"
    fi
  done

  if ! rpm -q dnf5-plugins &>/dev/null; then
    run sudo dnf install -y dnf5-plugins
  fi

  local enabled copr
  enabled="$(dnf repolist --enabled 2>/dev/null || true)"
  while IFS= read -r copr; do
    if grep -q "copr:copr.fedorainfracloud.org:${copr/\//:} " <<<"$enabled"; then
      ok "COPR $copr already enabled"
    else
      run sudo dnf copr enable -y "$copr"
    fi
  done < <(read_list "$COPR_LIST")

  run flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
  ok "Flathub configured"
}

step_packages() {
  step "DNF packages"
  local -a packages=()
  local pkg has_nvidia=0

  if command -v lspci &>/dev/null && lspci | grep -qi 'vga.*nvidia\|3d.*nvidia'; then
    has_nvidia=1
  fi

  while IFS= read -r pkg; do
    [[ $pkg =~ $PKG_EXCLUDE_REGEX ]] && continue
    [[ $has_nvidia -eq 0 && $pkg =~ $NVIDIA_PKG_REGEX ]] && continue
    packages+=("$pkg")
  done < <(read_list "$PKG_LIST")

  [[ $has_nvidia -eq 1 ]] && info "NVIDIA GPU detected: including driver packages" \
    || info "no NVIDIA GPU detected: skipping driver packages"
  info "installing ${#packages[@]} packages (unavailable ones are skipped)"

  run sudo dnf install -y --skip-unavailable "${packages[@]}"
  ok "packages installed"
}

step_flatpaks() {
  step "Flatpaks"
  local -a apps=()
  local app
  while IFS= read -r app; do
    # Skip the header row of `flatpak list --columns=application` exports.
    [[ $app == "Application" ]] && continue
    apps+=("$app")
  done < <(read_list "$FLATPAK_LIST")

  [[ ${#apps[@]} -gt 0 ]] || { info "no Flatpaks listed"; return 0; }
  run flatpak install -y --noninteractive flathub "${apps[@]}"
  ok "${#apps[@]} Flatpaks installed"
}

# Symlinks $1 to $2, backing up anything already at $2.
link() {
  local src=$1 dest=$2

  [[ -e $src ]] || { warn "missing source, skipped: $src"; return 0; }

  if [[ -L $dest && "$(readlink "$dest")" == "$src" ]]; then
    ok "${dest/#$HOME/\~}"
    return 0
  fi

  if [[ -e $dest || -L $dest ]]; then
    local backup="$BACKUP_DIR/${dest#"$HOME"/}"
    run mkdir -p "$(dirname "$backup")"
    run mv "$dest" "$backup"
    info "backed up ${dest/#$HOME/\~} -> ${backup/#$HOME/\~}"
  fi

  run mkdir -p "$(dirname "$dest")"
  run ln -s "$src" "$dest"
  ok "${dest/#$HOME/\~} -> ${src/#$HOME/\~}"
}

step_links() {
  step "Configuration symlinks"
  local entry
  for entry in "${LINKS[@]}"; do
    link "$DOTFILES_DIR/${entry%%:*}" "${entry#*:}"
  done

  # GnuPG refuses to use a home directory readable by others.
  [[ -d $HOME/.gnupg ]] && run chmod 700 "$HOME/.gnupg"

  # Default prompt profile; ChangeStarshipPrompt.sh switches it afterwards.
  local starship_toml="$CONFIG_DIR/starship.toml"
  if [[ -e $starship_toml || -L $starship_toml ]]; then
    ok "${starship_toml/#$HOME/\~} already set"
  else
    run ln -s "$CONFIG_DIR/starship/$DEFAULT_STARSHIP_PROFILE.toml" "$starship_toml"
    ok "${starship_toml/#$HOME/\~} -> $DEFAULT_STARSHIP_PROFILE"
  fi
}

step_local() {
  step "Machine-specific files"
  local file
  for file in "${LOCAL_TEMPLATES[@]}"; do
    if [[ -e $DOTFILES_DIR/$file ]]; then
      ok "$file exists"
    else
      run cp "$DOTFILES_DIR/$file.example" "$DOTFILES_DIR/$file"
      ok "$file created from template; adjust it for this machine"
    fi
  done

  local weather_home="$CONFIG_DIR/lagos/weather-home"
  if [[ -s $weather_home ]]; then
    ok "weather home location set"
  elif [[ $ASSUME_YES -eq 0 && $DRY_RUN -eq 0 && -t 0 ]]; then
    local city
    read -r -p "  Weather home location (City, State, Country; empty to skip): " city
    if [[ -n $city ]]; then
      mkdir -p "$(dirname "$weather_home")"
      printf '%s\n' "$city" >"$weather_home"
      ok "weather home location saved"
    else
      info "weather home location skipped; the widget will use IP geolocation"
    fi
  else
    info "no weather home location; write one to ${weather_home/#$HOME/\~} to enable the toggle"
  fi
}

step_shell() {
  step "Shell"

  if [[ -d $HOME/.oh-my-zsh ]]; then
    ok "Oh My Zsh installed"
  else
    run git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
    ok "Oh My Zsh installed"
  fi

  local zsh_path current_shell
  zsh_path="$(command -v zsh || true)"
  [[ -n $zsh_path ]] || { warn "zsh not installed; run the packages step first"; return 0; }

  current_shell="$(getent passwd "$USER" | cut -d: -f7)"
  if [[ $current_shell == "$zsh_path" ]]; then
    ok "login shell is zsh"
  elif confirm "Change login shell from $current_shell to $zsh_path?"; then
    run sudo chsh -s "$zsh_path" "$USER"
    ok "login shell set to zsh (takes effect at next login)"
  else
    info "login shell unchanged"
  fi
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------

summary() {
  step "Done"
  if [[ ${#WARNINGS[@]} -gt 0 ]]; then
    printf '  %s%d warning(s):%s\n' "$C_YELLOW" "${#WARNINGS[@]}" "$C_RESET"
    local w
    for w in "${WARNINGS[@]}"; do printf '    - %s\n' "$w"; done
  fi
  if [[ $DRY_RUN -eq 0 ]]; then
    [[ -d $BACKUP_DIR ]] && info "backups: ${BACKUP_DIR/#$HOME/\~}"
    info "log: ${LOG_FILE/#$HOME/\~}"
  fi
  info "next: log out and back in, or run 'exec zsh' and 'hyprctl reload'"
}

main() {
  parse_args "$@"

  if [[ $DRY_RUN -eq 0 ]]; then
    mkdir -p "$STATE_DIR"
    exec > >(tee -a "$LOG_FILE") 2>&1
  fi

  printf '%slagOS-station bootstrapper%s\n' "$C_BOLD" "$C_RESET"
  preflight

  if [[ $DRY_RUN -eq 0 ]] && ! confirm "Proceed with: ${SELECTED_STEPS[*]}?"; then
    info "aborted"
    exit 0
  fi

  local s
  for s in "${SELECTED_STEPS[@]}"; do
    "step_$s"
  done

  summary
}

main "$@"
