#!/usr/bin/env bash
# Enter in the Calc tab / calculator (rofi-calc's -calc-command):
#   RofiCalcAction.sh EXPRESSION RESULT
# An expression in x, or "plot f(x) [from to]", opens the graph (CalcPlot.sh);
# anything else copies the result.

expr="${1:-}"
result="${2:-}"
scripts="${XDG_CONFIG_HOME:-$HOME/.config}/hypr/scripts"
re_plot='^[[:space:]]*plot[[:space:](]+(.*)$'
re_x='(^|[^[:alpha:]_])x([^[:alpha:]_]|$)'

# "plot x^2 -5 5" or "plot(x^2, -5, 5)"
if [[ "$expr" =~ $re_plot ]]; then
  args="${BASH_REMATCH[1]%)}"
  IFS=',' read -r f a b <<<"$args"
  if [[ -z "$a" ]]; then          # space-separated form
    read -r -a parts <<<"$args"
    n=${#parts[@]}
    if (( n >= 3 )) && [[ ${parts[n-1]} =~ ^-?[0-9.]+$ && ${parts[n-2]} =~ ^-?[0-9.]+$ ]]; then
      f="${parts[*]:0:n-2}"; a="${parts[n-2]}"; b="${parts[n-1]}"
    fi
  fi
  a="${a// /}"; b="${b// /}"
  exec "$scripts/CalcPlot.sh" "$f" ${a:+"$a"} ${b:+"$b"}
fi
if [[ "$expr" =~ $re_x ]]; then
  exec "$scripts/CalcPlot.sh" "$expr"
fi
printf '%s' "$result" | wl-copy
