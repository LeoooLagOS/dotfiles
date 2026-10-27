# Contributing

Thanks for wanting to help. This is a one-maintainer project in beta, so a
short issue before a big change saves both of us time.

## Reporting a bug

Open an issue with:

- the panel version (Settings → About) and `hyprctl version`
- what you did, what you expected, what happened
- the log: `qs log -c panel`
- a screenshot if it's visual

## Running it while you work

```sh
qs -c panel          # Quickshell reloads live when a .qml file is saved
qs log -c panel      # warnings and errors
qs -c panel ipc call panel toggle    # drive it without the keyboard
```

If it runs as the user service, restart it with
`systemctl --user restart quickshell-panel`.

## Where things go

| Folder | What lives there |
| :-- | :-- |
| `services/` | state and data (singletons): no drawing |
| `zones/` | the side panel's blocks, placed per tab |
| `bar/` | the top bar's islands and popups |
| `common/` | shared pieces: `Theme`, `Settings`, `Config`, `Tr` |
| `scripts/` | helpers the QML calls (Python, shell) |
| `i18n/` | translations |
| `docs/REFERENCE.md` | how every feature works. **Update it with your change** |

## The rules

These are the decisions that keep the panel coherent. A change that breaks
one needs a discussion first.

1. **Usable without a terminal.** Every feature can be reached and set by
   mouse from Settings. No message tells a user to run a command.
2. **Hyprland only behind one boundary.** New code doesn't call `Hyprland.*`
   or `hyprctl` directly. It goes through the window-manager service (being
   built; until then, keep such calls in `services/`, not in zones or bar
   islands).
3. **Data is separate from presentation.** Services hold the data; zones and
   islands only draw it.
4. **No text glued around values.** Use `Tr.t("Due %1: %2", when, what)` and
   `Tr.n(count, "%1 message", "%1 messages")`. Word order changes between
   languages. Add every new string to `i18n/es.json` (or say that it's
   missing).
5. **Settings are never lost.** Renaming or moving a setting means migrating
   the old key on first read.
6. **No personal data in the tree.** Paths, accounts and private providers go
   in `~/.config/lagos/`, never in the code.
7. **Look before you claim it works.** For layout changes, check a screenshot
   (`grim`) on more than one screen size. Bar changes must keep both halves
   mirrored.

## Commits

[Conventional Commits](https://www.conventionalcommits.org), with the area as
the scope, written as what the user gets:

```
feat(media): open the player's app from its chip, art or title
fix(comms): open apps whose id ends in .desktop (Telegram)
```

Types: `feat`, `fix`, `docs`, `refactor`, `perf`, `chore`. One idea per
commit.

## Which version a change implies

Say it in your pull request:

| Your change… | Bump |
| :-- | :-- |
| fixes a bug, nothing else visible | PATCH |
| adds something, or changes what users see by default; old settings migrate | MINOR |
| makes users, styles, flavors or providers change something by hand: a setting that can't be migrated, an IPC command removed, a higher Hyprland/Quickshell with no fallback | MAJOR |

Before 1.0 a MINOR may break things, but it must be listed under
**⚠️ Breaking** in `CHANGELOG.md`, with what to do.

## Translations

Copy `i18n/es.json` to `i18n/<lang>.json`, translate the values (keep the
keys and the `%1` placeholders), then add the language to `Tr.languages` and
to the Language row in Settings. See
[Language](docs/REFERENCE.md#language).
