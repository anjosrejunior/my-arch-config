# ####################################################################################
# ///// ARQUIVOS E VISUALIZAÇÃO — INSTALL ARCH LINUX
# ####################################################################################
# Origem: my-setup/bootstrap.sh (blocos "THUNAR E FERRAMENTAS DE ARQUIVOS",
# "VISUALIZADORES" e "RCLONE").
# ####################################################################################

# Garante a biblioteca comum carregada (permite execução isolada do script).
[ -n "${MY_SETUP_COMMON_LOADED:-}" ] || . "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

# ####################################################################################
# ///// THUNAR E FERRAMENTAS DE ARQUIVOS
# ####################################################################################

log "Thunar e Ferramentas de Arquivos"

step "Instalando Thunar e utilitários..."
sudo pacman -S --needed --noconfirm \
    thunar \
    thunar-archive-plugin \
    thunar-volman \
    tumbler \
    gvfs \
    xarchiver \
    unzip \
    p7zip \
    unrar \
    tar \
    gzip \
    bzip2

ok "Thunar e utilitários instalados."

# ####################################################################################
# ///// VISUALIZADORES
# ####################################################################################

log "Visualizadores (Mpv, Feh, FFmpeg)"

step "Instalando mpv, ffmpeg e feh..."
sudo pacman -S --needed --noconfirm mpv ffmpeg feh

ok "Visualizadores instalados."

# ####################################################################################
# ///// RCLONE
# ####################################################################################

log "Rclone"

step "Instalando rclone..."
sudo pacman -S --needed --noconfirm rclone

ok "Rclone instalado."