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

step "Instalando NetworkManager, applet (bandeja) e WireGuard..."
sudo pacman -S --needed --noconfirm networkmanager network-manager-applet wireguard-tools openresolv

step "Ativando NetworkManager no Systemd..."
sudo systemctl enable --now NetworkManager

# Não pode haver outro gerenciador de rede disputando as mesmas interfaces.
if systemctl is-enabled --quiet systemd-networkd 2>/dev/null || systemctl is-active --quiet systemd-networkd; then
    warn "systemd-networkd está ativo. Desative-o (sudo systemctl disable --now systemd-networkd) para não conflitar com o NetworkManager."
fi

# Se o Wi-Fi usa iwd (iwctl), o NetworkManager precisa usar o backend iwd.
if systemctl is-enabled --quiet iwd 2>/dev/null || systemctl is-active --quiet iwd; then
    step "iwd detectado: configurando o NetworkManager com wifi.backend=iwd..."
    sudo mkdir -p /etc/NetworkManager/conf.d
    printf '[device]\nwifi.backend=iwd\n' | sudo tee /etc/NetworkManager/conf.d/wifi.conf > /dev/null
    ok "wifi.backend=iwd gravado em /etc/NetworkManager/conf.d/wifi.conf (vale após reiniciar o NetworkManager)."
fi

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