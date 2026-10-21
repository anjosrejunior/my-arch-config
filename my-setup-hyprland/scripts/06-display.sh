# ####################################################################################
# ///// DISPLAY E LOGIN — INSTALL ARCH LINUX
# ####################################################################################
# Origem: my-setup/bootstrap.sh (blocos "HYPRLAND", "NVIDIA DRIVERS",
# "UWSM", "GERENCIADOR DE LOGIN — GREETD + TUIGREET" e "LOCK SCREEN & SUPENSÃO").
# Usa NVIDIA_CHOICE coletado em 00-user-input.sh.
# ####################################################################################

# Garante a biblioteca comum carregada (permite execução isolada do script).
[ -n "${MY_SETUP_COMMON_LOADED:-}" ] || . "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

# ####################################################################################
# ///// HYPRLAND
# ####################################################################################

log "Hyprland"

step "Instalando Hyprland e dependências..."
sudo pacman -S --needed --noconfirm \
    hyprland \
    kitty \
    mesa \
    lib32-mesa \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk \
    xdg-utils \
    linux-headers \
    linux-lts-headers

ok "Hyprland e dependências instalados."

step "Criando diretório de config do hyprland..."
mkdir -p "$HOME/.config/hypr"

step "Copiando hyprland.lua..."

if [ "${NVIDIA_CHOICE}" = "1050ti" ]; then
    HYPRLAND_SRC_NAME="hyprland-1050ti.lua"
else
    HYPRLAND_SRC_NAME="hyprland.lua"
fi

HYPRLAND_SRC="$SCRIPT_DIR/hypr/$HYPRLAND_SRC_NAME"
HYPRLAND_DST="$HOME/.config/hypr/hyprland.lua"

if [ -f "$HYPRLAND_SRC" ]; then
    mkdir -p "$HOME/.config/hypr"
    cp "$HYPRLAND_SRC" "$HYPRLAND_DST"
    ok "$HYPRLAND_SRC_NAME copiado para $HYPRLAND_DST"
else
    warn "Arquivo de origem não encontrado em $HYPRLAND_SRC"
fi

# ####################################################################################
# ///// NVIDIA DRIVERS
# ####################################################################################

if [ "${NVIDIA_CHOICE}" = "1050ti" ]; then
    log "Instalando drivers e suporte NVIDIA..."

    echo "Instalando pacotes de suporte (libva, egl-wayland)..."
    sudo pacman -S --needed --noconfirm libva-nvidia-driver egl-wayland

    echo "Instalando drivers NVIDIA 580xx via YAY..."
    yay -S --noconfirm nvidia-580xx-dkms nvidia-580xx-utils lib32-nvidia-580xx-utils

    ok "Drivers NVIDIA instalados com sucesso."
else
    ok "Opção 'Sem NVIDIA' selecionada. Pulando a instalação de drivers."
fi

# ####################################################################################
# ///// UWSM
# ####################################################################################

log "UWSM (Universal Wayland Session Manager)"

step "Instalando UWSM..."
sudo pacman -S --needed --noconfirm uwsm

# ####################################################################################
# ///// GERENCIADOR DE LOGIN — GREETD + TUIGREET
# ####################################################################################

GREETD_SRC_DIR="$SCRIPT_DIR/greetd"

log "Gerenciador de Login (GreetD + Tuigreet)"

step "Instalando greetd e tuigreet..."
sudo pacman -S --needed --noconfirm greetd greetd-tuigreet

if [ -d "$GREETD_SRC_DIR" ]; then

    step "Copiando configuração do greetd..."
    if [ -f "$GREETD_SRC_DIR/config.toml" ]; then
        sudo mkdir -p /etc/greetd
        sudo cp "$GREETD_SRC_DIR/config.toml" /etc/greetd/config.toml
        sudo chmod 644 /etc/greetd/config.toml
        ok "config.toml copiado para /etc/greetd/"
    else
        warn "config.toml não encontrado em $GREETD_SRC_DIR/"
    fi

    step "Backup do PAM e configuração para auto-unlock do GNOME Keyring..."
    PAM_FILE="/etc/pam.d/greetd"

    if [ -f "$GREETD_SRC_DIR/greetd" ]; then
        if [ -f "$PAM_FILE" ]; then
            PAM_BACKUP="${PAM_FILE}.bak.$(date +%s)"
            sudo cp "$PAM_FILE" "$PAM_BACKUP"
            ok "Backup do PAM criado em: $PAM_BACKUP"
        fi

        sudo cp "$GREETD_SRC_DIR/greetd" "$PAM_FILE"
        sudo chmod 644 "$PAM_FILE"
        ok "Arquivo PAM greetd copiado para $PAM_FILE"
    else
        warn "Arquivo PAM $GREETD_SRC_DIR/greetd não encontrado/"
    fi

else
    warn "Diretório $GREETD_SRC_DIR/ não encontrado; configurações do greetd não copiadas."
fi

step "Definindo permissões do greeter e criando cache..."
sudo usermod -aG video,input greeter
sudo mkdir -p /var/cache/tuigreet
sudo chown -R greeter:greeter /var/cache/tuigreet

step "Habilitando serviço greetd..."
sudo systemctl enable greetd

ok "GreetD + Tuigreet configurados com sucesso."

# ####################################################################################
# ///// LOCK SCREEN & SUPENSÃO DE SISTEMA
# ####################################################################################

log "Lock Screen e Suspensão de Sistema"
warn "Seção ainda não implementada (placeholder)."