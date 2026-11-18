# dotfiles

My Linux (GNOME) dotfiles, managed with [chezmoi](https://www.chezmoi.io/).

## What's tracked

- **fish** — config, aliases, prompt, portable conf.d snippets and functions
- **git** — config (identity templated per machine) and global ignore
- **tmux** — config + cheatsheet popup
- **Doom Emacs** — config.el / init.el / packages.el / custom.el
- **Terminals** — Alacritty and Kitty use JetBrains Mono Medium at 11.5 pt with extra line spacing and follow the light/dark palette
- **Appearance switching** — the `gruvbox-theme-sync` user service follows GNOME Dark Style and selects the Bauhaus GTK, Shell and Alacritty themes, Gruvbox icons and the matching Claude Code theme.
- **Bauhaus desktop** — light/dark GNOME Shell, Alacritty, Kitty and Zellij palettes, flat tabs, cobalt focus and a 2880 × 1920 light wallpaper. The panel and headings use URW Gothic. Inter is the interface and document face. Rehear transcripts use 12 pt Inter with 1.45 line height. Quick Settings uses cobalt enabled tiles and native GNOME corner shapes. GTK3 and GTK4 share the shell palette, ruled headers and cobalt selections over GTK’s built-in widget styles.
- **Codex CLI** — the chezmoi modifier sets the ANSI syntax theme with `uv` and `tomlkit`, preserving the rest of the local config.
- **mise, htop, k9s** — tool configs
- **GNOME** — keybindings, interface/theme, input sources, extension settings,
  captured as dconf dumps in `home/.dconf/gnome/` and loaded automatically by a
  `run_onchange` script on `chezmoi apply`

Secrets are **not** tracked. User-level secrets live in `~/.env`, which
`fish/conf.d/user-env.fish` loads into every shell.

## New machine

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
chezmoi init --apply git@github.com:srih4ri/dotfiles.git
```

`chezmoi init` prompts once for git name/email/GPG key (stored locally in
`~/.config/chezmoi/chezmoi.toml`, never committed).

## Day-to-day

```sh
chezmoi diff        # what would change on this machine
chezmoi apply       # apply repo state to this machine
chezmoi re-add      # pull local edits of tracked files back into the repo
chezmoi add <file>  # start tracking a new file
```

After tweaking GNOME settings, re-export them with:

```sh
./scripts/capture-gnome-settings.sh
```

then review `git diff` and commit.

## Layout

- `home/` — chezmoi source state (`.chezmoiroot` points here)
- `home/.dconf/gnome/` — GNOME dconf dumps (not files in `$HOME`; loaded via dconf)
- `scripts/` — helper scripts

The old macOS-era setup (Brewfile, `setup.rb`) lives in git history before the
chezmoi migration.
