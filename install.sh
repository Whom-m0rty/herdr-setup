#!/bin/sh
# Link bin/* into ~/bin and install the herdr config. Safe to re-run.
#   ./install.sh            links + config (an existing config.toml is backed up first)
#   ./install.sh --no-config  links only
set -e
here=$(cd "$(dirname "$0")" && pwd)
mkdir -p "$HOME/bin"
for f in "$here"/bin/*; do
  [ -f "$f" ] || continue
  name=$(basename "$f")
  target="$HOME/bin/$name"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "skip $name: $target exists and is not a link (move it away to use this one)"
    continue
  fi
  ln -sf "$f" "$target"
  echo "linked ~/bin/$name"
done
case ":$PATH:" in *":$HOME/bin:"*) ;; *) echo "note: add ~/bin to PATH in your shell profile";; esac
if [ "$1" != "--no-config" ]; then
  conf="$HOME/.config/herdr/config.toml"
  mkdir -p "$(dirname "$conf")"
  if [ -f "$conf" ] && ! cmp -s "$conf" "$here/config/herdr/config.toml"; then
    cp "$conf" "$conf.backup-$(date +%Y%m%d-%H%M%S)"
    echo "backed up your config.toml"
  fi
  cp "$here/config/herdr/config.toml" "$conf"
  echo "installed $conf (run: herdr server reload-config)"
fi
[ -f "$HOME/todo.md" ] || echo "next: create ~/todo.md (see examples/todo.md)"
