# 🍨 flavors/ — Ready-made setups for what you work on

A **flavor** is everything one kind of work needs, on top of the base system: its apps, its configs, the permissions its apps need and sensible settings for them. Like Fedora Labs, but chosen per machine and combinable. The base (`System/`, `config/`) is what every lagOS-station gets; a flavor is what only some of them need.

```bash
./install.sh --list-flavors              # what exists, * = chosen on this machine
./install.sh --flavors audiophile,dj     # choose (saved in ~/.config/lagos/flavors)
./install.sh --flavors none              # none
./install.sh                             # later runs reuse the saved choice
```

## The flavors

| Id | Name (ES) | For | Audio profile |
| :-- | :-- | :-- | :-- |
| `audiophile` | Audiophile (Melómano) | Listening to and collecting music: bit-perfect playback, Picard / beets tagging, the panel Library's quality check | Rate follows the music (44.1 → 96 → 192 kHz) |
| `dj` | DJ | Mixing live with Mixxx on the same `~/Music` library | Fixed rate |
| `producer` | Producer (Productor) | Composing, recording, mixing: Bitwig, REAPER, Ardour, Surge XT, JACK on PipeWire, realtime priority | Fixed rate, low latency |

The three form the **music family**. The panel's Library (MPD, mpDris2, ffmpeg) isn't in any of them: it's base, because anyone may have music in `~/Music`.

### Audiophile and Producer on one machine
Their audio profiles contradict: the Audiophile's `10-hires.conf` lets the sound card switch rate with each song, which a DAW doesn't want mid-session (clicks, a project at the wrong rate). With both chosen, the Audiophile's config is installed; for a recording session, pin the rate until you're done:

```bash
pw-metadata -n settings 0 clock.force-rate 48000   # session: one fixed rate
pw-metadata -n settings 0 clock.force-rate 0       # back to following the music
```

Or from the desktop, without a terminal: the **start menu** on the bar's logo (Mode) by mouse, or **SUPER ALT F** (`scripts/wm/FlavorMenu.sh`) by keyboard. Both call `scripts/wm/FlavorMode.sh` (`list` as JSON · `set <id>` · `install <id>`). The rofi menu lists the installed flavors with their audio profile; picking one sets it on the fly (`follow-music-rate` → `force-rate 0`, `fixed-rate*` → 48 kHz, none → untouched) and then offers its apps (its Flatpaks and the `pkglist.txt` packages that ship a launcher). It lasts until another is picked or PipeWire restarts. Flavors not installed yet are listed last: picking one runs `install.sh --flavors … --only packages,flatpaks,links,flavors` in a terminal. (A panel toggle is still the plan.)

## The engineering family
Each engineering needs different software, so each discipline is its own flavor. Only the one in use is built; the others are planned with software checked to exist in Fedora or Flathub (2026-10-23), to be built when someone who uses it can test it.

| Id | Name (ES) | For | Software |
| :-- | :-- | :-- | :-- |
| `computer-engineering` | Computer Engineering (Ingeniería en Computación) | Networks and hardware labs | GNS3 (dynamips, ubridge), Wireshark, minicom / picocom, TFTP, Nagios, SNMP, GTKWave, dfu-util, Octave; by hand: MATLAB, Cisco Packet Tracer |
| *planned* `electronic-engineering` | Electronics (Electrónica) | Circuits, PCBs, embedded | KiCad, ngspice, Qucs-S, PulseView / sigrok, Arduino IDE, PlatformIO, Icarus Verilog, GHDL, Yosys |
| *planned* `civil-engineering` | Civil (Civil) | Plans, maps, structures | QGIS, LibreCAD, FreeCAD |
| *planned* `industrial-engineering` | Industrial (Industrial) | Statistics, quality, processes | R, JASP, PSPP, Octave, LibreOffice Calc |
| *planned* `mechanical-engineering` | Mechanical (Mecánica) | Parts, assemblies, 3D printing | FreeCAD, OpenSCAD |

Programming toolchains (compilers, databases, containers) aren't engineering-specific: they belong to a future **Development** flavor that any of these can be combined with. FreeCAD and OpenSCAD stay in the base until a Civil or Mechanical flavor exists.

## What a flavor contains

```
flavors/<id>/
├── manifest.json     schema (format version, 1), id, family, name and description in each language, audioProfile
├── pkglist.txt       DNF packages            (same format as System/pkglist.txt)
├── flatpaks.txt      Flathub app ids         (same format as System/flatpaks.txt)
├── groups.txt        groups the user joins   (e.g. realtime; needs sudo)
├── permissions.txt   Flatpak overrides: "<app id> <override option>" per line
├── manual.txt        apps it can't install: "<name> | <command or path> | <where to get it>"
├── config/           files linked into ~/.config at the same path, one by one
└── app-settings/     settings merged into ~/.config/<same path>: only missing keys
```

Every file is optional. Lists allow `#` comments and blank lines.

| Part | Applied by the `install.sh` step | Notes |
| :-- | :-- | :-- |
| `pkglist.txt`, `flatpaks.txt` | `packages`, `flatpaks` | Added to the base lists |
| `config/` | `links` | File by file: a flavor adds `pipewire.conf.d/10-hires.conf`, it doesn't take `pipewire.conf.d/` over. Existing files are backed up, like every link |
| `groups.txt` | `flavors` | `usermod -aG` only for groups you aren't in; effective at the next login |
| `permissions.txt` | `flavors` | Each one is **asked first** (`--yes` grants them), and skipped if the app already has it |
| `manual.txt` | `flavors` | Licensed apps or ones behind an account (MATLAB, Packet Tracer): only checked; a missing one is a warning saying where to get it |
| `app-settings/` | `flavors` | `ini-fill.py`: copies only the keys your file lacks. Your own settings always win, and re-running changes nothing |

## Trust: why flavors are data, not scripts
The contract (what a flavor may contain, and that the future engine must be able to remove what it adds) is recorded as a design decision: *Flavors are declarative bundles, plugged and unplugged by one engine*. This folder is its proof of concept.

A flavor can install software, join groups and open folders to sandboxed apps, so what it does must be readable before it runs. That's why there is no `setup.sh` in a flavor: every effect has its own declarative file, shown or asked for by `install.sh`. Only official repositories and Flathub; permissions listed one per line. (The same split as the lagOS design: styles are data, flavors install packages, widgets run code.)

## Adding a flavor
1. `mkdir flavors/<id>` and write `manifest.json` (copy one: `id`, `family`, `name.en/es`, `description.en/es`).
2. Move the packages / Flatpaks from `System/` into the flavor's lists if only that work needs them.
3. Move its configs from `config/` into `flavors/<id>/config/` (with `git mv`, and fix any comment that names the old path), and drop their lines from `LINKS` in `install.sh`.
4. App settings: copy the keys you want from your app's INI file into `app-settings/<path under ~/.config>`. Never paths with your user name, tokens or accounts (this repo is public).
5. `./install.sh --dry-run --only packages,flatpaks,links,flavors --flavors <id>` to see what it would do.

## Not yet
- **Services** (`services.txt`): no flavor needs its own yet; mpDris2 is base.
- **Panel settings** per flavor (e.g. the Audiophile opening the Media tab on the Library).
- **Mixxx's recordings folder**: its setting lives inside the Flatpak sandbox (`~/.var/app/org.mixxx.Mixxx/.mixxx/mixxx.cfg`) as an absolute path, so the DJ flavor grants the folder and you choose it once in Preferences → Recording.
- **Choosing flavors from the panel** (Settings → Flavors) instead of `--flavors`.
