# ####################################################################################
# ///// APLICATIVOS (FLATPAK) — INSTALL ARCH LINUX
# ####################################################################################
# Origem: my-setup/bootstrap.sh (blocos "APPS", "CODE EDITOR (ZED)",
# "NAVEGADORES", "ANKI" e "OBSIDIAN").
# ####################################################################################

# Garante a biblioteca comum carregada (permite execução isolada do script).
[ -n "${MY_SETUP_COMMON_LOADED:-}" ] || . "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

# ####################################################################################
# ///// APPS
# ####################################################################################

log "Validação de Sistema e Instalação de Flatpaks"

# Lista de pacotes (instalados em uma única chamada bulk ao Flathub para
# reduzir a carga no servidor e evitar timeouts em máquinas mais simples).
FLATPAKS=(
    dev.zed.Zed
    io.dbeaver.DBeaverCommunity
    com.discordapp.Discord
    com.spotify.Client
    net.ankiweb.Anki
    com.google.Chrome
    app.zen_browser.zen
    md.obsidian.Obsidian
)

# Checa se há conexão com a internet e alcance ao Flathub
check_network() {
    step "Verificando conexão com a internet e Flathub..."
    while true; do
        # Testa DNS público (Cloudflare) e resolução de nome do Flathub
        if ping -c 1 -W 2 1.1.1.1 >/dev/null 2>&1 && ping -c 1 -W 2 flathub.org >/dev/null 2>&1; then
            ok "Conexão com a rede estabelecida!"
            break
        else
            warn "Sem conexão com a internet ou Flathub inacessível. Aguardando 10 segundos..."
            sleep 10
        fi
    done
}

# Checa se há espaço livre em disco (Mínimo de 5GB livres na / ou no /var)
check_disk_space() {
    step "Verificando espaço em disco..."
    local min_space_gb=5
    # Obtém o espaço livre em KB no diretório de instalação do Flatpak (geralmente /var)
    local free_space_kb=$(df -k /var | awk 'NR==2 {print $4}')
    local free_space_gb=$((free_space_kb / 1024 / 1024))

    if [ "$free_space_gb" -lt "$min_space_gb" ]; then
        warn "Pouco espaço em disco! Apenas ${free_space_gb}GB disponíveis (Mínimo recomendado: ${min_space_gb}GB)."
        return 1
    fi

    ok "Espaço em disco OK: ${free_space_gb}GB disponíveis."
    return 0
}

# Executa as checagens preventivas
check_network

if ! check_disk_space; then
    warn "Instalação abortada para evitar falhas por falta de espaço em disco."
    exit 1
fi

# Loop de download tolerante a falhas e timeouts de rede
step "Iniciando a instalação dos pacotes Flatpak..."
attempt=1

while true; do
    echo "Baixando pacotes (Tentativa $attempt)..."

    if flatpak install --assumeyes flathub "${FLATPAKS[@]}"; then
        ok "Todos os aplicativos Flatpak foram instalados com sucesso!"
        break
    fi

    warn "Ocorreu um timeout ou desconexão temporária."

    # Valida a rede antes de reiniciar a tentativa
    check_network

    attempt=$((attempt + 1))
    echo "Reiniciando download de onde parou em 5 segundos..."
    sleep 5
done

# ####################################################################################
# ///// CONFIGURAÇÃO PÓS-INSTALAÇÃO DOS FLATPAKS
# ####################################################################################
# Os flatpaks acima já foram instalados em bulk. As seções a seguir aplicam
# apenas as permissões, overrides e scripts específicos de cada aplicativo.

# ####################################################################################
# ///// CODE EDITOR (ZED)
# ####################################################################################

log "Zed (Code Editor)"

ZED_CONFIG_DIR="$HOME/.var/app/dev.zed.Zed/config/zed"
SOURCE_ZED_SETTINGS="$SCRIPT_DIR/zed/settings.json"
TARGET_ZED_SETTINGS="$ZED_CONFIG_DIR/settings.json"

if [ -f "$SOURCE_ZED_SETTINGS" ]; then
    step "Copiando configurações do Zed..."
    # Cria a estrutura de pastas do Flatpak caso não exista
    mkdir -p "$ZED_CONFIG_DIR"
    cp "$SOURCE_ZED_SETTINGS" "$TARGET_ZED_SETTINGS"
    ok "settings.json copiado para $TARGET_ZED_SETTINGS"
else
    warn "settings.json não encontrado em $SOURCE_ZED_SETTINGS"
fi

ok "Zed configurado."

# ####################################################################################
# ///// NAVEGADORES
# ####################################################################################

log "Navegadores (Chrome e Zen)"

step "Aplicando permissões e tema no Zen Browser e Chrome..."
SHARED_DIR="$HOME/flatpaks-share"
mkdir -p "$SHARED_DIR"
sudo flatpak override --env=GTK_THEME=Materia-dark app.zen_browser.zen
sudo flatpak override --filesystem="$SHARED_DIR" app.zen_browser.zen
sudo flatpak override --filesystem="$SHARED_DIR" com.google.Chrome

ok "Navegadores configurados."

# ####################################################################################
# ///// ANKI
# ####################################################################################

log "Anki"

step "Configurando diretório de dados do Anki..."
mkdir -p "$HOME/documents/anki/"
flatpak override --user --filesystem="$HOME/documents/anki" net.ankiweb.Anki || warn "Falha ao configurar filesystem do Anki."
flatpak override --user --env=ANKI_BASE="$HOME/documents/anki" net.ankiweb.Anki || warn "Falha ao configurar ANKI_BASE."

ok "Anki configurado."

# ####################################################################################
# ///// OBSIDIAN
# ####################################################################################

log "Obsidian"

step "Criando diretórios necessários..."
mkdir -p "$HOME/documents/ocarina-of-time/"
mkdir -p "$HOME/scripts/"
mkdir -p "$HOME/.config/systemd/user"
mkdir -p "$BIN_DST_DIR"

step "Concedendo acesso ao Vault no Flatpak..."
flatpak override --user --filesystem="$HOME/documents/ocarina-of-time" md.obsidian.Obsidian || warn "Falha ao configurar filesystem do Obsidian."

step "Copiando script de sincronização do Rclone..."
if [ -f "$SCRIPT_DIR/obsidian-rclone/sync-obsidian.sh" ]; then
    # Preserva a extensão .sh no código-fonte para que editores identifiquem a sintaxe e o ícone do Shell Script.
    # No destino ($BIN_DST_DIR), a extensão é removida para seguir a convenção POSIX/Linux de comandos binários
    # e simplificar a chamada no Systemd e no terminal (ex: rodar apenas 'sync-obsidian' em vez de 'sync-obsidian.sh').
    cp "$SCRIPT_DIR/obsidian-rclone/sync-obsidian.sh" "$BIN_DST_DIR/sync-obsidian"
    chmod +x "$BIN_DST_DIR/sync-obsidian"
    ok "sync-obsidian.sh copiado para $BIN_DST_DIR/sync-obsidian"
else
    warn "sync-obsidian.sh não encontrado em $SCRIPT_DIR/obsidian-rclone/"
fi

step "Copiando serviço systemd do Obsidian Sync..."
if [ -f "$SCRIPT_DIR/obsidian-rclone/obsidian-sync.service" ]; then
    cp "$SCRIPT_DIR/obsidian-rclone/obsidian-sync.service" "$HOME/.config/systemd/user/obsidian-sync.service"
    ok "obsidian-sync.service copiado para ~/.config/systemd/user/"
else
    warn "obsidian-sync.service não encontrado em $SCRIPT_DIR/obsidian-rclone/"
fi

step "Ativando serviço no Systemd..."
systemctl --user daemon-reload || warn "systemctl daemon-reload falhou."
systemctl --user enable --now obsidian-sync.service || warn "Não foi possível ativar obsidian-sync.service."

ok "Obsidian e sincronização configurados."