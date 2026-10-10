#!/usr/bin/env bash
# Battery notifier: alerts while discharging at 50% (with time remaining), 20%,
# and a big centered popup at 10% and 5%. Each threshold fires once per discharge
# cycle and re-arms when the charger is plugged in.
# The levels can be changed in the Quickshell panel (Settings → Power & idle),
# which writes them to ~/.config/lagos/battery-alerts ("50 20 10 5"). A level
# at or below 10% shows the big popup; at or below 25%, a "low" notification.

BAT=$(ls -d /sys/class/power_supply/BAT* 2>/dev/null | head -n1)
[ -z "$BAT" ] && exit 0

INTERVAL=30
ALERTS_FILE="${XDG_CONFIG_HOME:-$HOME/.config}/lagos/battery-alerts"
fired=""   # thresholds already notified this discharge cycle, e.g. " 50 20 "

time_left() {
  # Prefer upower's estimate; fall back to energy_now / power_now
  local t
  t=$(upower -i "$(upower -e | grep -m1 BAT)" 2>/dev/null | awk -F: '/time to empty/ {gsub(/^ +/, "", $2); print $2}')
  if [ -n "$t" ]; then echo "$t"; return; fi
  local e p
  e=$(cat "$BAT/energy_now" 2>/dev/null); p=$(cat "$BAT/power_now" 2>/dev/null)
  if [ -n "$e" ] && [ -n "$p" ] && [ "$p" -gt 0 ]; then
    local mins=$(( e * 60 / p ))
    printf '%dh %02dmin\n' $((mins / 60)) $((mins % 60))
  else
    echo "unknown"
  fi
}

big_alert() {
  local pct=$1
  # Apple-style dark card, matching swaync's .notification.critical
  local red='#ff453a' fg='#f2f2f2' dim='#9a9aa0' bg='#1e1e20' alt='#3a3a3c'
  # Summary is styled as the small red "CRITICAL" header in swaync; body holds the title
  notify-send -u critical -i battery-empty -a "Battery" "⚠ CRITICAL" \
    "<span size='large' weight='bold'>Battery ${pct}%</span>
Plug in the charger now"
  pkill -f "yad --title=BatteryAlert" 2>/dev/null

  # Same look as swaync's critical notifications (see ~/.config/swaync/style.css)
  local css="
    * { font-family: 'Inter', 'Inter Variable', sans-serif; font-weight: normal; text-shadow: none; box-shadow: none; }
    window { background: $bg; }
    window > box { background: $bg; color: $fg;
                   border: 1px solid $alt; border-radius: 20px;
                   padding: 28px 32px 24px; }
    label { color: $fg; }
    button { background: mix($bg, $alt, 0.5); color: $fg; background-image: none;
             border: 1px solid $alt; border-radius: 12px; padding: 6px 28px; }
    button:hover { background: $alt; }
  "
  yad --title=BatteryAlert --class=BatteryAlert --center --on-top --undecorated \
      --width=520 --borders=0 --button="OK:0" --buttons-layout=center --timeout=30 \
      --text-align=center --css="$css" \
      --text="<span size='11pt' weight='bold' foreground='$red'>⚠ CRITICAL</span>
<span size='26pt' weight='bold' foreground='$fg'>Battery ${pct}%</span>

<span size='12pt' foreground='$dim'>Time remaining: $(time_left)
Plug in the charger now!</span>" &
}

while true; do
  status=$(cat "$BAT/status")
  cap=$(cat "$BAT/capacity")

  # Thresholds from the Quickshell panel (Settings → Power & idle), else the defaults
  levels=$(tr -cs '0-9' ' ' 2>/dev/null <"$ALERTS_FILE")
  levels=$(printf '%s\n' ${levels:-50 20 10 5} | sort -n | tr '\n' ' ')

  if [ "$status" = "Discharging" ]; then
    for th in $levels; do
      if [ "$cap" -le "$th" ] && [[ "$fired" != *" $th "* ]]; then
        # Mark this and all higher thresholds as done so we only alert once (e.g. unplugging at 15%)
        for t in $levels; do [ "$t" -ge "$th" ] && fired+=" $t "; done
        if [ "$th" -le 10 ]; then
          big_alert "$cap"
        elif [ "$th" -le 25 ]; then
          notify-send -u normal -i battery-low  -a "Battery" "Battery low: ${cap}%" "Time remaining: $(time_left)"
        else
          notify-send -u normal -i battery-good -a "Battery" "Battery at ${cap}%" "Time remaining: $(time_left)"
        fi
        break
      fi
    done
  else
    fired=""
    pkill -f "yad --title=BatteryAlert" 2>/dev/null
  fi

  sleep "$INTERVAL"
done
