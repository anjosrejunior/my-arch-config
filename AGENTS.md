# AGENTS.md

## What this repo is

- Personal Arch Linux dotfiles and reinstall automation with two variants:
  - `my-setup-hyprland/` — Arch + Hyprland, full desktop setup.
  - `my-setup-kde/` — Arch + KDE Plasma, apps/dev/shell-only variant (no Hyprland).
- There is no application build, package manifest, test suite, lint config, or CI.
- Each variant has its own `install.sh` entrypoint; the numbered scripts are the source of truth over prose in `README.md` / `setup-docs/`, which can be stale.
- The `.devcontainer/` is a Debian sandbox for editing only. Never run either installer there: they target Arch, use `pacman`/`yay`/`sudo`, make system-wide destructive changes, and are interactive.

## Verification

- No tests or linter are configured. For shell edits, run `bash -n <file>` (and if available, `shellcheck <file>`).
- Hyprland install (Arch only): `cd my-setup-hyprland && ./install.sh`.
- KDE install (Arch only): `cd my-setup-kde && ./install.sh`.
- After the first graphical login, run the matching `./post-install.sh` (user systemd services), then `./verify-services.sh` to check them.
- `GIT_NAME` and `GIT_EMAIL` can pre-seed the Git prompts. `my-setup-kde` also honors `NVIDIA_CHOICE=1050ti|no_nvidia`; `my-setup-hyprland/scripts/00-user-input.sh` currently resets `NVIDIA_CHOICE`, so review it before relying on the env var there. The reboot prompt still reads stdin.
- `my-setup-kde/scripts/06-display.sh` with `1050ti` edits `/etc` and the bootloader configuration (systemd-boot or GRUB, chosen in the script); review the script before running it.

## Installer structure (both variants)

- `install.sh` **sources** the numbered scripts in order, in one shell, so they share state (`SCRIPT_DIR`, `BIN_DST_DIR`, `GIT_NAME`, `GIT_EMAIL`, `NVIDIA_CHOICE`), the checklist, traps, and `set -Eeuo pipefail`. Add a new thematic script to the `SCRIPTS` array and keep numbered order; do not switch to executing it as a subprocess.
- Every script starts with the `MY_SETUP_COMMON_LOADED` guard that sources `scripts/lib/common.sh`. Preserve it so the script also works standalone.
- Use `log`, `step`, `ok`, `warn`, `err`, and `finish_checklist` from `scripts/lib/common.sh` instead of raw output. `warn`/`err` feed the generated `~/install-checklist-*.txt`.
- Keep comments and user-facing messages in Portuguese (pt-BR), matching the existing scripts.
- Anything needing a graphical user session (`systemctl --user`, `gsettings`) belongs in `post-install.sh`, not `install.sh`.
- Repo-to-install naming convention: source scripts keep `.sh`, but installed commands drop it into `~/.local/bin` (e.g. `obs-v4l2loopback.sh` -> `obs-v4l2loopback`, `sync-obsidian.sh` -> `sync-obsidian`). The `ExecStart=` paths in the service files rely on the installed names.
- `10-dev.sh` pins NVM and UV versions **and SHA-256 checksums**; bump the version and checksum together or installs abort.
- `my-setup-hyprland/post-install/config-git-ssh-key.sh` is not called by either installer and is not executable. It also resolves `common.sh` via `../../scripts/lib/`, which is wrong from `post-install/`; source `../scripts/lib/common.sh` when running it.

### Shared files across variants

Configuration identical in both variants lives once in `common/` at the repo root (`common/zed/settings.json`, `common/obs/obs-v4l2loopback.sh`, `common/obsidian-rclone/sync-obsidian.sh`). The scripts read it through `COMMON_DIR`, defined in `scripts/lib/common.sh` as `$SCRIPT_DIR/../common`. Edit these files only in `common/`.

Keep these in sync unless a variant-specific difference is intentional:

- `scripts/lib/common.sh` (exact copy in both variants, including the `COMMON_DIR` line).
- `scripts/10-dev.sh` versions and SHA-256 checksums.
- The ZSH/Starship block in `02-shell.sh`.

Intentional KDE differences:

- `obs-v4l2loopback.service` and `obsidian-sync.service` use `default.target`, not `graphical-session.target`. Service files stay per variant in `obs/` and `obsidian-rclone/`, not in `common/`.
- `02-shell.sh` leaves `ssh-agent` activation to `post-install.sh`; `my-setup-hyprland` activates it during install.
- `11-apps.sh` adds Chrome to the Flatpak list and does not apply the `GTK_THEME=Materia-dark` override.
- `06-display.sh` handles only NVIDIA drivers, not Hyprland/UWSM/greetd.

## my-setup-hyprland (Arch + Hyprland)

- Full installation: scripts `00` through `11`.
- Hyprland uses the Lua config (`hyprland.lua`), not `hyprland.conf`. `06-display.sh` copies `hyprland-1050ti.lua` when `NVIDIA_CHOICE=1050ti`; keep both variants in sync (currently they differ only by the NVIDIA env block).
- `06-display.sh` installs Hyprland, NVIDIA drivers, UWSM and greetd/tuigreet.
- Includes Waybar, Rofi, Hyprpaper, Materia-dark, GNOME Keyring, UFW and NetworkManager.

## my-setup-kde (Arch + KDE Plasma)

- Apps/dev/shell variant: scripts `00, 01, 02, 04, 05, 06, 08, 09, 10, 11`.
- There are intentionally no `03-network.sh` or `07-desktop.sh` scripts; do not renumber the existing scripts to fill the gaps.
- No Hyprland, Waybar, Rofi, Hyprpaper, greetd, UWSM, wallpaper, Materia-dark or `gsettings` theme setup. The only theme setup is Breeze Dark via `plasma-apply-colorscheme`/`plasma-apply-lookandfeel` in `post-install.sh`.
- Uses KDE-native tools (Dolphin, Ark, plasma-pa, Spectacle) for file management, archives, audio and screenshots. `kitty` is installed as the terminal.
- `06-display.sh` handles only the optional NVIDIA 1050ti drivers:
  - installs headers for the kernels present;
  - installs `libva-nvidia-driver`, `egl-wayland` and `nvidia-580xx-dkms`/`nvidia-580xx-utils`/`lib32-nvidia-580xx-utils` via YAY;
  - writes `/etc/modprobe.d/nvidia.conf` with `options nvidia_drm modeset=1`;
  - adds the NVIDIA modules to `/etc/mkinitcpio.conf`;
  - checks at least 500 MB free in `/boot` before changing anything (the `/boot` partition is small and `mkinitcpio -P` fails silently-ish when it fills up);
  - `00-user-input.sh` asks which bootloader to use (menu `1) systemd-boot 2) GRUB`, or `BOOTLOADER_CHOICE=systemd-boot|grub` via env), right after the NVIDIA choice;
  - `00-user-input.sh` also asks whether to create a GPG key (name/email default to the Git profile; `GPG_CHOICE=yes|no` via env) and an SSH key for GitHub (`SSH_CHOICE=yes|no`); `04-git.sh` creates them;
  - for systemd-boot: adds `nvidia_drm.modeset=1` to `/etc/kernel/cmdline` or `/boot/loader/entries/*.conf`, with backups, and runs `reinstall-kernels` when available;
  - for GRUB: adds `nvidia_drm.modeset=1` to `GRUB_CMDLINE_LINUX_DEFAULT` in `/etc/default/grub`, with a backup, and regenerates `/boot/grub/grub.cfg` with `grub-mkconfig`;
  - regenerates initramfs with `mkinitcpio -P`.
- User services (`obs-v4l2loopback`, `obsidian-sync`) use `default.target`; `post-install.sh` also enables PipeWire and `ssh-agent`, and applies Breeze Dark.
- Flatpaks: Zed, DBeaver, Discord, Spotify, Anki, Zen, Obsidian, Chrome and Bitwarden. Overrides cover the shared folder, Anki base and Obsidian vault.
- Shared assets (`zed`, `obs`, `obsidian-rclone`) live in `common/`, not in `my-setup-kde/`.

## Layout

- `common/` — configs shared by both variants: `zed/settings.json`, `obs/obs-v4l2loopback.sh`, `obsidian-rclone/sync-obsidian.sh`.
- `my-setup-hyprland/` — Hyprland installer plus deployed configs (`hypr/`, `waybar/`, `rofi/`, `greetd/`, service files).
- `my-setup-kde/` — KDE installer plus `scripts/`, `scripts/lib/common.sh`, `obs/` and `obsidian-rclone/` (service files only), `install.sh`, `post-install.sh`, `verify-services.sh`.
- `setup-docs/` — per-topic manual setup notes (pacman, NVIDIA, greetd, secure boot, etc.).
- `scripts/` — one-off helper scripts, separate from the installers.
