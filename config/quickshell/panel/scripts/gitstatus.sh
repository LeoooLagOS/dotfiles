#!/usr/bin/env bash
# The git status of the directory a terminal window is in (bar/WindowTitle.qml).
#   gitstatus.sh <terminal pid>
# Of the terminal's shells (one per tab or split), the one typed in last (its
# tty's access time); its foreground program's directory, else the shell's. Prints one line,
# tab-separated, or nothing outside a repository:
#   repo  branch  ahead  behind  staged  modified  untracked  conflicts
pid=$1
[ -n "$pid" ] || exit 0
best=""; bestfg=""; latest=-1
for c in $(pgrep -P "$pid"); do
  case "$(cat /proc/$c/comm 2>/dev/null)" in
    zsh|bash|fish|sh|nu|dash) ;;
    *) continue ;;
  esac
  tty=$(readlink "/proc/$c/fd/0" 2>/dev/null)
  typed=$(stat -c %X "$tty" 2>/dev/null) || typed=0
  if [ "$typed" -gt "$latest" ]; then
    latest=$typed; best=$c
    bestfg=$(awk '{print $8}' "/proc/$c/stat" 2>/dev/null)
    [ -n "$bestfg" ] && [ "$bestfg" -gt 0 ] || bestfg=$c
  fi
done
[ -n "$best" ] || exit 0
dir=$(readlink "/proc/$bestfg/cwd" 2>/dev/null) || dir=""
[ -d "$dir" ] || dir=$(readlink "/proc/$best/cwd" 2>/dev/null)
[ -d "$dir" ] || exit 0

out=$(GIT_OPTIONAL_LOCKS=0 timeout 2 git -C "$dir" status --porcelain=v2 --branch 2>/dev/null) || exit 0
top=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null)
awk -v repo="${top##*/}" '
  /^# branch.head / { head = $3 }
  /^# branch.oid /  { oid = substr($3, 1, 7) }
  /^# branch.ab /   { ahead = substr($3, 2); behind = substr($4, 2) }
  /^[12] / { x = substr($2, 1, 1); y = substr($2, 2, 1); if (x != ".") s++; if (y != ".") m++ }
  /^u /    { u++ }
  /^\? /   { n++ }
  END {
    if (head == "(detached)") head = oid
    printf "%s\t%s\t%d\t%d\t%d\t%d\t%d\t%d\n", repo, head, ahead, behind, s, m, n, u
  }' <<<"$out"
