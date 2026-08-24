#!/usr/bin/env bash
# ####################################################################################
# ///// BOOTSTRAP ARCH LINUX
# ####################################################################################
# Script de pós-instalação e configuração para Arch Linux + Hyprland.
# Executa: atualização do sistema, instalação de pacotes, configuração de
# ambiente gráfico (Hyprland/Waybar/Rofi), ferramentas de desenvolvimento
# (Node/UV/Docker) e aplicativos via Flatpak.
# ####################################################################################

set -Eeuo pipefail

# ---- Versões e checksums de instaladores remotos (atualizar ao mudar versão) ----
NVM_VERSION="0.40.6"
NVM_SHA256="2ef7e8d4373c1ffd70daa55f919f629e98a619543ffc0a8d892d77a5247e50e4"   # SHA-256 do install.sh do NVM; vazio = apenas exibir e prosseguir
UV_VERSION="0.12.5"
UV_SHA256="504511fbbbd811aeaba6738abc79408956b6c7da0ca35437b3dcc24a41efc111"    # SHA-256 do install.sh do UV; vazio = apenas exibir e prosseguir

# ---- Diretórios base (definidos uma única vez) ----
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DST_DIR="$HOME/.local/bin"

# ---- Funções de saída formatada ----
log()  {
    flush_section
    CURRENT_SECTION="$*"
    SECTION_STATUS="OK"
    SECTION_ISSUES=()
    printf '\n==> %s\n' "$*"
}
step() { printf '  -> %s\n' "$*"; }
ok()   { printf '  [ok] %s\n' "$*"; }
warn() {
    printf '  [aviso] %s\n' "$*" >&2
    [ "$SECTION_STATUS" = "OK" ] && SECTION_STATUS="AVISO"
    SECTION_ISSUES+=("- $*")
}
err()  {
    printf '  [erro] %s\n' "$*" >&2
    SECTION_STATUS="ERRO"
    SECTION_ISSUES+=("- $*")
}

# ---- Checklist em arquivo TXT ----
CHECKLIST_FILE="$HOME/bootstrap-checklist-$(date +%Y%m%d-%H%M%S).txt"
CHECKLIST_START="$(date '+%Y-%m-%d %H:%M:%S')"
CURRENT_SECTION=""
SECTION_STATUS="OK"
SECTION_ISSUES=()
TOTAL_OK=0
TOTAL_WARN=0
TOTAL_ERR=0

# Escreve o cabeçalho do checklist imediatamente.
{
    printf '==========================================\n'
    printf '  BOOTSTRAP ARCH LINUX — Checklist\n'
    printf '  Iniciado em: %s\n' "$CHECKLIST_START"
    printf '==========================================\n\n'
} > "$CHECKLIST_FILE"

# Registra (ou não) a seção atual no arquivo e reinicia o estado.
flush_section() {
    [ -z "$CURRENT_SECTION" ] && return 0
    local tag
    case "$SECTION_STATUS" in
        OK)    tag="[OK]";    TOTAL_OK=$((TOTAL_OK + 1))   ;;
        AVISO) tag="[AVISO]"; TOTAL_WARN=$((TOTAL_WARN + 1)) ;;
        ERRO)  tag="[ERRO]";  TOTAL_ERR=$((TOTAL_ERR + 1))  ;;
        *)     tag="[OK]";    TOTAL_OK=$((TOTAL_OK + 1))   ;;
    esac
    printf '%-8s %s\n' "$tag" "$CURRENT_SECTION" >> "$CHECKLIST_FILE"
    local issue
    for issue in "${SECTION_ISSUES[@]:-}"; do
        [ -n "$issue" ] && printf '        %s\n' "$issue" >> "$CHECKLIST_FILE"
    done
    CURRENT_SECTION=""
    SECTION_STATUS="OK"
    SECTION_ISSUES=()
}

# Finaliza o checklist escrevendo o rodapé com resumo e timestamp.
finish_checklist() {
    flush_section
    {
        printf '\n==========================================\n'
        printf '  Resumo: %d OK | %d AVISO | %d ERRO\n' "$TOTAL_OK" "$TOTAL_WARN" "$TOTAL_ERR"
        printf '  Finalizado em: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')"
        printf '==========================================\n'
    } >> "$CHECKLIST_FILE"
}

# ---- Pré-autenticação do sudo + refrescador em background ----
sudo -v
( while true; do sudo -v; sleep 50; done 2>/dev/null ) &
SUDO_REFRESH_PID=$!

# Mata o processo do sudo-refresh ao sair do script (mesmo em caso de erro)
trap 'kill "$SUDO_REFRESH_PID" 2>/dev/null || true' EXIT

# ---- Helper: verifica se o systemd --user está disponível ----
user_systemd_ok() {
    [ -d "/run/user/$(id -u)/systemd" ] && systemctl --user is-system-running >/dev/null 2>&1
}

cleanup() {
    if [ -n "${SUDO_REFRESH_PID:-}" ]; then
        kill -- "$SUDO_REFRESH_PID" 2>/dev/null || true
    fi
}
_CHECKLIST_FINISHED=0
finish_checklist_safe() {
    [ "$_CHECKLIST_FINISHED" -eq 0 ] || return 0
    _CHECKLIST_FINISHED=1
    finish_checklist
}
trap 'cleanup; finish_checklist_safe' EXIT INT TERM
trap 'flush_section; err "Falha na linha $LINENO (comando: $BASH_COMMAND)"; finish_checklist_safe' ERR

# ####################################################################################
# ///// GIT — PERFIL DO USUÁRIO
# ####################################################################################

log "Configuração do Perfil do Git"

while [ -z "${GIT_NAME:-}" ]; do
    read -rp "Digite o seu Nome para o Git: " GIT_NAME
    if [ -z "${GIT_NAME:-}" ]; then
        warn "O nome não pode ficar em branco."
    elif [[ "${GIT_NAME}" =~ [[:cntrl:]] ]]; then
        warn "O nome contém caracteres de controle inválidos."
        GIT_NAME=""
    fi
done

while [ -z "${GIT_EMAIL:-}" ] || [[ "${GIT_EMAIL}" != *@* ]]; do
    read -rp "Digite o seu E-mail para o Git: " GIT_EMAIL
    if [ -z "${GIT_EMAIL:-}" ]; then
        warn "O e-mail não pode ficar em branco."
    elif [[ "${GIT_EMAIL}" != *@* ]]; then
        warn "E-mail inválido (deve conter '@')."
        GIT_EMAIL=""
    fi
done

ok "Perfil do Git coletado: $GIT_NAME <$GIT_EMAIL>"

# ####################################################################################
# ///// SELEÇÃO DE DRIVERS DE VÍDEO
# ####################################################################################

log "Seleção de perfil de drivers"

NVIDIA_CHOICE=""

while [ -z "${NVIDIA_CHOICE}" ]; do
    echo "---------------------------------"
    echo "1) Sem drivers NVIDIA"
    echo "2) 1050ti (Drivers NVIDIA)"
    echo "---------------------------------"
    read -rp "Escolha uma opção [1 ou 2]: " OPTION

    case "${OPTION}" in
        1)
            NVIDIA_CHOICE="no_nvidia"
            ok "Opção selecionada: Sem drivers NVIDIA"
            ;;
        2)
            NVIDIA_CHOICE="1050ti"
            ok "Opção selecionada: Drivers NVIDIA (1050ti)"
            ;;
        *)
            warn "Opção inválida. Digite 1 ou 2."
            ;;
    esac
done

# ####################################################################################
# ///// INIT — ATUALIZAÇÃO DO SISTEMA E PACOTES BASE
# ####################################################################################

log "Atualização do Sistema e Pacotes Base"

step "Atualizando o sistema..."
sudo pacman -Syu --noconfirm

step "Instalando editor de terminal e fontes..."
sudo pacman -S --needed --noconfirm \
    micro \
    noto-fonts \
    ttf-nerd-fonts-symbols-common \
    ttf-jetbrains-mono-nerd

ok "Pacotes base instalados."

# ####################################################################################
# ///// ZSH
# ####################################################################################

log "Configuração do ZSH"

step "Instalando ZSH e plugins..."
sudo pacman -S --needed --noconfirm \
    zsh \
    starship \
    zsh-autosuggestions \
    zsh-syntax-highlighting \
    fzf

step "Criando arquivos de configuração..."
touch ~/.zshrc ~/.zprofile

step "Adicionando configurações ao ~/.zshrc..."
if ! grep -q "zsh-autosuggestions.zsh" ~/.zshrc 2>/dev/null; then
    cat >> ~/.zshrc << 'EOF'
# Plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Fuzzy Find
source <(fzf --zsh)

# Starship Prompt
eval "$(starship init zsh)"

# Inicia o ssh-agent se ainda não estiver rodando na sessão
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" > /dev/null
fi

# Alias do Zed
alias zeditor='flatpak run dev.zed.Zed'
EOF
    ok "Configurações adicionadas ao ~/.zshrc."
else
    ok "~/.zshrc já contém as configurações."
fi

step "Definindo ZSH como shell padrão..."
ZSH_PATH="$(command -v zsh || echo /usr/bin/zsh)"

# Detecta o usuário real (caso o script esteja rodando via sudo)
REAL_USER="${SUDO_USER:-$USER}"

if grep -q "$ZSH_PATH" /etc/shells 2>/dev/null; then
    # Usa sudo chsh especificando o usuário explicitamente
    if sudo chsh -s "$ZSH_PATH" "$REAL_USER"; then
        ok "ZSH definido como shell padrão para $REAL_USER."
        warn "Faça logout/login (ou reinicie a sessão) para a mudança ter efeito."
    else
        warn "Falha ao definir zsh. Tente manualmente: chsh -s $ZSH_PATH"
    fi
else
    warn "$ZSH_PATH não está em /etc/shells; shell padrão não alterado."
fi

# ####################################################################################
# ///// FIREWALL
# ####################################################################################

log "Configuração do Firewall (UFW)"

step "Instalando UFW..."
sudo pacman -S --needed --noconfirm ufw

step "Habilitando serviço no Systemd..."
sudo systemctl enable --now ufw.service

step "Definindo regras padrão..."
sudo ufw default deny incoming
sudo ufw default allow outgoing

step "Ativando firewall..."
sudo ufw --force enable

ok "Firewall configurado e ativado."

# ####################################################################################
# ///// SYSTEM MONITOR
# ####################################################################################

log "System Monitor (Btop)"

step "Instalando btop..."
sudo pacman -S --needed --noconfirm btop

ok "btop instalado."

# ####################################################################################
# ///// NETWORK
# ####################################################################################

log "Rede (NetworkManager + WireGuard)"

step "Instalando NetworkManager e WireGuard..."
sudo pacman -S --needed --noconfirm networkmanager wireguard-tools

step "Ativando NetworkManager no Systemd..."
sudo systemctl enable --now NetworkManager

ok "NetworkManager configurado."

# ####################################################################################
# ///// KEYRING
# ####################################################################################

log "GNOME Keyring"

step "Instalando GNOME Keyring e libsecret..."
sudo pacman -S --needed --noconfirm gnome-keyring libsecret

step "Ativando Gnome-Keyring no Systemd..."
systemctl --user enable gnome-keyring-daemon.service

ok "GNOME Keyring instalado."

# ####################################################################################
# ///// GIT CONFIG
# ####################################################################################

log "Configuração do Git"

step "Instalando git..."
sudo pacman -S --needed --noconfirm git less # Git and Less Terminal Pager

step "Aplicando configurações globais..."
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global init.defaultBranch master
git config --global pull.rebase true
git config --global push.autoSetupRemote true
git config --global color.ui auto
git config --global core.autocrlf input
git config --global core.editor micro

step "Configurando credential helper..."
if command -v git-credential-libsecret &>/dev/null || [ -x /usr/lib/git-core/git-credential-libsecret ]; then
    git config --global credential.helper libsecret
    ok "credential.helper definido como libsecret."
else
    warn "git-credential-libsecret não encontrado; credential.helper não configurado."
fi

step "Definindo aliases..."
git config --global alias.s "status -s"
git config --global alias.c "commit -m"
git config --global alias.l "log --oneline --graph --decorate --all"

ok "Configuração do Git aplicada com sucesso!"
step "Nome:  $(git config --global user.name)"
step "Email: $(git config --global user.email)"

# ####################################################################################
# ///// YAY (AUR HELPER)
# ####################################################################################

log "YAY (AUR Helper)"

step "Instalando base-devel e git..."
sudo pacman -S --needed --noconfirm base-devel git

if ! command -v yay &>/dev/null; then 
    step "YAY não encontrado. Clonando e compilando a versão mais recente..."
    ( 
        cd /tmp && rm -rf yay && git clone --depth 1 https://aur.archlinux.org/yay.git && cd yay
        makepkg -s --noconfirm --needed
        sudo pacman -U --noconfirm yay-*.pkg.tar.zst
    )
    ok "YAY instalado com sucesso."
else
    ok "YAY já está instalado."
fi

# ####################################################################################
# ///// FLATPAK
# ####################################################################################

log "Flatpak"

step "Instalando Flatpak..."
sudo pacman -S --needed --noconfirm flatpak

step "Adicionando repositório Flathub..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || warn "Flathub já existe ou não foi possível adicionar."

ok "Flatpak configurado."

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

step "Habilitando serviço Waybar no Systemd..."
if user_systemd_ok; then
    systemctl --user enable waybar.service || warn "Não foi possível habilitar waybar.service."
else
    warn "systemd --user indisponível; waybar.service não habilitado (faça logout/login após reiniciar)."
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

step "Ativando serviço hyprpaper no Systemd..."
if user_systemd_ok; then
    systemctl --user enable --now hyprpaper.service || warn "Não foi possível habilitar hyprpaper.service."
else
    warn "systemd --user indisponível; hyprpaper.service não habilitado (faça logout/login após reiniciar)."
fi

ok "Wallpaper configurado."

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
# ///// NODE (NVM)
# ####################################################################################

log "Node.js (NVM)"

export NVM_DIR="$HOME/.nvm"

if [ -s "$NVM_DIR/nvm.sh" ]; then
    \. "$NVM_DIR/nvm.sh"
fi

if command -v node &>/dev/null; then
    ok "Node.js já está instalado na máquina. Pulando etapa..."
else
    NVM_INSTALLER="/tmp/nvm-install-${NVM_VERSION}.sh"

    step "Baixando instalador do NVM v${NVM_VERSION}..."
    curl -fsSLo "$NVM_INSTALLER" "https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh"

    NVM_ACTUAL_SHA256="$(sha256sum "$NVM_INSTALLER" | awk '{print $1}')"
    if [ -n "$NVM_SHA256" ]; then
        if [ "$NVM_ACTUAL_SHA256" != "$NVM_SHA256" ]; then
            err "Checksum do NVM não confere. Esperado: $NVM_SHA256 | Obtido: $NVM_ACTUAL_SHA256"
            rm -f "$NVM_INSTALLER"
            exit 1
        fi
        ok "Checksum do NVM verificado."
    else
        warn "NVM_SHA256 não definido. Hash obtido: $NVM_ACTUAL_SHA256"
    fi

    step "Executando instalador do NVM..."
    bash "$NVM_INSTALLER"
    rm -f "$NVM_INSTALLER"

    step "Carregando NVM na sessão atual..."
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        \. "$NVM_DIR/nvm.sh"
        ok "NVM carregado."
    else
        err "nvm.sh não encontrado em $NVM_DIR. Instalação do NVM pode ter falhado."
        exit 1
    fi

    step "Instalando Node.js 24..."
    nvm install 24 || { err "Falha ao instalar Node.js 24 via NVM."; exit 1; }

    step "Ativando pnpm via Corepack..."
    if command -v corepack &>/dev/null; then
        export COREPACK_ENABLE_DOWNLOAD_PROMPT=0
        corepack enable pnpm
        ok "pnpm ativado via Corepack."
    else
        warn "Corepack não encontrado; pnpm não ativado."
    fi

    ok "Node.js instalado com sucesso."
fi

# ####################################################################################
# ///// UV (Astral)
# ####################################################################################

log "UV (Astral) v${UV_VERSION}"

UV_INSTALLER="/tmp/uv-install-${UV_VERSION}.sh"

step "Baixando instalador do UV v${UV_VERSION}..."
curl -fsSLo "$UV_INSTALLER" "https://releases.astral.sh/github/uv/releases/download/${UV_VERSION}/uv-installer.sh"

UV_ACTUAL_SHA256="$(sha256sum "$UV_INSTALLER" | awk '{print $1}')"
if [ -n "$UV_SHA256" ]; then
    if [ "$UV_ACTUAL_SHA256" != "$UV_SHA256" ]; then
        err "Checksum do UV não confere. Esperado: $UV_SHA256 | Obtido: $UV_ACTUAL_SHA256"
        rm -f "$UV_INSTALLER"
        exit 1
    fi
    ok "Checksum do UV verificado."
else
    warn "UV_SHA256 não definido. Hash obtido: $UV_ACTUAL_SHA256"
fi

step "Executando instalador do UV..."
sh "$UV_INSTALLER"
rm -f "$UV_INSTALLER"

ok "UV v${UV_VERSION} instalado."

# ####################################################################################
# ///// DOCKER
# ####################################################################################

log "Docker"

step "Instalando Docker e complementos..."
sudo pacman -S --needed --noconfirm \
    docker \
    docker-compose \
    docker-buildx

step "Habilitando serviço Docker no Systemd..."
sudo systemctl enable --now docker

step "Adicionando usuário atual ao grupo docker..."
sudo usermod -aG docker "$USER" || warn "Não foi possível adicionar $USER ao grupo docker."
warn "Reinicie a sessão (logout/login) para o grupo docker ter efeito."

ok "Docker configurado."

# ####################################################################################
# ///// CODE EDITOR (ZED)
# ####################################################################################

log "Zed (Code Editor)"

step "Instalando Zed via Flatpak..."
# O timeout evita falhas em downloads pesados de runtimes
flatpak install --assumeyes --http-timeout=60 flathub dev.zed.Zed

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
if user_systemd_ok; then
    systemctl --user daemon-reload || warn "systemctl daemon-reload falhou."
    systemctl --user enable --now obs-v4l2loopback.service || warn "Não foi possível ativar obs-v4l2loopback.service."
else
    warn "systemd --user indisponível; obs-v4l2loopback.service não ativado (faça logout/login após reiniciar)."
fi

ok "OBS Studio e v4l2loopback instalados e configurados."

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

# ####################################################################################
# ///// NAVEGADORES
# ####################################################################################

log "Navegadores (Chrome e Zen)"

step "Instalando Google Chrome via Flatpak..."
flatpak install --assumeyes flathub com.google.Chrome

step "Instalando Zen Browser via Flatpak..."
flatpak install --assumeyes flathub app.zen_browser.zen

step "Aplicando permissões e tema no Zen Browser e Chrome..."
SHARED_DIR="$HOME/flatpaks-share"
mkdir -p "$SHARED_DIR"
sudo flatpak override --env=GTK_THEME=Materia-dark app.zen_browser.zen
sudo flatpak override --filesystem="$SHARED_DIR" app.zen_browser.zen
sudo flatpak override --filesystem="$SHARED_DIR" com.google.Chrome

ok "Navegadores instalados."

# ####################################################################################
# ///// DBEAVER
# ####################################################################################

log "DBeaver Community"

step "Instalando DBeaver via Flatpak..."
flatpak install --assumeyes flathub io.dbeaver.DBeaverCommunity

ok "DBeaver instalado."

# ####################################################################################
# ///// DISCORD
# ####################################################################################

log "Discord"

step "Instalando Discord via Flatpak..."
flatpak install --assumeyes flathub com.discordapp.Discord

ok "Discord instalado."

# ####################################################################################
# ///// SPOTIFY
# ####################################################################################

log "Spotify"

step "Instalando Spotify via Flatpak..."
flatpak install --assumeyes flathub com.spotify.Client

ok "Spotify instalado."

# ####################################################################################
# ///// ANKI
# ####################################################################################

log "Anki"

step "Instalando Anki via Flatpak..."
flatpak install --assumeyes flathub net.ankiweb.Anki

step "Configurando diretório de dados do Anki..."
mkdir -p "$HOME/documents/anki/"
flatpak override --user --filesystem="$HOME/documents/anki" net.ankiweb.Anki || warn "Falha ao configurar filesystem do Anki."
flatpak override --user --env=ANKI_BASE="$HOME/documents/anki" net.ankiweb.Anki || warn "Falha ao configurar ANKI_BASE."

ok "Anki instalado e configurado."

# ####################################################################################
# ///// OBSIDIAN
# ####################################################################################

log "Obsidian"

step "Instalando Obsidian via Flatpak..."
flatpak install --assumeyes flathub md.obsidian.Obsidian

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
if user_systemd_ok; then
    systemctl --user daemon-reload || warn "systemctl daemon-reload falhou."
    systemctl --user enable --now obsidian-sync.service || warn "Não foi possível ativar obsidian-sync.service."
else
    warn "systemd --user indisponível; obsidian-sync.service não ativado (faça logout/login após reiniciar)."
fi

ok "Obsidian instalado e sincronização configurada."

# ####################################################################################
# ///// FIM
# ####################################################################################

log "Configuração concluída!"

finish_checklist
ok "Checklist salvo em: $CHECKLIST_FILE"

REBOOT=""
while true; do
    read -rp "Reiniciar agora para aplicar as mudanças? [s/N]: " REBOOT
    case "${REBOOT:-}" in
        [sS]|[sS][iI][mM]|[yY]|[yY][eE][sS])
            ok "Reiniciando o sistema..."
            sudo shutdown -r now
            break
            ;;
        [nN]|[nN][ãaÃoO]|"")
            ok "Reinicialização adiada. Faça logout/login para aplicar as mudanças de sessão (zsh, docker, systemd --user)."
            break
            ;;
        *)
            warn "Resposta inválida. Use 's' (sim) ou 'n' (não)."
            ;;
    esac
done
