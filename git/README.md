# 🔏 git/ — Global Git Provenance

Global Git configuration plus the GPG agent settings that make signed commits practical. This README also covers the top-level `gpg/` directory.

| Source | Linked to |
|---|---|
| `git/.gitconfig` | `~/.gitconfig` |
| `gpg/gpg-agent.conf` | `~/.gnupg/gpg-agent.conf` |

## Git (`.gitconfig`)

- **Cryptographic identity:** every commit is GPG-signed (`commit.gpgsign = true`) with key `0D06886B74ED962C`, so commits show as verified on the remote.
- **Delta pager:** `delta` renders `git diff`, `log`, `show` and interactive staging with syntax highlighting; `n`/`N` jump between files.
- **zdiff3 conflicts:** conflict markers include the common ancestor, giving the baseline for each side.
- **Defaults:** `main` as the initial branch, upstream set automatically on first push, credentials cached for one hour.

## GPG agent (`gpg/gpg-agent.conf`)

- Caches the passphrase for 12 hours, so signing doesn't prompt on every commit.
- Uses `pinentry-qt` for a graphical passphrase prompt under Hyprland.

If signing fails with an agent or TTY error (for example after switching from a TTY to Hyprland), run `gpg-refresh`, defined in [`zsh/conf.d/20-security.zsh`](../zsh/README.md).

## Verification

```bash
git config --get user.signingkey   # 0D06886B74ED962C
git log --show-signature -1        # "Good signature from ..."
```
