#!/usr/bin/env bash
# ####################################################################################
# ///// POST INSTALL ARCH LINUX
# ####################################################################################
# Pós-instalação: ativa no Systemd os serviços de usuário que dependem de uma
# sessão gráfica ativa (GNOME Keyring, PipeWire, OBS Loopback e Obsidian Sync).
# Execute APÓS o primeiro login gráfico (os comandos usam systemctl --user).
# Os comandos de instalação dos pacotes continuam no install.sh; aqui ficam
# apenas a cópia das configs (.service) e a ativação dos serviços.
# ####################################################################################

set -Eeuo pipefail

# ---- Carrega a biblioteca comum (funções, checklist, SCRIPT_DIR, BIN_DST_DIR) ----
MY_SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$MY_SETUP_DIR/scripts/lib/common.sh"

SYSTEMD_USER_DIR="$HOME/.config/systemd/user"

# ####################################################################################
# ///// PIPE WIRE
# ####################################################################################

log "Áudio (PipeWire)"

step "Ativando serviços do PipeWire..."
systemctl --user enable --now pipewire pipewire-pulse wireplumber || warn "Não foi possível ativar pipewire pipewire-pulse wireplumber"

ok "Serviços de áudio ativados."

# ####################################################################################
# ///// OBS STUDIO & LOOPBACK
# ####################################################################################

log "OBS Studio e v4l2loopback"

step "Criando diretório systemd de usuário..."
mkdir -p "$SYSTEMD_USER_DIR"

step "Copiando serviço systemd do OBS Loopback..."
if [ -f "$SCRIPT_DIR/obs/obs-v4l2loopback.service" ]; then
    cp "$SCRIPT_DIR/obs/obs-v4l2loopback.service" "$SYSTEMD_USER_DIR/obs-v4l2loopback.service"
    ok "obs-v4l2loopback.service copiado para ~/.config/systemd/user/"
else
    warn "obs-v4l2loopback.service não encontrado em $SCRIPT_DIR/obs/"
fi

step "Ativando serviço no Systemd..."
systemctl --user daemon-reload || warn "systemctl daemon-reload falhou."
systemctl --user enable --now obs-v4l2loopback.service || warn "Não foi possível ativar obs-v4l2loopback.service."

ok "OBS Loopback ativado."

# ####################################################################################
# ///// OBSIDIAN SYNC
# ####################################################################################

log "Obsidian Sync"

step "Criando diretório systemd de usuário..."
mkdir -p "$SYSTEMD_USER_DIR"

step "Copiando serviço systemd do Obsidian Sync..."
if [ -f "$SCRIPT_DIR/obsidian-rclone/obsidian-sync.service" ]; then
    cp "$SCRIPT_DIR/obsidian-rclone/obsidian-sync.service" "$SYSTEMD_USER_DIR/obsidian-sync.service"
    ok "obsidian-sync.service copiado para ~/.config/systemd/user/"
else
    warn "obsidian-sync.service não encontrado em $SCRIPT_DIR/obsidian-rclone/"
fi

step "Ativando serviço no Systemd..."
systemctl --user daemon-reload || warn "systemctl daemon-reload falhou."
systemctl --user enable --now obsidian-sync.service || warn "Não foi possível ativar obsidian-sync.service."

ok "Obsidian Sync ativado."

# ####################################################################################
# ///// FIM
# ####################################################################################

log "Pós-instalação concluída!"

finish_checklist
ok "Checklist salvo em: $CHECKLIST_FILE"