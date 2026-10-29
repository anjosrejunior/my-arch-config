# ####################################################################################
# ///// SISTEMA BASE — INSTALL ARCH LINUX + KDE PLASMA
# ####################################################################################
# Atualiza o sistema e instala pacotes base usados no desktop: editor de
# terminal, Kitty, fontes, monitor de sistema e NetworkManager.
# ####################################################################################

# Garante a biblioteca comum carregada (permite execução isolada do script).
[ -n "${MY_SETUP_COMMON_LOADED:-}" ] || . "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

# ####################################################################################
# ///// INIT — ATUALIZAÇÃO DO SISTEMA E PACOTES BASE
# ####################################################################################

log "Atualização do Sistema e Pacotes Base"

step "Atualizando lista de mirrors (Brasil)..."
curl -s "https://archlinux.org/mirrorlist/?country=BR&protocol=https&use_mirror_status=on" | sed 's/^#Server/Server/' | sudo tee /etc/pacman.d/mirrorlist > /dev/null

step "Atualizando o sistema e bases de dados..."
sudo pacman -Syyu --noconfirm

step "Instalando editor de terminal, Kitty e fontes..."
sudo pacman -S --needed --noconfirm \
    micro \
    kitty \
    noto-fonts \
    noto-fonts-cjk \
    noto-fonts-emoji \
    ttf-nerd-fonts-symbols-common \
    ttf-jetbrains-mono-nerd

ok "Pacotes base instalados."

# ####################################################################################
# ///// SYSTEM MONITOR
# ####################################################################################

log "System Monitor (Btop)"

step "Instalando btop..."
sudo pacman -S --needed --noconfirm btop

ok "btop instalado."

# ####################################################################################
# ///// REDE (NETWORKMANAGER)
# ####################################################################################

log "Rede (NetworkManager)"

step "Instalando NetworkManager, applet do Plasma e suporte a modem e Wi-Fi..."
sudo pacman -S --needed --noconfirm networkmanager plasma-nm modemmanager usb_modeswitch wpa_supplicant

# O "enable --now" já inicia o serviço; um restart logo depois derrubaria a conexão atual.
step "Ativando NetworkManager no Systemd..."
sudo systemctl enable --now NetworkManager

ok "NetworkManager instalado e ativado."
