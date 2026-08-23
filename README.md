# 📁 Arch Linux Dotfiles

This repository contains my personal Arch Linux configuration files (`dotfiles`) and manuals. The goal is to allow me to quickly replicate my workflow and environment on any machine. Feel free to copy them or use them as inspiration!

---

## 🛠️ What's configured here?

### System and Compositor
| Component | Tool |
|-----------|------|
| Package Manager (`pacman.conf`) | Parallel downloads enabled (10) + `ILoveCandy` easter egg |
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
./bootstrap.sh
```

> **Note:** The script will ask for your name and email to configure Git. Have this information ready.

### Post-installation

1. **ZSH** — Log out and log back in (or restart the terminal) for ZSH to become the default shell.
2. **Zed** — Open Zed at least once so that Flatpak generates the configuration directory structure.
3. **Obsidian** — Configure Rclone for sync (the script copies the `sync-obsidian` binary to `~/.local/bin/` and enables the systemd service).
4. **Docker** — Log out and log back in for the `docker` group to take effect (or run `newgrp docker`).

## 📁 Repository Structure

```
my-arch-config/
├── my-setup/
│   ├── bootstrap.sh          # Main installation script
│   ├── my-arch-en.md             # English documentation
│   ├── my-arch-pt-br.md          # Portuguese (Brazil) documentation
│   ├── waybar/                   # Waybar configurations (config.jsonc, style.css)
│   ├── rofi/                     # Rofi configurations (config.rasi, powermenu.rasi, rofi-powermenu)
│   ├── hypr/                     # Hyprpaper configurations (hyprpaper.conf)
│   ├── zed/                      # Zed configurations (settings.json)
│   ├── obsidian-rclone/          # Obsidian sync script and systemd service
│   └── wallpaper.jpg             # Default wallpaper
├── scripts                     # Scripts
├── setup-docs                  # Setup documentation
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