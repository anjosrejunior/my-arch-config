#!/usr/bin/env bash
# ####################################################################################
# ///// POST INSTALL ARCH LINUX
# ####################################################################################
# Pós-instalação: ativa no Systemd os serviços de usuário que dependem de uma
# sessão gráfica ativa (PipeWire, OBS Loopback, Obsidian Sync e agente de polkit),
# configura o rclone (remoto mydrive) e cria a chave SSH do GitHub.
# A VPN WireGuard não é configurada aqui: use o vpn-setup.sh, quando tiver o .conf.
# Execute APÓS o primeiro login gráfico (os comandos usam systemctl --user).
# Os comandos de instalação dos pacotes continuam no install.sh; aqui ficam
# apenas a cópia das configs (.service), a ativação dos serviços e as etapas
# que pedem interação do usuário (senha da chave SSH, login OAuth do Drive).
#
# Variáveis opcionais:
#   RCLONE_CONF_SRC=/caminho/rclone.conf  # copia uma config do rclone já pronta (com tokens)
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
# ///// AGENTE DE POLKIT (HYPRPOLKITAGENT)
# ####################################################################################

log "Agente de Polkit (hyprpolkitagent)"

step "Ativando serviço no Systemd..."
systemctl --user enable --now hyprpolkitagent.service || warn "Não foi possível ativar hyprpolkitagent.service."

ok "hyprpolkitagent ativado."

# ####################################################################################
# ///// RCLONE (REMOTO MYDRIVE)
# ####################################################################################
# O obsidian-sync usa o remoto 'mydrive'. Sem ele o sync fica desativado.

log "Rclone (remoto mydrive)"

RCLONE_CONF_DST="$HOME/.config/rclone/rclone.conf"

if rclone listremotes 2>/dev/null | grep -q "^mydrive:"; then
    ok "Remoto 'mydrive' já configurado."
elif [ -n "${RCLONE_CONF_SRC:-}" ] && [ -f "$RCLONE_CONF_SRC" ]; then
    step "Copiando configuração do rclone de $RCLONE_CONF_SRC..."
    mkdir -p "$(dirname "$RCLONE_CONF_DST")"
    cp "$RCLONE_CONF_SRC" "$RCLONE_CONF_DST"
    chmod 600 "$RCLONE_CONF_DST"
    if rclone listremotes 2>/dev/null | grep -q "^mydrive:"; then
        ok "Remoto 'mydrive' restaurado a partir do arquivo informado."
    else
        warn "O arquivo informado não contém o remoto 'mydrive'."
    fi
else
    # Sem arquivo pronto: abre o login OAuth do Google Drive no navegador.
    # Assume que o remoto 'mydrive' é do tipo 'drive' (Google Drive), como o sync-obsidian espera.
    step "Remoto 'mydrive' não encontrado. Iniciando o login do Google Drive (abre o navegador)..."
    if rclone config create mydrive drive scope=drive; then
        ok "Remoto 'mydrive' criado."
    else
        warn "Não foi possível criar o remoto 'mydrive'. Rode manualmente: rclone config"
    fi
fi

# ####################################################################################
# ///// CHAVE SSH DO GITHUB
# ####################################################################################

log "Chave SSH para o GitHub"

if ! command -v ssh-keygen &> /dev/null; then
    step "Instalando OpenSSH..."
    sudo pacman -S --needed --noconfirm openssh
fi

SSH_DIR="$HOME/.ssh"
SSH_KEY="$SSH_DIR/github_key"
SSH_CONFIG="$SSH_DIR/config"
PUBLIC_KEY_TXT="$HOME/chave_publica_github.txt"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

if [ -f "$SSH_KEY" ]; then
    ok "Chave SSH já existe em $SSH_KEY. Geração pulada."
else
    # Comentário da chave: e-mail do Git (o install.sh não é executado aqui, então lê do git config).
    KEY_COMMENT="$(git config --global user.email || true)"
    while [ -z "$KEY_COMMENT" ]; do
        read -rp "Digite o e-mail da sua conta do GitHub (usado como comentário da chave): " KEY_COMMENT
    done

    SSH_PASSPHRASE=""
    while [ -z "$SSH_PASSPHRASE" ]; do
        read -rsp "Digite uma senha (passphrase) para a chave SSH do GitHub: " SSH_PASSPHRASE
        echo ""
        [ -z "$SSH_PASSPHRASE" ] && warn "A senha não pode ficar em branco."
    done

    ssh-keygen -t ed25519 -C "$KEY_COMMENT" -f "$SSH_KEY" -N "$SSH_PASSPHRASE" > /dev/null
    unset SSH_PASSPHRASE
    chmod 600 "$SSH_KEY"
    chmod 644 "${SSH_KEY}.pub"

    if ! grep -q "Host github.com" "$SSH_CONFIG" 2>/dev/null; then
        cat << EOF >> "$SSH_CONFIG"

# Configuração da chave SSH para o GitHub
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/github_key
    IdentitiesOnly yes
    AddKeysToAgent yes
EOF
        chmod 600 "$SSH_CONFIG"
        ok "Arquivo ~/.ssh/config atualizado com as regras do GitHub."
    fi

    cp "${SSH_KEY}.pub" "$PUBLIC_KEY_TXT"
    chmod 644 "$PUBLIC_KEY_TXT"

    ok "Chave SSH gerada com sucesso!"
    ok "Chave privada: $SSH_KEY"
    ok "Cópia da chave pública pronta em: $PUBLIC_KEY_TXT"
    warn "Cadastre a chave PÚBLICA em https://github.com/settings/keys"
fi

echo ""
warn "Sua chave PÚBLICA do GitHub está abaixo e em '$PUBLIC_KEY_TXT':"
echo "--------------------------------------------------------------------------------"
cat "${SSH_KEY}.pub"
echo "--------------------------------------------------------------------------------"

# ####################################################################################
# ///// FIM
# ####################################################################################

log "Pós-instalação concluída!"

finish_checklist
ok "Checklist salvo em: $CHECKLIST_FILE"

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