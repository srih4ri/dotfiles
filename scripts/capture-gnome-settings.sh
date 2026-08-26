#!/bin/sh
# Re-export the GNOME settings tracked in this repo from the current machine.
# Run this after tweaking GNOME, then review `git diff` and commit.
set -e

dir="$(cd "$(dirname "$0")/.." && pwd)/home/.dconf/gnome"
mkdir -p "$dir"

dconf dump /org/gnome/desktop/wm/ > "$dir/desktop-wm.ini"
dconf dump /org/gnome/desktop/interface/ > "$dir/desktop-interface.ini"
dconf dump /org/gnome/desktop/peripherals/ > "$dir/desktop-peripherals.ini"
dconf dump /org/gnome/desktop/input-sources/ > "$dir/desktop-input-sources.ini"
dconf dump /org/gnome/settings-daemon/plugins/media-keys/ > "$dir/media-keys.ini"
dconf dump /org/gnome/mutter/ > "$dir/mutter.ini"
dconf dump /org/gnome/shell/keybindings/ > "$dir/shell-keybindings.ini"
dconf dump /org/gnome/shell/extensions/ > "$dir/shell-extensions.ini"
printf '[/]\nenabled-extensions=%s\n' "$(dconf read /org/gnome/shell/enabled-extensions)" > "$dir/shell-enabled-extensions.ini"

echo "GNOME settings captured to $dir"
