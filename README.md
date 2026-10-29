# 📁 Arch Linux Dotfiles

This repository contains my personal Arch Linux configuration files (`dotfiles`) and manuals. The goal is to allow me to quickly replicate my workflow and environment on any machine. Feel free to copy them or use them as inspiration!

---

## 🧭 Variants

The repository has two installers, one per desktop:

| Variant | Folder | What it is |
|---------|--------|------------|
| Hyprland | `my-setup-hyprland/` | Full desktop: Hyprland, UWSM, greetd/tuigreet, Waybar, Rofi, Hyprpaper, Materia-dark |
| KDE Plasma | `my-setup-kde/` | Apps, dev tools and shell only, on KDE Plasma (Dolphin, Ark, Spectacle, plasma-pa, kitty). No Hyprland, no greetd |

Configs that are identical in both variants live once in `common/` (Zed `settings.json`, the OBS loopback script and the Obsidian sync script). Both installers read them from there.

The tables below describe the Hyprland variant unless a row says otherwise.

## 🛠️ What's configured here?

### System and Compositor
| Component | Tool |
|-----------|------|
| Package Manager (`pacman.conf`) | Parallel downloads enabled (5) + `ILoveCandy` easter egg |
| Compositor | Hyprland |
| Session Manager | UWSM |
| Login Manager | Greetd + Tuigreet |
| Firewall | UFW |
| Network Manager | NetworkManager + WireGuard |

### Terminal and Shell
| Component | Tool |
|-----------|------|
| Terminal | Kitty |
| Shell | ZSH |
| Prompt | Starship |
| Plugins | zsh-autosuggestions, zsh-syntax-highlighting, fzf |
| Fonts | JetBrains Mono Nerd, Noto Fonts |

### Interface and Theme
| Component | Tool |
|-----------|------|
| Taskbar | Waybar |
| App Launcher | Rofi (+ powermenu) |
| Wallpaper | Hyprpaper |
| GTK Theme | Materia-dark |
| Qt Theme | qt5ct, qt6ct, Kvantum |
| Keyring | GNOME Keyring + libsecret |

### Audio and Media
| Component | Tool |
|-----------|------|
| Audio Service | Pipewire (alsa, pulse, jack) + Wireplumber |
| Audio Control | Pavucontrol |
| Video Player | MPV + FFmpeg |
| Image Viewer | FEH |
| Screen Recorder | OBS Studio + v4l2loopback |

### Files and Disks
| Component | Tool |
|-----------|------|
| File Manager | Thunar (+ plugins, tumbler, gvfs) |
| Sync | Rclone |
| Compression | xarchiver, unzip, p7zip, unrar, tar, gzip, bzip2 |

### Development
| Component | Tool |
|-----------|------|
| Code Editor | Zed (Flatpak) |
| Version Control | Git |
| JS/TS Runtime | Node.js (NVM v24) + pnpm |
| Python Runtime | UV (Astral) |
| Containers | Docker + Docker Compose + Docker Buildx |

### Applications
| Application | Installation |
|------------|--------------|
| Zen Browser | Flatpak |
| Google Chrome | Flatpak |
| Obsidian | Flatpak (+ sync via Rclone and systemd) |
| Spotify | Flatpak |
| Discord | Flatpak |
| DBeaver | Flatpak |
| Anki | Flatpak |
| System Monitor | BTOP (pacman) |
| Terminal Editor | micro (pacman) |
| Clipboard | wl-clipboard |
| Screenshot | grim + slurp |

## 🚀 How to install on a new machine

Follow the steps below after performing a clean Arch Linux installation.

### Prerequisites

- **Arch Linux** freshly installed with:
  - **BTRFS** filesystem with ZSTD compression
  - Subvolumes: `@`, `@home`, `@log`, `@pkg`
  - Partitions: `/boot/efi` (EFI), `/boot` (kernels), `/` (root)
- **Active internet connection**
- **Git** installed on the base system

### 1. Clone the repository

```bash
git clone https://github.com/anjosrejunior/my-arch-config
cd my-arch-config
```

### 2. Run the installer for your variant

```bash
# Hyprland (full desktop)
cd my-setup-hyprland
./install.sh

# KDE Plasma (apps, dev tools and shell only)
cd my-setup-kde
./install.sh
```

> **Note:** The script will ask for your name and email to configure Git. Have this information ready.
> `install.sh` is an orchestrator: it activates the themed scripts in the variant's `scripts/` folder, in order. The Hyprland variant runs `00` to `11` (user input, system base, shell, network, git, flatpak, display, desktop, media, files, dev, apps). The KDE variant has no network (`03`) or desktop (`07`) scripts.

### Post-installation

1. **ZSH** — Log out and log back in (or restart the terminal) for ZSH to become the default shell.
2. **User services** — After the first graphical login, run `./post-install.sh` inside your variant's folder (`my-setup-hyprland/` or `my-setup-kde/`) to activate the user systemd services (PipeWire, OBS Loopback, Obsidian Sync, and GNOME Keyring on Hyprland). Then run `./verify-services.sh` to check them. These are not enabled during `install.sh` because they need an active user/graphical session.
3. **Zed** — Open Zed at least once so that Flatpak generates the configuration directory structure.
4. **Obsidian** — Configure Rclone for sync (the script copies the `sync-obsidian` binary to `~/.local/bin/`; the systemd service is activated by `post-install.sh`).
5. **Docker** — Log out and log back in for the `docker` group to take effect (or run `newgrp docker`).

## 📁 Repository Structure

```
my-arch-config/
├── common/                             # Configs shared by both variants
│   ├── obs/obs-v4l2loopback.sh         # OBS loopback script (installed as ~/.local/bin/obs-v4l2loopback)
│   ├── obsidian-rclone/sync-obsidian.sh # Obsidian/Rclone sync script (installed as ~/.local/bin/sync-obsidian)
│   └── zed/settings.json               # Zed settings
├── my-setup-hyprland/                  # Hyprland variant (full desktop)
│   ├── greetd/                         # Greetd (Display Manager)
│   ├── hypr/                           # Hyprland (Lua config) and Hyprpaper configurations
│   ├── obs/                            # OBS loopback systemd user service
│   ├── obsidian-rclone/                # Obsidian sync systemd user service
│   ├── post-install/                   # Helper not called by the installers (config-git-ssh-key.sh)
│   ├── rofi/                           # Rofi configurations (config.rasi, powermenu.rasi, rofi-powermenu.sh)
│   ├── waybar/                         # Waybar configurations (config.jsonc, style.css)
│   ├── install.sh                      # Orchestrator script (activates the themed scripts below)
│   ├── post-install.sh                 # Post-install: enables user systemd services
│   ├── verify-services.sh              # Checks the user systemd services
│   ├── scripts/                        # Themed scripts activated in order by install.sh
│   │   ├── lib/common.sh               # Shared helpers: logging, checklist, sudo refresh, traps
│   │   ├── 00-user-input.sh            # Git profile + NVIDIA driver selection prompts
│   │   ├── 01-system-base.sh           # Mirrors, system update and base packages
│   │   ├── 02-shell.sh                 # ZSH, Starship and completions
│   │   ├── 03-network.sh               # UFW, NetworkManager/WireGuard and GNOME Keyring
│   │   ├── 04-git.sh                   # Git config and YAY (AUR helper)
│   │   ├── 05-flatpak.sh               # Flatpak + Flathub
│   │   ├── 06-display.sh               # Hyprland + NVIDIA (conditional), UWSM, GreetD/Tuigreet
│   │   ├── 07-desktop.sh               # Waybar, Rofi, dark theme and wallpaper
│   │   ├── 08-media.sh                 # PipeWire, clipboard tools and OBS Studio
│   │   ├── 09-files.sh                 # Thunar, media viewers and Rclone
│   │   ├── 10-dev.sh                   # Node (NVM), UV (Astral) and Docker
│   │   └── 11-apps.sh                  # Flatpak apps install + Zed/Browsers/Anki/Obsidian config
│   ├── my-arch-en.md                   # English documentation
│   ├── my-arch-pt-br.md                # Portuguese (Brazil) documentation
│   └── wallpaper.jpg                   # Default wallpaper
├── my-setup-kde/                       # KDE Plasma variant (apps, dev tools and shell only)
│   ├── obs/                            # OBS loopback systemd user service
│   ├── obsidian-rclone/                # Obsidian sync systemd user service
│   ├── install.sh                      # Orchestrator script (activates the themed scripts below)
│   ├── post-install.sh                 # Post-install: user services and Breeze Dark theme
│   ├── verify-services.sh              # Checks the user systemd services
│   └── scripts/                        # Themed scripts activated in order by install.sh
│       ├── lib/common.sh               # Shared helpers: logging, checklist, sudo refresh, traps
│       ├── 00-user-input.sh            # Git profile, NVIDIA, bootloader and GPG/SSH key prompts
│       ├── 01-system-base.sh           # Mirrors, system update and base packages
│       ├── 02-shell.sh                 # ZSH, Starship and completions
│       ├── 04-git.sh                   # Git config, YAY (AUR helper) and GPG/SSH keys
│       ├── 05-flatpak.sh               # Flatpak + Flathub
│       ├── 06-display.sh               # Optional NVIDIA 1050ti drivers
│       ├── 08-media.sh                 # PipeWire, plasma-pa, clipboard tools and Spectacle
│       ├── 09-files.sh                 # Dolphin, Ark and file tools
│       ├── 10-dev.sh                   # Node (NVM), UV (Astral) and Docker
│       └── 11-apps.sh                  # Flatpak apps install + Zed/Browsers/Anki/Obsidian config
├── scripts/                            # One-off helper scripts (not the installers)
├── setup-docs/                         # Manual setup notes per topic
├── AGENTS.md                           # Guidance for coding agents working on this repo
├── LICENSE
└── README.md
```

## 📝 Notes

- The script uses **sudo pre-authentication** (`sudo -v`) to avoid multiple password prompts.
- The installed NVIDIA driver is `nvidia-580xx` (DKMS), compatible with Wayland.
- The Hyprland variant applies the dark theme globally via `gsettings` (Materia-dark). The KDE variant applies Breeze Dark with `plasma-apply-colorscheme` / `plasma-apply-lookandfeel` in its `post-install.sh`.
- The lock screen (**Hyprlock**) is not yet configured in the script (pending).
- Flatpak support includes the Flathub repositories and specific permissions for Zen Browser, Chrome, Obsidian, and Anki.

## 📄 License

This project is licensed under the MIT License. Feel free to use, modify, and distribute it.