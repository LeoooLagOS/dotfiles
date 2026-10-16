#!/usr/bin/env bash
# Notification demo for recording a video of the panel: every kind of
# notification, one after another, with pauses so each can be seen.
#   NotifDemo.sh            a 5 s countdown (start recording), then the demo
#   NotifDemo.sh -w 0       no countdown
#   NotifDemo.sh -p 2.5     seconds between notifications (default 3)
#   NotifDemo.sh -k KIND…   only these: message group mail call reminder code
#                           volume brightness progress download media system critical
#   NotifDemo.sh -x NAME -y NAME   the two people in them (default: the panel's
#                           Settings → Demos, else "Persona X" and "Persona Y")
# They're marked x-lagos-test: the panel never offers to reply to them and a
# click opens nothing; they stay in the history like real ones (Clear all
# removes them). The panel runs it too (Settings → Demos: one kind, or all).

set -u
pause=3
wait=5
kinds=()
# The two people: the panel's Settings → Demos, overridden by -x / -y
settings="${XDG_CONFIG_HOME:-$HOME/.config}/lagos/panel-settings.json"
read_name() {
  python3 -c 'import json,sys
try: print(json.load(open(sys.argv[1])).get(sys.argv[2]) or "")
except Exception: print("")' "$settings" "$1" 2>/dev/null
}
X=$(read_name demoPersonX); X=${X:-Persona X}
Y=$(read_name demoPersonY); Y=${Y:-Persona Y}
while [ $# -gt 0 ]; do
  case $1 in
    -p) pause=$2; shift 2 ;;
    -w) wait=$2; shift 2 ;;
    -x) X=$2; shift 2 ;;
    -y) Y=$2; shift 2 ;;
    -k) shift; while [ $# -gt 0 ] && [[ $1 != -* ]]; do kinds+=("$1"); shift; done ;;
    -h|--help) sed -n '2,14p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option: $1" >&2; exit 2 ;;
  esac
done
want() { [ ${#kinds[@]} -eq 0 ] || [[ " ${kinds[*]} " == *" $1 "* ]]; }

# notify-send with the test mark; with actions it waits for an answer, so in
# the background (at most two minutes)
send() { timeout 120 notify-send -h boolean:x-lagos-test:true "$@" >/dev/null 2>&1 & }
# The same, printing the id (to replace it in place: progress, levels)
send_id() { notify-send -p -h boolean:x-lagos-test:true "$@"; }
step() { sleep "$pause"; }

TEAMS=com.github.IsmaelMartinez.teams_for_linux

if [ "$wait" != 0 ]; then
  for i in $(seq "$wait" -1 1); do printf '\rStarting in %s… ' "$i"; sleep 1; done; printf '\r%-20s\n' "Go"
fi

if want message; then
  echo "· message (WhatsApp)"
  send -a "WhatsApp Web" -h string:category:im.received "$X" "¿Ya viste el video que te mandé? 😄" -A default=Open
  step
fi

if want group; then
  echo "· messages from one chat, grouped (Teams)"
  send -a "Teams" -i $TEAMS -h string:category:im.received "$Y" "Hola, ¿tienes un momento?" -A default=Open
  sleep 1.2
  send -a "Teams" -i $TEAMS -h string:category:im.received "$Y" "Quería revisar contigo la presentación de mañana" -A default=Open
  sleep 1.2
  send -a "Teams" -i $TEAMS -h string:category:im.received "$Y" "Te dejé comentarios en las diapositivas 4 y 7" -A default=Open
  step
fi

if want mail; then
  echo "· email (Thunderbird)"
  send -a "Thunderbird" -i thunderbird "alumno@universidad.edu received 1 new message" "Avance del proyecto final from \"$X\""
  step
fi

if want call; then
  echo "· incoming call (Teams)"
  send -a "Teams" -i $TEAMS -h string:category:call.incoming "Incoming call" "$X is calling you" -A answer=Answer -A decline=Decline
  step; step
fi

if want reminder; then
  echo "· calendar reminder"
  send -a "Calendar" -i x-office-calendar -h string:category:calendar "Reunión con $Y · in 10 minutes" "16:00 – 17:00 · Sala de juntas"
  step
fi

if want code; then
  echo "· security code"
  send -a "Microsoft account" -i dialog-password "Your security code" "Use 482913 to sign in. It expires in 10 minutes."
  step
fi

if want volume; then
  echo "· volume (one bar, updating in place)"
  id=$(send_id -a Volume -i audio-volume-medium -h string:x-canonical-private-synchronous:volume -h int:value:40 Volume)
  for v in 50 60 70 80 70 60; do
    sleep 0.35
    notify-send -r "$id" -h boolean:x-lagos-test:true -a Volume -i audio-volume-high \
      -h string:x-canonical-private-synchronous:volume -h int:value:$v Volume >/dev/null
  done
  step
fi

if want brightness; then
  echo "· brightness"
  id=$(send_id -a Brightness -i display-brightness -h string:x-canonical-private-synchronous:brightness -h int:value:30 Brightness)
  for v in 45 60 75; do
    sleep 0.35
    notify-send -r "$id" -h boolean:x-lagos-test:true -a Brightness -i display-brightness \
      -h string:x-canonical-private-synchronous:brightness -h int:value:$v Brightness >/dev/null
  done
  step
fi

if want progress; then
  echo "· progress (a download filling in place)"
  id=$(send_id -a Downloads -i folder-download -h int:value:0 "Downloading presentacion.pdf" "0 MB of 24 MB")
  for v in 15 35 55 75 90 100; do
    sleep 0.5
    notify-send -r "$id" -h boolean:x-lagos-test:true -a Downloads -i folder-download -h int:value:$v \
      "Downloading presentacion.pdf" "$((v * 24 / 100)) MB of 24 MB" >/dev/null
  done
  step
fi

if want download; then
  echo "· download finished (scripts/wm/DownloadWatch.py)"
  send -a Downloads -i x-office-document -h string:category:transfer.complete \
    -A default=Open -A open=Open -A "folder=Show in folder" "Download complete" "presentacion.pdf
24.0 MB"
  step
fi

if want media; then
  echo "· now playing"
  send -a "Spotify" -i com.spotify.Client -h string:category:x-gnome.music "La puerta de al lado" "Los Rodríguez · Palabras más, palabras menos"
  step
fi

if want system; then
  echo "· system"
  send -a "NetworkManager" -i network-wireless "Connected" "Home Wi-Fi"
  step
fi

if want critical; then
  echo "· critical"
  send -u critical -a "Battery" -i battery-caution "Battery low" "5% left: plug in the charger"
  step
fi

echo "Done. Clear them from the Notifications tab (Clear all)."

exit 0
