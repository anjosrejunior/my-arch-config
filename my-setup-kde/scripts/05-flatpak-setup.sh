# ####################################################################################
# ///// FLATPAK — INSTALL ARCH LINUX + KDE PLASMA
# ####################################################################################
# Instala o Flatpak, o portal do KDE e adiciona o repositório Flathub.
# ####################################################################################

# Garante a biblioteca comum carregada (permite execução isolada do script).
[ -n "${MY_SETUP_COMMON_LOADED:-}" ] || . "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

# ####################################################################################
# ///// FLATPAK
# ####################################################################################

log "Flatpak"

step "Instalando Flatpak e integração com o KDE..."
sudo pacman -S --needed --noconfirm flatpak xdg-desktop-portal-kde xdg-utils

step "Adicionando repositório Flathub..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || warn "Flathub já existe ou não foi possível adicionar."

flatpak update --appstream

ok "Flatpak configurado."
