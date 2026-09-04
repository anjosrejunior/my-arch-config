# ####################################################################################
# ///// REDE E SEGURANÇA — INSTALL ARCH LINUX
# ####################################################################################
# Origem: my-setup/bootstrap.sh (blocos "FIREWALL", "NETWORK" e "KEYRING").
# ####################################################################################

# Garante a biblioteca comum carregada (permite execução isolada do script).
[ -n "${MY_SETUP_COMMON_LOADED:-}" ] || . "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

# ####################################################################################
# ///// FIREWALL
# ####################################################################################

log "Configuração do Firewall (UFW)"

step "Instalando UFW..."
sudo pacman -S --needed --noconfirm ufw

step "Habilitando serviço no Systemd..."
sudo systemctl enable --now ufw.service

step "Definindo regras padrão..."
sudo ufw default deny incoming
sudo ufw default allow outgoing

step "Ativando firewall..."
sudo ufw --force enable

ok "Firewall configurado e ativado."

# ####################################################################################
# ///// NETWORK
# ####################################################################################

log "Rede (NetworkManager + WireGuard)"

step "Instalando NetworkManager e WireGuard..."
sudo pacman -S --needed --noconfirm networkmanager wireguard-tools openresolv

step "Ativando NetworkManager no Systemd..."
sudo systemctl enable --now NetworkManager

step "Aguardando conexão de rede..."
if ! nm-online -q --timeout=30; then
    err "NetworkManager não conseguiu estabelecer conexão."
    exit 1
fi

step "Verificando resolução DNS..."
if ! getent hosts archlinux.org >/dev/null 2>&1; then
    err "DNS não está funcionando."
    exit 1
fi

ok "Rede e DNS disponíveis."

step "Desativando espera de rede no boot..."
sudo systemctl disable NetworkManager-wait-online.service

ok "NetworkManager configurado."

# ####################################################################################
# ///// KEYRING
# ####################################################################################

log "GNOME Keyring"

step "Instalando GNOME Keyring e libsecret..."
sudo pacman -S --needed --noconfirm gnome-keyring libsecret

log "GNOME Keyring"

step "Ativando Sockets do Gnome-Keyring no Systemd (Global)..."
systemctl --global enable gnome-keyring-daemon.socket

ok "GNOME Keyring ativado com sucesso."

ok "GNOME Keyring instalado."