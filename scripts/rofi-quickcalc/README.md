# rofi-quickcalc

A tiny rofi mode that answers math **inside the app launcher** (SUPER D): type
`2+2*3`, `15% * 80`, `sqrt(2)*pi`, `10 km to mi` or `100 USD to MXN` in the
Apps search and the first row is the result (Enter copies it). An expression
in `x` (`x^2 - 3x`, `sin(x)/x`) gets a **Plot** row instead, which opens the
graph (`scripts/wm/CalcPlot.sh`).

- `mode.c` — the rofi side. rofi's combi mode doesn't hand its modes the raw
  input, so it reads it from the view (`rofi_view_get_user_input`, exported by
  rofi). It always has two rows and shows/hides them in `token_match`, because
  combi counts entries only once.
- `engine.cc` — libqalculate in-process, loaded in a background thread when rofi
  starts, so typing never waits. Only input with a digit (or `x`, or a leading
  `=`) is evaluated, and every word must be a known function, variable, unit or
  keyword: app names such as "IntelliJ 2026" are never treated as math.
  Separate file because libqalculate's and rofi's headers both define `PropertyType`.
- `build.sh` — builds `~/.local/lib/rofi/quickcalc.so` and links the system
  plugins there (rofi reads one plugin directory; `scripts/wm/RofiLauncher.sh`
  sets `ROFI_PLUGIN_PATH`). `install.sh` runs it. Rebuild after a rofi or
  libqalculate upgrade if the launcher stops showing results.

Needs `rofi-devel` (rofi 2.x), `libqalculate-devel`, `gcc-c++`; plots need
`qalculate` (qalc) and `gnuplot`.

The full calculator (history, conversions, plots with `plot f(x) a b`) is the
Calc tab of SUPER D and its own window, SUPER ALT C / the Calculator key
(`scripts/wm/RofiCalc.sh`).
