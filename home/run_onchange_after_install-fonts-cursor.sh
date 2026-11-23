#!/bin/bash
# Install the Bauhaus desktop's fonts and cursor into ~/.local/share:
#   - Atkinson Hyperlegible Next (interface/documents) and Mono (terminal),
#     variable TTFs, OFL, from google/fonts
#   - Bibata-Modern-Classic cursor (black), GPL-3.0, from its GitHub release
# Pinned and checksummed; skips anything already installed. Needs curl, tar.
# Re-runs when this file changes (run_onchange).

set -euo pipefail

FONTS_REV=06bfe0d62a98375cb09c942fa18e68bd32cff057   # google/fonts
BIBATA_TAG=v2.0.7

FONT_DIR="$HOME/.local/share/fonts"
ICON_DIR="$HOME/.local/share/icons"

fetch() {  # url dest sha256
    local tmp
    tmp=$(mktemp)
    curl -fsSL "$1" -o "$tmp"
    if ! echo "$3  $tmp" | sha256sum -c --quiet -; then
        echo "checksum mismatch for $1" >&2
        rm -f "$tmp"
        return 1
    fi
    mv "$tmp" "$2"
}

font() {  # family-dir file sha256
    local dir="$FONT_DIR/$1" lower
    lower=$(echo "$1" | tr '[:upper:]' '[:lower:]')
    [ -f "$dir/$2" ] && return 0
    mkdir -p "$dir"
    # URL-encode the brackets in "[wght]"
    fetch "https://raw.githubusercontent.com/google/fonts/$FONTS_REV/ofl/$lower/$(echo "$2" | sed 's/\[/%5B/; s/\]/%5D/')" \
        "$dir/$2" "$3"
    changed=1
}

changed=0
font AtkinsonHyperlegibleNext 'AtkinsonHyperlegibleNext[wght].ttf'        5a455d1cfa099b601ab70751bb9673e8fe1854dc4500c80e1a220d0d75e31745
font AtkinsonHyperlegibleNext 'AtkinsonHyperlegibleNext-Italic[wght].ttf' ce9cffed32742ad2d9238c561a93220385e5934cdc02b8eb4097a50efa957dc6
font AtkinsonHyperlegibleMono 'AtkinsonHyperlegibleMono[wght].ttf'        5ce8b1698d1ded7dff2178c1a3ad159470085a58ea239e8b2cb88f4fb4a6f646
font AtkinsonHyperlegibleMono 'AtkinsonHyperlegibleMono-Italic[wght].ttf' e18f523877530e4abe229df6a36d394326254da488a7f5abb9b7b5ea8f780cd4
if [ "$changed" = 1 ] && command -v fc-cache >/dev/null 2>&1; then
    fc-cache -f "$FONT_DIR"
fi

if [ ! -d "$ICON_DIR/Bibata-Modern-Classic" ]; then
    mkdir -p "$ICON_DIR"
    tarball=$(mktemp)
    fetch "https://github.com/ful1e5/Bibata_Cursor/releases/download/$BIBATA_TAG/Bibata-Modern-Classic.tar.xz" \
        "$tarball" 7d3495864e5bbef02f5e77de760b2905903b63c71495a78ef6306d19a3b556d8
    tar -xJf "$tarball" -C "$ICON_DIR" Bibata-Modern-Classic
    rm -f "$tarball"
fi
