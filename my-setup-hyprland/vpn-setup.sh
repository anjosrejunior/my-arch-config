#!/usr/bin/env bash
# ####################################################################################
# ///// VPN WIREGUARD — IMPORTAÇÃO DA CONEXÃO WG0 NO NETWORKMANAGER
# ####################################################################################
# Importa um perfil WireGuard (.conf) como conexão 'wg0' no NetworkManager.
# A conexão aparece no applet da bandeja da Waybar e no menu vpn-menu (SUPER + W).
# Script avulso: não faz parte do install.sh nem do post-install.sh.
#
# Uso:
#   ./vpn-setup.sh /caminho/para/wg0.conf
#
# O arquivo .conf contém a chave privada da VPN: não o coloque no repositório.
# ####################################################################################

set -Eeuo pipefail

# ---- Carrega a biblioteca comum (funções, checklist, sudo-refresh) ----
MY_SETUP_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "$MY_SETUP_DIR/scripts/lib/common.sh"

NOME_CONEXAO="wg0"

# ####################################################################################
# ///// ENTRADA
# ####################################################################################

log "Importação da VPN WireGuard"

WG_CONF_SRC="${1:-}"
if [ -z "$WG_CONF_SRC" ]; then
    read -rp "Caminho do arquivo .conf do WireGuard: " WG_CONF_SRC
fi

# Expande '~' manualmente (o read não faz isso).
WG_CONF_SRC="${WG_CONF_SRC/#\~/$HOME}"

if [ ! -f "$WG_CONF_SRC" ]; then
    err "Arquivo não encontrado: $WG_CONF_SRC"
    exit 1
fi

ok "Arquivo encontrado: $WG_CONF_SRC"

# ####################################################################################
# ///// DEPENDÊNCIAS
# ####################################################################################

log "Dependências (NetworkManager e WireGuard)"

step "Instalando networkmanager e wireguard-tools (se faltarem)..."
sudo pacman -S --needed --noconfirm networkmanager wireguard-tools

if ! systemctl is-active --quiet NetworkManager; then
    err "NetworkManager não está ativo. Ative com: sudo systemctl enable --now NetworkManager"
    exit 1
fi

ok "NetworkManager ativo."

# ####################################################################################
# ///// IMPORTAÇÃO
# ####################################################################################

log "Conexão $NOME_CONEXAO"

if nmcli -t -f NAME connection show | grep -qx "$NOME_CONEXAO"; then
    ok "Conexão $NOME_CONEXAO já existe no NetworkManager. Nada a fazer."
else
    step "Importando $WG_CONF_SRC no NetworkManager..."
    sudo nmcli connection import type wireguard file "$WG_CONF_SRC"

    if nmcli -t -f NAME connection show | grep -qx "$NOME_CONEXAO"; then
        ok "Conexão $NOME_CONEXAO importada."
    else
        warn "Importado, mas a conexão não se chama '$NOME_CONEXAO'. Renomeie com: sudo nmcli connection modify <nome> connection.id $NOME_CONEXAO"
    fi
fi

# ####################################################################################
# ///// FIM
# ####################################################################################

step "Para ligar/desligar: SUPER + W (vpn-menu) ou nmcli connection up|down $NOME_CONEXAO"
warn "O arquivo original ($WG_CONF_SRC) contém a chave privada. Apague-o se não precisar mais dele."

finish_checklist
ok "Checklist salvo em: $CHECKLIST_FILE"
