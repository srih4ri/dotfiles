#!/usr/bin/env bash
# Derive ~/.themes/Gruvbox-Orange-Daylight from the built Gruvbox-Orange-Light
# (see run_once_after_install-gruvbox-themes.sh). It is the high-contrast light
# theme for bright, glare-heavy rooms and matches alacritty/gruvbox-daylight.toml.
# The theme's colours are inlined as literals rather than @define-color names,
# so they are rewritten with sed. Bump the version below to rebuild.
# version: 4
set -euo pipefail

src="$HOME/.themes/Gruvbox-Orange-Light"
dst="$HOME/.themes/Gruvbox-Orange-Daylight"
if [[ ! -d $src ]]; then
  echo "tune-gruvbox-daylight: $src missing, skipping" >&2
  exit 0
fi

tmp=$(mktemp -d "$HOME/.themes/.daylight.XXXXXX")
cp -a "$src/." "$tmp/"

# Background near-white; text opaque; secondary text and borders darker;
# accent orange -> blue (#1a4fa8; a protan sees the orange as olive);
# error/warning/success use the protan-tuned Daylight hues.
sed -i -E \
  -e 's/#fbf1c7/#fffcf2/gI' \
  -e 's/#ebdbb2/#f3ead2/gI' \
  -e 's/rgba\(29, 32, 33, 0\.87\)/#1d2021/g' \
  -e 's/rgba\(29, 32, 33, 0\.6\)/rgba(29, 32, 33, 0.78)/g' \
  -e 's/rgba\(29, 32, 33, 0\.38\)/rgba(29, 32, 33, 0.5)/g' \
  -e 's/rgba\(29, 32, 33, 0\.12\)/rgba(29, 32, 33, 0.22)/g' \
  -e 's/#c35e0a/#1a4fa8/gI' \
  -e 's/rgba\(195, 94, 10,/rgba(26, 79, 168,/g' \
  -e 's/#ea6962/#7c100e/gI' \
  -e 's/#d8a657/#866001/gI' \
  -e 's/#a9b665/#176e3f/gI' \
  "$tmp"/gtk-3.0/gtk.css "$tmp"/gtk-4.0/gtk.css "$tmp"/gnome-shell/gnome-shell.css

# Top bar: Light's bar is cream at 45% opacity, which rendered black in practice
# (2026-11-05; an opaque !important value fixed it). Make it solid Daylight bg.
sed -i -E '/^#panel \{/,/^\}/ s/background-color: rgba\(251, 241, 199, 0\.45\);/background-color: #fffcf2 !important;/' \
  "$tmp"/gnome-shell/gnome-shell.css

# Accent-coloured SVG assets (shell toggles/checkboxes, GTK scalable assets).
grep -rlI --include='*.svg' -i 'c35e0a' "$tmp" | xargs -r sed -i 's/#c35e0a/#1a4fa8/gI'

sed -i 's/Gruvbox-Orange-Light/Gruvbox-Orange-Daylight/g' "$tmp/index.theme"

rm -rf "$dst"
mv "$tmp" "$dst"
echo "tune-gruvbox-daylight: built $dst"
