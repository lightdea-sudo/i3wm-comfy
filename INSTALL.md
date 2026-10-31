# Installation

i3wm-comfy is a small, calm i3 setup for **Arch Linux (X11)**: a teal palette, a compact `i3blocks` bar, Alt as the main key, and a few helper scripts (screenshot, projector, tint).

## Prerequisites

- Arch Linux or an Arch-based distro, with `pacman`
- A working **X11** session (a login manager such as Ly, or `startx`). Wayland is not supported
- A normal user with `sudo`
- A laptop is assumed: the bar shows battery and brightness. On a desktop PC those two blocks will show nothing, which is harmless
- An internet connection during install

## Quick install

```sh
git clone https://github.com/lightdea-sudo/i3wm-comfy.git
cd i3wm-comfy
chmod +x install.sh
./install.sh
```

The script installs the packages below, backs up anything it would overwrite into `~/.i3wm-comfy-backup-<date>`, copies the dotfiles, expands `~` in the fastfetch config, and checks the i3 config.

To copy the dotfiles only (skip `pacman`):

```sh
./install.sh --no-packages
```

After it finishes, make sure NetworkManager is running, then log out and choose the **i3** session at the login screen:

```sh
sudo systemctl enable --now NetworkManager
```

## Packages

| Package | Used for |
| --- | --- |
| `i3-wm`, `dex` | window manager and autostart |
| `i3blocks` | status bar blocks |
| `dmenu` | app launcher (`Alt+d`) |
| `i3lock`, `xss-lock` | lock screen and auto lock |
| `alacritty` | terminal |
| `ttf-jetbrains-mono-nerd`, `inter-font` | terminal font, interface font |
| `fastfetch` | banner when a terminal opens |
| `xorg-xrandr`, `xorg-xset`, `xorg-setxkbmap` | projector, screen sleep, keyboard layout |
| `feh` | wallpaper |
| `redshift` | green screen tint |
| `maim`, `slop`, `xclip` | screenshots |
| `brightnessctl`, `acpi` | brightness and battery blocks |
| `libpulse`, `pipewire`, `pipewire-pulse`, `wireplumber` | volume (`pactl`) and audio |
| `networkmanager`, `network-manager-applet` | wifi and the tray icon |
| `libnotify` | notification from the projector script |
| `unzip` | reading `i3wm-comfy.zip` |

## What gets installed

```
~/.config/i3/config
~/.config/i3blocks/        battery, brightness, tint, volume, ipv6, netspeed
~/.config/alacritty/alacritty.toml
~/.config/fastfetch/       config.jsonc, logo.txt
~/.config/redshift/redshift.conf
~/.local/bin/ss            screenshot helper
~/.local/bin/proyektor     projector helper (mirror / extend / off)
~/.bashrc                  prompt, fastfetch on terminal start
~/Pictures/wallpapers/blue.png
```

## Keybindings

`Alt` is the main key (`$mod = Mod1`). Everything not listed here is stock i3.

| Keys | Action |
| --- | --- |
| `Alt+Enter` | terminal |
| `Alt+d` | app launcher |
| `Alt+q` or `Alt+Shift+q` | close window |
| `Alt+Shift+x` | lock screen |
| `Alt+p` / `Alt+Shift+p` / `Alt+Ctrl+p` | projector: mirror / extend / laptop only |
| `Print` / `Shift+Print` / `Ctrl+Print` | screenshot: full / area / area to clipboard only |
| `Alt+Shift+f` / `Alt+Shift+s` / `Alt+Ctrl+s` | same three screenshots, for keyboards without a Print key |
| volume and brightness keys | change volume and brightness, bar updates |

Screenshots are saved to `~/Pictures/Screenshots`.

## Bar

From left to right: IPv6 address, download speed (mbps), tint on/off (click to toggle), battery, brightness (scroll), volume (scroll, click to mute), memory, clock, and the network tray icon.

## Customize

- **Wallpaper:** replace `~/Pictures/wallpapers/blue.png`, or edit the `feh` line in the i3 config.
- **Tint strength:** the `gamma` value `0.81:1.0:0.81` appears in `~/.config/i3/config` and `~/.config/i3blocks/tint`. Closer to `1.0` is subtler.
- **Redshift:** day and night temperature are equal, so the tint is constant and the location is not used (`lat`/`lon` are `0.0`). If you set different `temp-night` and `temp-day` values, put your own coordinates there.
- **Main key:** change `set $mod Mod1` in the i3 config (`Mod4` is the Win key).

## Troubleshooting

- **Alt shortcuts do nothing, but Win works:** some keyboards have a Mac/Win switch that swaps the two keys. Set it to Win mode. Check what the key sends with `xev -event keyboard | grep keysym`.
- **Check the config before reloading:** `i3 -C -c ~/.config/i3/config` prints nothing when it is valid.
- **Volume block is empty:** the audio server is not running. Run `systemctl --user enable --now pipewire pipewire-pulse wireplumber`, then `i3-msg restart`.
- **Brightness keys do nothing:** you must be in the `video` group (the installer adds you). Log out and in again.
- **No network icon in the tray:** run `nm-applet &`, and check that `tray_output primary` is inside the `bar {}` block.
- **Stuck without a terminal:** switch to a text console with `Ctrl+Alt+F2`, log in, fix `~/.config/i3/config`, then run `DISPLAY=:0 i3-msg restart` or reboot.

## Restore the old files

The installer moves existing files to `~/.i3wm-comfy-backup-<date>`. Copy them back from there to undo.
