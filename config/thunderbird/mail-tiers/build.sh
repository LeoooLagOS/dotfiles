#!/usr/bin/env bash
# Package the add-on with your private tier table, and optionally install it.
#   code   : this folder (in the repo)
#   config : ~/.config/lagos/mail/tiers.json (names your accounts: never in the repo)
#   output : ~/.config/lagos/mail/lagos-mail-tiers.xpi
#
#   build.sh            build only
#   build.sh --install  build and drop the add-on into the profile's extensions/ folder; a running
#                       Thunderbird restarts hidden when idle (ThunderbirdColors.sh) and loads it.
#                       No reinstalling from the Add-ons manager.
#
# First install only: Add-ons and Themes → ⚙ → Install Add-on From File (so Thunderbird
# trusts it); after that, --install updates it in place.
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)
cfg=${XDG_CONFIG_HOME:-$HOME/.config}/lagos/mail
id=mail-tiers@lagos
[ -f "$cfg/tiers.json" ] || { echo "missing $cfg/tiers.json" >&2; exit 1; }
python3 -I -c 'import json,sys; json.load(open(sys.argv[1]))' "$cfg/tiers.json"   # fail early on bad JSON

tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
cp "$here/background.js" "$cfg/tiers.json" "$tmp/"
# Build number: minutes since the epoch, appended to the manifest's version (1.2 → 1.2.29925845),
# so every build is newer than the last and Thunderbird shows which one is running
build=$(( $(date +%s) / 60 ))
python3 -I - "$here/manifest.json" "$tmp/manifest.json" "$build" <<'EOF'
import json, sys
m = json.load(open(sys.argv[1]))
m["version"] = m["version"].split(".")[0] + "." + m["version"].split(".")[1] + "." + sys.argv[3]
json.dump(m, open(sys.argv[2], "w"), indent=2)
print("version", m["version"])
EOF
rm -f "$cfg/lagos-mail-tiers.xpi"
(cd "$tmp" && zip -q -X "$cfg/lagos-mail-tiers.xpi" manifest.json background.js tiers.json)
echo "built $cfg/lagos-mail-tiers.xpi"

[ "${1:-}" = "--install" ] || exit 0

# The profile Thunderbird starts with: the [Install…] section's Default= in profiles.ini
tb=${XDG_CONFIG_HOME:-$HOME/.config}/thunderbird
profile=$(awk -F= '/^\[Install/{inst=1; next} /^\[/{inst=0} inst && $1=="Default"{print $2; exit}' "$tb/profiles.ini")
dest="$tb/$profile/extensions/$id.xpi"
[ -f "$dest" ] || { echo "not installed yet in $profile: install it once from the Add-ons manager" >&2; exit 1; }

# Copy then rename: the new file gets a new inode, so a running Thunderbird keeps reading the
# old one safely; at its next start it sees the change and loads the new version
cp "$cfg/lagos-mail-tiers.xpi" "$dest.new"
mv -f "$dest.new" "$dest"
echo "installed into $profile"

# Running: restart it hidden, when you're not using it (the same script that reloads its
# colors: waits while it's focused, shown or has a second window open)
restart=$HOME/.config/hypr/scripts/ThunderbirdColors.sh
if pgrep -x thunderbird >/dev/null && [ -x "$restart" ]; then
  setsid "$restart" >/dev/null 2>&1 < /dev/null &
  echo "Thunderbird restarts hidden as soon as it's idle"
else
  echo "it loads at Thunderbird's next start"
fi
