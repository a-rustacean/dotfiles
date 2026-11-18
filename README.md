# dotfiles

Personal Linux desktop configuration built around Hyprland (configured in
Lua), a Quickshell/QML status bar and launcher, Alacritty, Helix, gitui and
opencode. The repository is the source of truth: `links.json` and `link.py`
symlink each tracked directory or file into the locations where the programs
expect them, so editing a file here edits the live configuration.

<!-- screenshot -->

## Dependencies

- hyprland
- hyprpaper
- hyprlock
- hypridle
- hyprsunset
- hyprpicker
- hyprshutdown
- hyprpolkitagent
- xdg-desktop-portal-hyprland
- dunst
- cliphist
- wl-clipboard
- quickshell
- qml-language-server
- alacritty
- gitui
- helix
- opencode
- JetBrains Mono Nerd Font
- bluez
- NetworkManager
- pipewire and wireplumber
- playerctl
- brightnessctl
- gnupg and a pinentry program

`link.py` needs Python 3 (standard library only).

## Install

Clone the repository, preview the symlinks, then create them:

```sh
git clone <repository-url> ~/dotfiles
cd ~/dotfiles
./link.py -n
./link.py
```

Existing destinations are skipped by default. Pass `--backup` to rename an
existing destination to `<name>.bak` before linking, and `--force` to replace
existing files or symlinks. Directories are never deleted.

## Git identity

The tracked `.gitconfig` contains shared defaults and includes
`~/.gitconfig.local` for personal information. Copy `gitconfig.local.example`
to `~/.gitconfig.local` and adjust your name, email, and signing key:

```sh
cp gitconfig.local.example ~/.gitconfig.local
```

The local file is intentionally untracked and is not managed by `link.py`.

## Layout

`links.json` maps each path in this repository to its destination on the
system. Keys are relative to the repository root; values may use `~` and
environment variables. For example, `"hypr": "~/.config/hypr"` links this
repository's `hypr/` directory to `~/.config/hypr`. `link.py` reads the mapping
from the `links.json` next to the script, so it can be run from any directory.

## Status

This repository is a work in progress. Expect pieces to move or change without
notice.
