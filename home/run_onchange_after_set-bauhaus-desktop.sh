#!/bin/sh
set -eu
gsettings set org.gnome.desktop.interface accent-color blue
gsettings set org.gnome.desktop.interface font-name 'Atkinson Hyperlegible Next 11'
gsettings set org.gnome.desktop.interface document-font-name 'Atkinson Hyperlegible Next 12'
gsettings set org.gnome.desktop.interface monospace-font-name 'Atkinson Hyperlegible Mono Medium 12'
gsettings set org.gnome.desktop.wm.preferences titlebar-font 'Atkinson Hyperlegible Next Semi-Bold 11'
wallpaper_uri=$(python3 -c 'from pathlib import Path; print((Path.home() / ".local/share/backgrounds/bauhaus-study.svg").as_uri())')
gsettings set org.gnome.desktop.background picture-uri "$wallpaper_uri"
