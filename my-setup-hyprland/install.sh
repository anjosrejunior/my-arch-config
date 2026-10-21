#!/usr/bin/env bash
# ####################################################################################
# ///// INSTALL ARCH LINUX
# ####################################################################################
# Orquestrador de pós-instalação e configuração para Arch Linux + Hyprland.
# Este script NÃO executa configurações diretamente: ele apenas ativa (source),
# em ordem, os scripts temáticos localizados em my-setup/scripts/.
# ####################################################################################

set -Eeuo pipefail

# ---- Carrega a biblioteca comum (funções, checklist, sudo-refresh) ----
MY_SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$MY_SETUP_DIR/scripts/lib/common.sh"

# ---- Scripts temáticos executados em ordem ----
SCRIPTS=(
    "00-user-input.sh"
    "01-system-base.sh"
    "02-shell.sh"
    "03-network.sh"
    "04-git.sh"
    "05-flatpak.sh"
    "06-display.sh"
    "07-desktop.sh"
    "08-media.sh"
    "09-files.sh"
    "10-dev.sh"
    "11-apps.sh"
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

warn "Serviços de usuário (GNOME Keyring, PipeWire, OBS Loopback e Obsidian Sync) NÃO foram ativados."
warn "Após o primeiro login gráfico, execute manualmente: ./post-install.sh"

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