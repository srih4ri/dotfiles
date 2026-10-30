#!/bin/bash
# Build and install the Gruvbox-Orange GTK/shell themes (light + dark) and
# Gruvbox icons from upstream, then enable gruvbox-theme-sync.
# Skips anything already installed. Needs git and sassc.
#
# Pinned upstream: https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme
# Shell theme gets every border-radius zeroed (sharp corners).

set -euo pipefail

REPO=https://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme.git
REV=578cd220b5ff6e86b078a6111d26bb20ec8c733f
THEMES="$HOME/.themes"
ICONS="$HOME/.local/share/icons"

need_build=0
for v in Dark Light; do
    [ -d "$THEMES/Gruvbox-Orange-$v" ] && [ -d "$ICONS/Gruvbox-$v" ] || need_build=1
done

if [ "$need_build" = 1 ]; then
    if ! command -v sassc >/dev/null 2>&1; then
        echo "sassc not found; skipping Gruvbox theme build (install sassc, then re-run with: chezmoi state delete-bucket --bucket=scriptState && chezmoi apply)" >&2
        exit 0
    fi
    src=$(mktemp -d)
    trap 'rm -rf "$src"' EXIT
    git -C "$src" init -q
    git -C "$src" fetch -q --depth 1 "$REPO" "$REV"
    git -C "$src" checkout -q FETCH_HEAD

    mkdir -p "$THEMES" "$ICONS"
    for v in Dark Light; do
        if [ ! -d "$THEMES/Gruvbox-Orange-$v" ]; then
            (cd "$src/themes" && ./install.sh -d "$THEMES" -t orange -c "${v,,}")
            sed -i -E 's/border-radius:[^;]*;/border-radius: 0;/g' \
                "$THEMES/Gruvbox-Orange-$v/gnome-shell/gnome-shell.css"
        fi
        if [ ! -d "$ICONS/Gruvbox-$v" ]; then
            cp -r "$src/icons/Gruvbox-$v" "$ICONS/"
            gtk-update-icon-cache -f -t "$ICONS/Gruvbox-$v" >/dev/null 2>&1 || true
        fi
    done
fi

if command -v systemctl >/dev/null 2>&1 && systemctl --user show-environment >/dev/null 2>&1; then
    systemctl --user daemon-reload
    systemctl --user enable --now gruvbox-theme-sync.service
else
    "$HOME/.local/bin/gruvbox-theme-sync" --once || true
fi
