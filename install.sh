#!/usr/bin/env bash
# i3wm-comfy installer (Arch Linux)
#
# usage:
#   ./install.sh                  install packages + dotfiles
#   ./install.sh --no-packages    only copy dotfiles (skip pacman)
#
# the dotfiles are read from this folder: either an extracted tree
# (.config/, .local/, .bashrc, Pictures/) or the i3wm-comfy.zip next to this script.
# anything that already exists is moved to ~/.i3wm-comfy-backup-<date> first.

set -euo pipefail

SRC="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP="$HOME/.i3wm-comfy-backup-$STAMP"
INSTALL_PKGS=1
[ "${1:-}" = "--no-packages" ] && INSTALL_PKGS=0

say()  { printf '\033[1;36m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

[ "$(id -u)" -eq 0 ] && die "run as a normal user, not root (sudo is asked for when needed)"
command -v pacman >/dev/null || die "this installer is for Arch Linux (pacman not found)"

# ---------------------------------------------------------------- packages
PKGS=(
  # window manager + bar + launcher + lock
  i3-wm i3blocks dmenu i3lock xss-lock dex
  # terminal, fonts, prompt banner
  alacritty ttf-jetbrains-mono-nerd inter-font fastfetch
  # x11 tools used by the config and scripts
  xorg-xrandr xorg-xset xorg-setxkbmap feh redshift
  # screenshots
  maim slop xclip
  # hardware keys + bar blocks
  brightnessctl acpi libpulse libnotify
  # audio + network
  pipewire pipewire-pulse wireplumber networkmanager network-manager-applet
  # misc
  unzip
)

if [ "$INSTALL_PKGS" -eq 1 ]; then
  say "installing packages (pacman)"
  sudo pacman -S --needed "${PKGS[@]}"
else
  say "skipping packages (--no-packages)"
fi

# ---------------------------------------------------------------- payload
if [ -d "$SRC/.config" ]; then
  PAYLOAD="$SRC"
elif [ -f "$SRC/i3wm-comfy.zip" ]; then
  say "extracting i3wm-comfy.zip"
  PAYLOAD="$(mktemp -d)"
  trap 'rm -rf "$PAYLOAD"' EXIT
  unzip -q "$SRC/i3wm-comfy.zip" -d "$PAYLOAD"
else
  die "nothing to install: expected .config/ or i3wm-comfy.zip next to install.sh"
fi

# ---------------------------------------------------------------- backup + copy
ITEMS=(
  .config/i3
  .config/i3blocks
  .config/alacritty
  .config/fastfetch
  .config/redshift
  .local/bin/ss
  .local/bin/proyektor
  .bashrc
  Pictures/wallpapers/blue.png
)

say "backing up existing files to $BACKUP"
for item in "${ITEMS[@]}"; do
  if [ -e "$HOME/$item" ]; then
    mkdir -p "$BACKUP/$(dirname "$item")"
    mv "$HOME/$item" "$BACKUP/$item"
  fi
done

say "copying dotfiles"
for item in "${ITEMS[@]}"; do
  if [ -e "$PAYLOAD/$item" ]; then
    mkdir -p "$HOME/$(dirname "$item")"
    cp -r "$PAYLOAD/$item" "$HOME/$item"
  else
    warn "missing in payload: $item"
  fi
done

# old snapshots that may have been shipped by mistake
rm -f "$HOME"/.config/i3/config.sebelum-* "$HOME"/.config/i3/config.lama "$HOME"/.config/i3/config.baru

# ---------------------------------------------------------------- fixups
say "fixing paths and permissions"
# fastfetch needs an absolute path for the logo, so expand the leading ~
sed -i "s|\"~/|\"$HOME/|g" "$HOME/.config/fastfetch/config.jsonc"

chmod +x "$HOME"/.local/bin/ss "$HOME"/.local/bin/proyektor
for f in battery brightness tint volume ipv6 netspeed; do
  [ -f "$HOME/.config/i3blocks/$f" ] && chmod +x "$HOME/.config/i3blocks/$f"
done

mkdir -p "$HOME/.cache" "$HOME/Pictures/Screenshots"

# brightnessctl needs the video group on most setups
if ! id -nG "$USER" | tr ' ' '\n' | grep -qx video; then
  say "adding $USER to the video group (log out and in again to apply)"
  sudo usermod -aG video "$USER"
fi

# audio session services (ignored when not inside a user session)
systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null || true

# ---------------------------------------------------------------- check
if command -v i3 >/dev/null; then
  if i3 -C -c "$HOME/.config/i3/config" >/dev/null 2>&1; then
    say "i3 config is valid"
  else
    warn "i3 reports a problem, run: i3 -C -c ~/.config/i3/config"
  fi
fi

cat <<EOF

done.

next:
  - make sure NetworkManager is running:  sudo systemctl enable --now NetworkManager
  - log out, pick the "i3" session in your login manager, and log in
  - main key is Alt (Mod1). if your keyboard has a Mac/Win switch, set it to Win
  - your old files are in: $BACKUP
EOF
