# Arch Linux Dotfiles

Personal Arch Linux configuration and reinstall automation. The goal is to rebuild my workflow and environment on a fresh machine with a few commands, and to keep the setup documented. Feel free to copy it or use it as inspiration.

## Variants

The project has two variants, one per desktop environment. Each has its own installer:

| Variant | Folder | Focus |
|---------|--------|-------|
| Hyprland | `my-setup-hyprland/` | Full desktop: Hyprland, UWSM, greetd/tuigreet, Waybar, Rofi, Hyprpaper, Materia-dark theme |
| KDE Plasma | `my-setup-kde/` | Apps, dev tools and shell on KDE Plasma, using Plasma's own tools (Dolphin, Ark, Spectacle, plasma-pa) |

Both variants install the same base system, shell, Git, Flatpak, dev tools and applications, with the parts that depend on the desktop changing between them.

## Shared configuration

Configs that are identical in both variants live once in `common/`:

- Zed `settings.json`
- OBS loopback script
- Obsidian sync script (Rclone)

Both installers read them from there, so a change in `common/` applies to both variants.

## Repository layout

```
my-arch-config/
├── common/             # Configs shared by both variants
├── my-setup-hyprland/  # Hyprland installer and desktop configs
├── my-setup-kde/       # KDE Plasma installer
├── setup-docs/         # Manual setup notes per topic
├── scripts/            # One-off helper scripts, not run by the installers
├── AGENTS.md           # Guidance for coding agents working on this repo
└── LICENSE
```

- **`setup-docs/`** holds manual notes for steps that are not fully automated, such as pacman configuration, NVIDIA, greetd, Secure Boot, dual boot, Wi-Fi and VPN.
- **`scripts/`** holds helpers that are run by hand, for example for Secure Boot, OBS or a specific hardware device.

## Requirements

- **Arch Linux** installed on a UEFI machine, with an active internet connection and `git` available.
- The installers target **Arch Linux only**. They use `pacman`, `yay` and `sudo`, and they change system configuration, so review the scripts before running them.

## Usage

1. Clone the repository and enter the folder of the variant you want:

   ```bash
   git clone https://github.com/anjosrejunior/my-arch-config
   cd my-arch-config/my-setup-kde   # or my-setup-hyprland
   ```

2. Run the installer. It asks a few questions, such as the Git identity and hardware options, then runs the numbered scripts in order:

   ```bash
   ./install.sh
   ```

3. After the first graphical login, run the user services setup and check it:

   ```bash
   ./post-install.sh
   ./verify-services.sh
   ```

   These steps are separate because user systemd services need an active graphical session.

Each step is described in more detail in the scripts themselves and in `setup-docs/`.

## How the installers work

- `install.sh` is an orchestrator. It runs the themed scripts in `scripts/`, in numbered order, in a single shell, so they share state.
- The numbers keep the execution order. Gaps in the numbering are intentional, so new scripts can be added without renaming the existing ones.
- Each run writes a checklist to `~/install-checklist-*.txt`, listing the steps that succeeded and any warnings or errors.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).
