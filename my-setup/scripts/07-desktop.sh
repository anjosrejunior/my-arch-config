# ####################################################################################
# ///// ÁREA DE TRABALHO — INSTALL ARCH LINUX
# ####################################################################################
# Origem: my-setup/bootstrap.sh (blocos "WAYBAR", "ROFI", "DARK THEME" e
# "WALLPAPER").
# ####################################################################################

# Garante a biblioteca comum carregada (permite execução isolada do script).
[ -n "${MY_SETUP_COMMON_LOADED:-}" ] || . "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

# ####################################################################################
# ///// WAYBAR
# ####################################################################################

log "Waybar"

step "Instalando Waybar..."
sudo pacman -S --needed --noconfirm waybar

WAYBAR_SRC_DIR="$SCRIPT_DIR/waybar"
WAYBAR_DST_DIR="$HOME/.config/waybar"

step "Criando diretório de destino..."
mkdir -p "$WAYBAR_DST_DIR"

if [ -d "$WAYBAR_SRC_DIR" ]; then
    step "Copiando configurações do Waybar..."

    if [ -f "$WAYBAR_SRC_DIR/config.jsonc" ]; then
        cp "$WAYBAR_SRC_DIR/config.jsonc" "$WAYBAR_DST_DIR/config.jsonc"
        ok "config.jsonc copiado para $WAYBAR_DST_DIR/"
    else
        warn "config.jsonc não encontrado em $WAYBAR_SRC_DIR/"
    fi

    if [ -f "$WAYBAR_SRC_DIR/style.css" ]; then
        cp "$WAYBAR_SRC_DIR/style.css" "$WAYBAR_DST_DIR/style.css"
        ok "style.css copiado para $WAYBAR_DST_DIR/"
    else
        warn "style.css não encontrado em $WAYBAR_SRC_DIR/"
    fi
else
    warn "Diretório $WAYBAR_SRC_DIR/ não encontrado; configurações do Waybar não copiadas."
fi

ok "Waybar configurado."

# ####################################################################################
# ///// ROFI
# ####################################################################################

log "Rofi"

step "Instalando Rofi..."
if ! command -v rofi &>/dev/null; then
    sudo pacman -S --needed --noconfirm rofi
fi

ROFI_SRC_DIR="$SCRIPT_DIR/rofi"
ROFI_DST_DIR="$HOME/.config/rofi"

step "Criando diretórios de destino..."
mkdir -p "$ROFI_DST_DIR"
mkdir -p "$BIN_DST_DIR"

if [ -d "$ROFI_SRC_DIR" ]; then
    step "Copiando configurações do Rofi..."

    if [ -f "$ROFI_SRC_DIR/config.rasi" ]; then
        cp "$ROFI_SRC_DIR/config.rasi" "$ROFI_DST_DIR/config.rasi"
        ok "config.rasi copiado para $ROFI_DST_DIR/"
    else
        warn "config.rasi não encontrado em $ROFI_SRC_DIR/"
    fi

    if [ -f "$ROFI_SRC_DIR/powermenu.rasi" ]; then
        cp "$ROFI_SRC_DIR/powermenu.rasi" "$ROFI_DST_DIR/powermenu.rasi"
        ok "powermenu.rasi copiado para $ROFI_DST_DIR/"
    else
        warn "powermenu.rasi não encontrado em $ROFI_SRC_DIR/"
    fi

    if [ -f "$ROFI_SRC_DIR/rofi-powermenu.sh" ]; then
        # Preserva a extensão .sh no código-fonte para que editores (ex: Zed) identifiquem a sintaxe e o ícone do Shell Script.
        # No destino ($BIN_DST_DIR), a extensão é removida para seguir a convenção POSIX/Linux de comandos binários
        # e simplificar a chamada no Systemd e no terminal (ex: rodar apenas 'rofi-powermenu' em vez de 'rofi-powermenu.sh').
        cp "$ROFI_SRC_DIR/rofi-powermenu.sh" "$BIN_DST_DIR/rofi-powermenu"
        chmod +x "$BIN_DST_DIR/rofi-powermenu"
        ok "rofi-powermenu.sh copiado e tornado executável em $BIN_DST_DIR/rofi-powermenu"
    else
        warn "rofi-powermenu.sh não encontrado em $ROFI_SRC_DIR/"
    fi
else
    warn "Diretório $ROFI_SRC_DIR/ não encontrado; configurações do Rofi não copiadas."
fi

ok "Rofi configurado."

# ####################################################################################
# ///// DARK THEME
# ####################################################################################

log "Tema Escuro (Dark Theme)"

step "Instalando pacotes de tema..."
sudo pacman -S --needed --noconfirm materia-gtk-theme qt5ct qt6ct kvantum

step "Aplicando tema via gsettings..."
if command -v gsettings &>/dev/null; then
    gsettings set org.gnome.desktop.interface gtk-theme 'Materia-dark' || warn "Falha ao definir gtk-theme (sem sessão D-Bus?)."
    gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' || warn "Falha ao definir color-scheme (sem sessão D-Bus?)."
    ok "Tema escuro aplicado."
else
    warn "gsettings não encontrado; tema não aplicado."
fi

ok "Tema escuro configurado."

# ####################################################################################
# ///// WALLPAPER
# ####################################################################################

log "Wallpaper (Hyprpaper)"

step "Instalando hyprpaper..."
sudo pacman -S --needed --noconfirm hyprpaper

step "Criando diretórios..."
mkdir -p "$HOME/wallpapers"
mkdir -p "$HOME/.config/hypr"

if [ -f "$SCRIPT_DIR/wallpaper.jpg" ]; then
    cp "$SCRIPT_DIR/wallpaper.jpg" "$HOME/wallpapers/wallpaper.jpg"
    ok "wallpaper.jpg copiado para $HOME/wallpapers/"
else
    warn "wallpaper.jpg não encontrado em $SCRIPT_DIR/"
fi

step "Copiando configuração do hyprpaper..."
HYPRPAPER_SRC="$SCRIPT_DIR/hypr/hyprpaper.conf"
HYPRPAPER_DST="$HOME/.config/hypr/hyprpaper.conf"
if [ -f "$HYPRPAPER_SRC" ]; then
    cp "$HYPRPAPER_SRC" "$HYPRPAPER_DST"
    ok "hyprpaper.conf copiado para $HYPRPAPER_DST"
else
    warn "hyprpaper.conf não encontrado em $HYPRPAPER_SRC"
fi

ok "Wallpaper configurado."