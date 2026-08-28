# ####################################################################################
# ///// MÍDIA E CAPTURA — INSTALL ARCH LINUX
# ####################################################################################
# Origem: my-setup/bootstrap.sh (blocos "AUDIO (PIPEWIRE)", "CLIPBOARD" e
# "OBS STUDIO & LOOPBACK").
# ####################################################################################

# Garante a biblioteca comum carregada (permite execução isolada do script).
[ -n "${MY_SETUP_COMMON_LOADED:-}" ] || . "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

# ####################################################################################
# ///// AUDIO (PIPEWIRE)
# ####################################################################################

log "Áudio (PipeWire)"

step "Removendo conflitos antigos de áudio..."
sudo pacman -Rdd --noconfirm jack2 2>/dev/null || true

step "Instalando PipeWire e ferramentas..."
sudo pacman -S --needed --noconfirm \
    pipewire \
    pipewire-alsa \
    pipewire-pulse \
    pipewire-jack \
    wireplumber \
    pavucontrol

ok "Áudio configurado."

# ####################################################################################
# ///// CLIPBOARD
# ####################################################################################

log "Clipboard e Captura de Tela"

step "Instalando wl-clipboard, grim e slurp..."
sudo pacman -S --needed --noconfirm wl-clipboard grim slurp

ok "Ferramentas de clipboard instaladas."

# ####################################################################################
# ///// OBS STUDIO & LOOPBACK
# ####################################################################################

log "OBS Studio e v4l2loopback"

step "Instalando OBS Studio e v4l2loopback..."
sudo pacman -S --needed --noconfirm obs-studio v4l2loopback-dkms

step "Configurando parâmetros do v4l2loopback no kernel..."
echo 'options v4l2loopback video_nr=10 card_label="OBS Virtual Camera" exclusive_caps=1' | sudo tee /etc/modprobe.d/v4l2loopback.conf > /dev/null
echo 'v4l2loopback' | sudo tee /etc/modules-load.d/v4l2loopback.conf > /dev/null
ok "Parâmetros do v4l2loopback salvos em /etc/modprobe.d/ e /etc/modules-load.d/"

step "Criando diretórios necessários..."
mkdir -p "$HOME/.config/systemd/user"
mkdir -p "$BIN_DST_DIR"

step "Copiando script do OBS Loopback..."
if [ -f "$SCRIPT_DIR/obs/obs-v4l2loopback.sh" ]; then
    # Preserva a extensão .sh no código-fonte para que editores (ex: Zed) identifiquem a sintaxe e o ícone do Shell Script.
    # No destino ($BIN_DST_DIR), a extensão é removida para seguir a convenção POSIX/Linux de comandos binários
    # e simplificar a chamada no Systemd e no terminal (ex: rodar apenas 'obs-v4l2loopback' em vez de 'obs-v4l2loopback.sh').
    cp "$SCRIPT_DIR/obs/obs-v4l2loopback.sh" "$BIN_DST_DIR/obs-v4l2loopback"
    chmod +x "$BIN_DST_DIR/obs-v4l2loopback"
    ok "obs-v4l2loopback.sh copiado e tornado executável em $BIN_DST_DIR/obs-v4l2loopback"
else
    warn "obs-v4l2loopback.sh não encontrado em $SCRIPT_DIR/obs/"
fi

step "Copiando serviço systemd do OBS Loopback..."
if [ -f "$SCRIPT_DIR/obs/obs-v4l2loopback.service" ]; then
    cp "$SCRIPT_DIR/obs/obs-v4l2loopback.service" "$HOME/.config/systemd/user/obs-v4l2loopback.service"
    ok "obs-v4l2loopback.service copiado para ~/.config/systemd/user/"
else
    warn "obs-v4l2loopback.service não encontrado em $SCRIPT_DIR/obs/"
fi

step "Ativando serviço no Systemd..."
systemctl --user daemon-reload || warn "systemctl daemon-reload falhou."
systemctl --user enable --now obs-v4l2loopback.service || warn "Não foi possível ativar obs-v4l2loopback.service."

ok "OBS Studio e v4l2loopback instalados e configurados."