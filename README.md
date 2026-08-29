# 📁 Arch Linux Dotfiles

This repository contains my personal Arch Linux configuration files (`dotfiles`) and manuals. The goal is to allow me to quickly replicate my workflow and environment on any machine. Feel free to copy them or use them as inspiration!

---

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

### 2. Run the main script

```bash
cd my-setup
./install.sh
```

> **Note:** The script will ask for your name and email to configure Git. Have this information ready.
> `install.sh` is an orchestrator: it activates the themed scripts in `my-setup/scripts/` in order (one per area: user input, system base, shell, network, git, flatpak, display, desktop, media, files, dev, apps).

### Post-installation

1. **ZSH** — Log out and log back in (or restart the terminal) for ZSH to become the default shell.
2. **User services** — After the first graphical login, run `./my-setup/post-install.sh` to activate the user systemd services (GNOME Keyring, PipeWire, OBS Loopback, Obsidian Sync). These are not enabled during `install.sh` because they need an active user/graphical session.
3. **Zed** — Open Zed at least once so that Flatpak generates the configuration directory structure.
4. **Obsidian** — Configure Rclone for sync (the script copies the `sync-obsidian` binary to `~/.local/bin/`; the systemd service is activated by `post-install.sh`).
5. **Docker** — Log out and log back in for the `docker` group to take effect (or run `newgrp docker`).

## 📁 Repository Structure

```
my-arch-config/
├── my-setup/
│   ├── greetd/                   # Greetd (Display Manager)
│   ├── hypr/                     # Hyprpaper configurations (hyprpaper.conf)
│   ├── obs/                      # Obs configurations
│   ├── obsidian-rclone/          # Obsidian sync script and systemd service
│   ├── post-install/             # Post Install Actions
│   ├── rofi/                     # Rofi configurations (config.rasi, powermenu.rasi, rofi-powermenu)
│   ├── waybar/                   # Waybar configurations (config.jsonc, style.css)
│   ├── zed/                      # Zed configurations (settings.json)
│   ├── install.sh                # Orchestrator script (activates the themed scripts below)
│   ├── post-install.sh           # Post-install: enables user systemd services (Keyring, PipeWire, OBS, Obsidian)
│   ├── scripts/                  # Themed scripts activated in order by install.sh
│   │   ├── lib/common.sh         # Shared helpers: logging, checklist, sudo refresh, traps
│   │   ├── 00-user-input.sh      # Git profile + NVIDIA driver selection prompts
│   │   ├── 01-system-base.sh     # Mirrors, system update and base packages
│   │   ├── 02-shell.sh           # ZSH, Starship and completions
│   │   ├── 03-network.sh         # UFW, NetworkManager/WireGuard and GNOME Keyring
│   │   ├── 04-git.sh             # Git config and YAY (AUR helper)
│   │   ├── 05-flatpak.sh         # Flatpak + Flathub
│   │   ├── 06-display.sh         # Hyprland + NVIDIA (conditional), UWSM, GreetD/Tuigreet
│   │   ├── 07-desktop.sh         # Waybar, Rofi, dark theme and wallpaper
│   │   ├── 08-media.sh           # PipeWire, clipboard tools and OBS Studio
│   │   ├── 09-files.sh           # Thunar, media viewers and Rclone
│   │   ├── 10-dev.sh             # Node (NVM), UV (Astral) and Docker
│   │   └── 11-apps.sh            # Flatpak apps install + Zed/Browsers/Anki/Obsidian config
│   ├── my-arch-en.md             # English documentation
│   ├── my-arch-pt-br.md          # Portuguese (Brazil) documentation
│   └── wallpaper.jpg             # Default wallpaper
├── scripts                       # Scripts
├── setup-docs                    # Setup documentation
├── LICENSE
└── README.md
```

## 📝 Notes

- The script uses **sudo pre-authentication** (`sudo -v`) to avoid multiple password prompts.
- The installed NVIDIA driver is `nvidia-580xx` (DKMS), compatible with Wayland.
- The dark theme is applied globally via `gsettings` (Materia-dark).
- The lock screen (**Hyprlock**) is not yet configured in the script (pending).
- Flatpak support includes the Flathub repositories and specific permissions for Zen Browser, Chrome, Obsidian, and Anki.

## 📄 License

This project is licensed under the MIT License. Feel free to use, modify, and distribute it.