#!/usr/bin/env bash
# Build the quickcalc rofi plugin and install it in ~/.local/lib/rofi, next to
# links to the system plugins (rofi reads one plugin directory, given by
# $ROFI_PLUGIN_PATH in scripts/wm/RofiLauncher.sh).
# Needs: rofi-devel (rofi 2.x headers), libqalculate-devel, g++.

set -euo pipefail
cd "$(dirname "$0")"

dest="$(realpath -m "$HOME/.local/lib/rofi")"
mkdir -p "$dest"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
# engine.cc (libqalculate) and mode.c (rofi) can't share a translation unit:
# both libraries' headers define PropertyType
g++ -std=c++17 -O2 -fPIC -Wall -c engine.cc -o "$tmp/engine.o" $(pkg-config --cflags libqalculate)
gcc -std=gnu11 -O2 -fPIC -Wall -c mode.c -o "$tmp/mode.o" $(pkg-config --cflags rofi glib-2.0 gmodule-2.0 cairo)
g++ -shared "$tmp/engine.o" "$tmp/mode.o" -o "$dest/quickcalc.so" \
  $(pkg-config --libs libqalculate glib-2.0 gmodule-2.0 cairo)

# Keep the system plugins (e.g. the Calc tab, libcalc.so) available too
for so in /usr/lib64/rofi/*.so /usr/lib/rofi/*.so; do
  [[ -e $so ]] && ln -sf "$so" "$dest/$(basename "$so")"
done

echo "installed $dest/quickcalc.so"
