# AGENTS.md

## What this repo is

- Personal Arch Linux dotfiles and reinstall automation with two variants:
  - `my-setup/` — Arch + Hyprland, full desktop setup.
  - `my-setup-kde/` — Arch + KDE Plasma, apps/dev/shell-only variant (no Hyprland).
- There is no application build, package manifest, test suite, lint config, or CI.
- Each variant has its own `install.sh` entrypoint; the numbered scripts are the source of truth over prose in `README.md` / `setup-docs/`, which can be stale.
- The `.devcontainer/` is a Debian sandbox for editing only. Never run either installer there: they target Arch, use `pacman`/`yay`/`sudo`, make system-wide destructive changes, and are interactive.

## Verification

- No tests or linter are configured. For shell edits, run `bash -n <file>` (and if available, `shellcheck <file>`).
- Hyprland install (Arch only): `cd my-setup && ./install.sh`.
- KDE install (Arch only): `cd my-setup-kde && ./install.sh`.
- After the first graphical login, run the matching `./post-install.sh` (user systemd services), then `./verify-services.sh` to check them.
- `GIT_NAME` and `GIT_EMAIL` can pre-seed the Git prompts. `my-setup-kde` also honors `NVIDIA_CHOICE=1050ti|no_nvidia`; `my-setup/scripts/00-user-input.sh` currently resets `NVIDIA_CHOICE`, so review it before relying on the env var there. The reboot prompt still reads stdin.
- `my-setup-kde/scripts/06-display.sh` with `1050ti` edits `/etc` and the systemd-boot configuration; review the script before running it.

## Installer structure (both variants)

- `install.sh` **sources** the numbered scripts in order, in one shell, so they share state (`SCRIPT_DIR`, `BIN_DST_DIR`, `GIT_NAME`, `GIT_EMAIL`, `NVIDIA_CHOICE`), the checklist, traps, and `set -Eeuo pipefail`. Add a new thematic script to the `SCRIPTS` array and keep numbered order; do not switch to executing it as a subprocess.
- Every script starts with the `MY_SETUP_COMMON_LOADED` guard that sources `scripts/lib/common.sh`. Preserve it so the script also works standalone.
- Use `log`, `step`, `ok`, `warn`, `err`, and `finish_checklist` from `scripts/lib/common.sh` instead of raw output. `warn`/`err` feed the generated `~/install-checklist-*.txt`.
- Keep comments and user-facing messages in Portuguese (pt-BR), matching the existing scripts.
- Anything needing a graphical user session (`systemctl --user`, `gsettings`) belongs in `post-install.sh`, not `install.sh`.
- Repo-to-install naming convention: source scripts keep `.sh`, but installed commands drop it into `~/.local/bin` (e.g. `obs-v4l2loopback.sh` -> `obs-v4l2loopback`, `sync-obsidian.sh` -> `sync-obsidian`). The `ExecStart=` paths in the service files rely on the installed names.
- `10-dev.sh` pins NVM and UV versions **and SHA-256 checksums**; bump the version and checksum together or installs abort.
- `my-setup/post-install/config-git-ssh-key.sh` is not called by either installer and is not executable. It also resolves `common.sh` via `../../scripts/lib/`, which is wrong from `post-install/`; source `../scripts/lib/common.sh` when running it.

### Shared files across variants

Keep these in sync unless a variant-specific difference is intentional:

- `scripts/lib/common.sh` (exact copy in both variants).
- `scripts/10-dev.sh` versions and SHA-256 checksums.
- `zed/settings.json`.
- `obs/obs-v4l2loopback.sh`.
- `obsidian-rclone/sync-obsidian.sh`.
- The ZSH/Starship block in `02-shell.sh`.

Intentional KDE differences:

- `obs-v4l2loopback.service` and `obsidian-sync.service` use `default.target`, not `graphical-session.target`.
- `02-shell.sh` leaves `ssh-agent` activation to `post-install.sh`; `my-setup` activates it during install.
- `11-apps.sh` adds Chrome to the Flatpak list and does not apply the `GTK_THEME=Materia-dark` override.
- `06-display.sh` handles only NVIDIA drivers, not Hyprland/UWSM/greetd.

## my-setup (Arch + Hyprland)

- Full installation: scripts `00` through `11`.
- Hyprland uses the Lua config (`hyprland.lua`), not `hyprland.conf`. `06-display.sh` copies `hyprland-1050ti.lua` when `NVIDIA_CHOICE=1050ti`; keep both variants in sync (currently they differ only by the NVIDIA env block).
- `06-display.sh` installs Hyprland, NVIDIA drivers, UWSM and greetd/tuigreet.
- Includes Waybar, Rofi, Hyprpaper, Materia-dark, GNOME Keyring, UFW and NetworkManager.

## my-setup-kde (Arch + KDE Plasma)

- Apps/dev/shell variant: scripts `00, 01, 02, 04, 05, 06, 08, 09, 10, 11`.
- There are intentionally no `03-network.sh` or `07-desktop.sh` scripts; do not renumber the existing scripts to fill the gaps.
- No Hyprland, Waybar, Rofi, Hyprpaper, greetd, UWSM, wallpaper, Materia-dark or `gsettings` theme setup.
- Uses KDE-native tools (Dolphin, Ark, plasma-pa, Spectacle) for file management, archives, audio and screenshots. `kitty` is installed as the terminal.
- `06-display.sh` handles only the optional NVIDIA 1050ti drivers:
  - installs headers for the kernels present;
  - installs `libva-nvidia-driver`, `egl-wayland` and `nvidia-580xx-dkms`/`nvidia-580xx-utils`/`lib32-nvidia-580xx-utils` via YAY;
  - writes `/etc/modprobe.d/nvidia.conf` with `options nvidia_drm modeset=1`;
  - adds the NVIDIA modules to `/etc/mkinitcpio.conf`;
  - adds `nvidia_drm.modeset=1` to `/etc/kernel/cmdline` or to `/boot/loader/entries/*.conf` (systemd-boot), with backups;
  - regenerates initramfs with `mkinitcpio -P` and runs `reinstall-kernels` when available;
  - **never edits GRUB**.
- User services (`obs-v4l2loopback`, `obsidian-sync`) use `default.target`; `post-install.sh` also enables PipeWire and `ssh-agent`.
- Flatpaks: Zed, DBeaver, Discord, Spotify, Anki, Zen, Obsidian and Chrome. Overrides cover the shared folder, Anki base and Obsidian vault.
- Assets live in `my-setup-kde/{zed,obs,obsidian-rclone}/`.

## Layout

- `my-setup/` — Hyprland installer plus deployed configs (`hypr/`, `waybar/`, `rofi/`, `zed/`, `greetd/`, service files).
- `my-setup-kde/` — KDE installer plus `scripts/`, `scripts/lib/common.sh`, `zed/`, `obs/`, `obsidian-rclone/`, `install.sh`, `post-install.sh`, `verify-services.sh`.
- `setup-docs/` — per-topic manual setup notes (pacman, NVIDIA, greetd, secure boot, etc.).
- `scripts/` — one-off helper scripts, separate from the installers.
