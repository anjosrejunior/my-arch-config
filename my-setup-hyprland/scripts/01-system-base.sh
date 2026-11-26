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
    noto-fonts-cjk \
    noto-fonts-emoji \
    ttf-nerd-fonts-symbols-common \
    ttf-jetbrains-mono-nerd

step "Instalando FUSE 2/3 e GTK 3 (compatibilidade com apps que ainda precisam deles)..."
sudo pacman -S --needed --noconfirm fuse2 fuse3 gtk3

ok "Pacotes base instalados."

step "Configurando o micro (softwrap)..."
MICRO_SRC="$SCRIPT_DIR/micro/settings.json"
MICRO_DST_DIR="$HOME/.config/micro"
MICRO_DST="$MICRO_DST_DIR/settings.json"

mkdir -p "$MICRO_DST_DIR"

if [ ! -f "$MICRO_DST" ]; then
    # Sem arquivo prévio: copia a config do repositório.
    cp "$MICRO_SRC" "$MICRO_DST"
    ok "settings.json criado em $MICRO_DST"
else
    # Já existe: só liga o softwrap, preservando as outras opções do usuário.
    sudo pacman -S --needed --noconfirm jq
    if jq '.softwrap = true' "$MICRO_DST" > "$MICRO_DST.tmp" && mv "$MICRO_DST.tmp" "$MICRO_DST"; then
        ok "softwrap ativado em $MICRO_DST"
    else
        rm -f "$MICRO_DST.tmp"
        warn "Não foi possível alterar $MICRO_DST (JSON inválido?). Adicione \"softwrap\": true manualmente."
    fi
fi

# ####################################################################################
# ///// SYSTEM MONITOR
# ####################################################################################

log "System Monitor (Btop)"

step "Instalando btop..."
sudo pacman -S --needed --noconfirm btop

step "Instalando pacman-contrib (paccache, usado na limpeza de disco)..."
sudo pacman -S --needed --noconfirm pacman-contrib

ok "btop instalado."