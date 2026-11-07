# ####################################################################################
# ///// ARQUIVOS E VISUALIZAÇÃO — INSTALL ARCH LINUX + KDE PLASMA
# ####################################################################################
# Usa os aplicativos nativos do KDE (Dolphin/Ark) e instala apenas os
# backends de compactação, visualizadores e o Rclone.
# ####################################################################################

# Garante a biblioteca comum carregada (permite execução isolada do script).
[ -n "${MY_SETUP_COMMON_LOADED:-}" ] || . "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

# ####################################################################################
# ///// DOLPHIN, ARK E FERRAMENTAS DE ARQUIVOS
# ####################################################################################

log "Dolphin, Ark e Ferramentas de Arquivos"

step "Instalando gerenciador de arquivos, compactador e utilitários..."
sudo pacman -S --needed --noconfirm \
    dolphin \
    ark \
    unzip \
    p7zip \
    unrar \
    tar \
    gzip \
    bzip2

ok "Dolphin, Ark e utilitários instalados."

# ####################################################################################
# ///// VISUALIZADORES
# ####################################################################################

log "Visualizadores e Reprodutores de Mídia"

step "Instalando visualizadores de imagem, documentos e reprodutores..."
sudo pacman -S --needed --noconfirm \
    ffmpeg \
    gwenview \
    okular \
    haruna \
    kdegraphics-thumbnailers \
    ffmpegthumbs

ok "Visualizadores instalados."

# ####################################################################################
# ///// RCLONE
# ####################################################################################

log "Rclone"

step "Instalando rclone..."
sudo pacman -S --needed --noconfirm rclone

ok "Rclone instalado."
