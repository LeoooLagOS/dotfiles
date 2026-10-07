# 📦 System/ — Declarative Provisioning

Infrastructure-as-Code lists that describe the workstation's packages. `install.sh` reads them; nothing here is linked into `$HOME`.

| File | Format | Consumed by |
|---|---|---|
| `pkglist.txt` | One DNF package per line (~490) | `packages` step |
| `coprs.txt` | One COPR `owner/project` per line; `#` comments allowed | `repos` step, before packages |
| `flatpaks.txt` | One Flathub app ID per line | `flatpaks` step |

## Filtering

The `packages` step skips entries that don't belong on a fresh host:

- live-ISO tooling (`anaconda*`, `dracut-live`, `livesys-scripts`) and kernel-pinned `kmod-nvidia-*` builds;
- NVIDIA drivers (`akmod-nvidia`, `nvidia-*`, `xorg-x11-drv-nvidia*`) when `lspci` finds no NVIDIA GPU.

## Updating the lists

Add or remove lines by hand. `pkglist.txt` is kept in byte order (`LC_ALL=C sort`), so capitalized names come first. When adding a package from a COPR, add the COPR to `coprs.txt` in the same commit so a fresh install can resolve it. Preview the effect with:

```bash
./install.sh --dry-run --only repos,packages,flatpaks
```

## `etc/` — system config

Files under `etc/` mirror their path under `/etc`. `install.sh` doesn't deploy them; copy them by hand:

```bash
sudo cp System/etc/udev/rules.d/90-usb-input-wakeup.rules /etc/udev/rules.d/
sudo udevadm control --reload && sudo udevadm trigger --subsystem-match=usb --action=add
sudo install -Dm644 System/etc/systemd/logind.conf.d/10-lid.conf /etc/systemd/logind.conf.d/10-lid.conf
sudo systemctl kill -s HUP systemd-logind
```

| File | Purpose |
|---|---|
| `udev/rules.d/90-usb-input-wakeup.rules` | Lets the USB keyboard/mouse wake from suspend and keeps them connected across resume |
| `systemd/logind.conf.d/10-lid.conf` | Don't suspend on lid close while on AC (clamshell with external monitor) |
