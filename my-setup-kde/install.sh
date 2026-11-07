#!/usr/bin/env bash
# ####################################################################################
# ///// INSTALL ARCH LINUX + KDE PLASMA
# ####################################################################################
# Orquestrador de pós-instalação para um Arch Linux com KDE Plasma.
# Instala apenas os aplicativos, ferramentas de desenvolvimento e shell do
# setup pessoal; não configura Hyprland, Waybar, Rofi, greetd ou wallpaper.
# Este script ativa (source), em ordem, os scripts temáticos em scripts/.
# ####################################################################################

set -Eeuo pipefail

# ---- Carrega a biblioteca comum (funções, checklist, sudo-refresh) ----
MY_SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$MY_SETUP_DIR/scripts/lib/common.sh"

# ---- Scripts temáticos executados em ordem ----
SCRIPTS=(
    "00-user-input.sh"
    "01-system-base.sh"
    "02-zsh-starship.sh"
    "04-git-aur.sh"
    "05-flatpak-setup.sh"
    "06-graphics-drivers.sh"
    "08-media-capture.sh"
    "09-files-viewers.sh"
    "10-dev-tools.sh"
    "11-flatpak-apps.sh"
)

SCRIPTS_DIR="$MY_SETUP_DIR/scripts"

# ---- Orquestração: ativa cada script no mesmo processo para manter o estado ----
for script in "${SCRIPTS[@]}"; do
    step "Executando $script..."
    . "$SCRIPTS_DIR/$script"
    ok "$script concluído."
done

# ####################################################################################
# ///// FIM
# ####################################################################################

log "Configuração concluída!"

finish_checklist
ok "Checklist salvo em: $CHECKLIST_FILE"

warn "Serviços de usuário (PipeWire, SSH Agent, OBS Loopback e Obsidian Sync) NÃO foram ativados."
warn "Após o primeiro login gráfico no KDE Plasma, execute manualmente: ./post-install.sh"

REBOOT=""
while true; do
    read -rp "Reiniciar agora para aplicar as mudanças? [s/N]: " REBOOT
    case "${REBOOT:-}" in
        [sS]|[sS][iI][mM]|[yY]|[yY][eE][sS])
            ok "Reiniciando o sistema..."
            sudo shutdown -r now
            break
            ;;
        [nN]|[nN][ãaÃoO]|"")
            ok "Reinicialização adiada. Faça logout/login para aplicar as mudanças de sessão (zsh, docker, systemd --user)."
            break
            ;;
        *)
            warn "Resposta inválida. Use 's' (sim) ou 'n' (não)."
            ;;
    esac
done
