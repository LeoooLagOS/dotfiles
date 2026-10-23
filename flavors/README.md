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

(A panel toggle for this, "listening / producing", is the plan: the profile becomes a mode you switch, not a choice at install time.)

## What a flavor contains

```
flavors/<id>/
├── manifest.json     id, family, name and description in each language, audioProfile
├── pkglist.txt       DNF packages            (same format as System/pkglist.txt)
├── flatpaks.txt      Flathub app ids         (same format as System/flatpaks.txt)
├── groups.txt        groups the user joins   (e.g. realtime; needs sudo)
├── permissions.txt   Flatpak overrides: "<app id> <override option>" per line
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
| `app-settings/` | `flavors` | `ini-fill.py`: copies only the keys your file lacks. Your own settings always win, and re-running changes nothing |

## Trust: why flavors are data, not scripts
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
