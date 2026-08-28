# ####################################################################################
# ///// SISTEMA BASE — INSTALL ARCH LINUX
# ####################################################################################
# Origem: my-setup/bootstrap.sh (blocos "INIT — ATUALIZAÇÃO DO SISTEMA E
# PACOTES BASE" e "SYSTEM MONITOR").
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

step "Instalando editor de terminal e fontes..."
sudo pacman -S --needed --noconfirm \
    micro \
    noto-fonts \
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