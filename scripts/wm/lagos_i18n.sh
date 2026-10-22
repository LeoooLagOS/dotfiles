# shellcheck shell=bash
# Translations for the desktop scripts, shared with the Quickshell panel
# (config/quickshell/panel/common/Tr.qml): the language is the panel's
# Settings → Appearance → Language, or the system's (LANG) when it says
# "System"; the words come from the panel's i18n/<lang>.json, keyed by the
# English text. A missing one stays English.
#   . "$(dirname "$(readlink -f "$0")")/lagos_i18n.sh"
#   t "Battery at %1" "$cap"        → "Batería al 40" (%1, %2… = the arguments)

LAGOS_I18N_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/panel/i18n"

lagos_lang() {
  local l
  l=$(jq -r '.language // "system"' "${XDG_CONFIG_HOME:-$HOME/.config}/lagos/panel-settings.json" 2>/dev/null || true)
  [[ -z $l || $l == system || $l == null ]] && l=${LC_ALL:-${LC_MESSAGES:-${LANG:-en}}}
  l=${l%%[_.@]*}
  [[ $l != en && -f $LAGOS_I18N_DIR/$l.json ]] && echo "$l" || echo en
}
LAGOS_LANG=$(lagos_lang)

# The whole dictionary in one jq call (English text → translation)
declare -gA LAGOS_TR=()
if [[ $LAGOS_LANG != en ]]; then
  while IFS= read -r -d '' k && IFS= read -r -d '' v; do LAGOS_TR[$k]=$v; done \
    < <(jq -j 'to_entries[] | .key, "\u0000", .value, "\u0000"' "$LAGOS_I18N_DIR/$LAGOS_LANG.json" 2>/dev/null || true)
fi

t() {
  local s=$1 i=1
  shift
  [[ -n ${LAGOS_TR[$s]+set} ]] && s=${LAGOS_TR[$s]}
  for a in "$@"; do s=${s//%$i/$a}; i=$((i + 1)); done
  printf '%s' "$s"
}
