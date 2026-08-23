#!/bin/bash
set -e

# Pré-autentica o sudo para evitar prompts de senha espalhados durante a execução
sudo -v

# ####################################################################################
# ///// GIT
# ####################################################################################

echo "=== Configuração do Perfil do Git ==="

# Solicita o nome até que um valor seja digitado
while [ -z "$GIT_NAME" ]; do
    read -rp "Digite o seu Nome para o Git: " GIT_NAME
    [ -z "$GIT_NAME" ] && echo "Erro: O nome não pode ficar em branco."
done

# Solicita o e-mail até que um valor seja digitado
while [ -z "$GIT_EMAIL" ]; do
    read -rp "Digite o seu E-mail para o Git: " GIT_EMAIL
    [ -z "$GIT_EMAIL" ] && echo "Erro: O e-mail não pode ficar em branco."
done

# ####################################################################################
# ///// INIT
# ####################################################################################

sudo pacman -Syu --noconfirm

#---- Install terminal editor ----
sudo pacman -S --noconfirm micro

#---- Install Basic Fonts ----
sudo pacman -S --noconfirm noto-fonts

#---- Install Nerd Fonts ----
sudo pacman -S --noconfirm ttf-nerd-fonts-symbols-common ttf-jetbrains-mono-nerd

# ####################################################################################
# ///// ZSH
# ####################################################################################

sudo pacman -S --noconfirm zsh

##---- Cria os arquivos de configuração ----
touch ~/.zshrc
touch ~/.zprofile

##---- Instala pacotes extras (starship, autosuggestions, syntax-highlighting, fzf) ----
sudo pacman -S --noconfirm starship zsh-autosuggestions zsh-syntax-highlighting fzf

##---- Adiciona as configurações no ~/.zshrc (evita duplicação) ----
if ! grep -q "zsh-autosuggestions.zsh" ~/.zshrc 2>/dev/null; then
cat >> ~/.zshrc << 'EOF'
# Plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Fuzzy Find
source <(fzf --zsh)

# Starship Prompt
eval "$(starship init zsh)"
EOF
fi

##---- Define o Zsh como shell padrão do usuário atual ----
chsh -s $(which zsh)

echo "Zsh instalado, configurado e definido como shell padrão."
echo "Faça logout e login novamente (ou reinicie o terminal) para a mudança ter efeito."

# ####################################################################################
# ///// FIREWALL
# ####################################################################################

# 1. Instalar o UFW (Exemplo para Arch Linux / pacman)
sudo pacman -S ufw --noconfirm

# 2. Habilitar o serviço no Systemd para iniciar com o sistema
sudo systemctl enable --now ufw.service

# 3. Definir regras padrão de segurança
sudo ufw default deny incoming
sudo ufw default allow outgoing

# 4. Ativar o firewall
sudo ufw --force enable

# ####################################################################################
# ///// SYSTEM MONITOR
# ####################################################################################

sudo pacman -S --needed --noconfirm btop

# ####################################################################################
# ///// NETWORK
# ####################################################################################

# NETWORK MANAGER - GERENCIADOR DE REDE + SUPORTE WIREGUARD/VPN + APPLET
sudo pacman -S --needed --noconfirm networkmanager wireguard-tools

# ATIVAR E INICIAR O SERVIÇO DO NETWORK MANAGER
sudo systemctl enable --now NetworkManager

# ####################################################################################
# ///// KEYRING
# ####################################################################################

sudo pacman -S gnome-keyring libsecret --noconfirm

# ####################################################################################
# ///// GIT CONFIG
# ####################################################################################

sudo pacman -S --needed --noconfirm git

# Config GIT
# --- CONFIGURAÇÕES BÁSICAS (OBRIGATÓRIAS) ---
# Substitua pelos seus dados do GitHub/GitLab
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"

echo ""
echo "=== Configuração do git aplicada com sucesso! ==="
echo "Nome:  $(git config --global user.name)"
echo "Email: $(git config --global user.email)"

# --- PREFERÊNCIAS DE BRANCH E BRANCHES REMOTAS ---
# Define 'main' como o nome padrão para a branch principal de novos repositórios
git config --global init.defaultBranch main

# --- COMPORTAMENTO DE PULL E REBASE ---
# Faz o 'git pull' aplicar rebase por padrão (evita commits de merge desnecessários)
git config --global pull.rebase true

# Auto-setup de rastreamento remoto ao criar novas branches
git config --global push.autoSetupRemote true

# --- CREDENCIAIS E SEGURANÇA ---
# Conecta o Git ao GNOME Keyring via libsecret (salva tokens com criptografia em segundo plano)
git config --global credential.helper libsecret

# --- MELHORIAS VISUAIS E UTILITÁRIOS ---
# Ativa cores na saída do terminal
git config --global color.ui auto

# Converte quebras de linha de forma inteligente (Crucial para Linux)
git config --global core.autocrlf input

# --- ATALHOS (ALIASES) ÚTEIS ---
git config --global alias.s "status -s"
git config --global alias.c "commit -m"
git config --global alias.l "log --oneline --graph --decorate --all"

# ####################################################################################
# ///// YAY (AUR HELPER)
# ####################################################################################

echo ""
echo "=== Verificando e Instalando o YAY ==="

# Instala ferramentas essenciais de compilação
sudo pacman -S --needed --noconfirm base-devel

if ! command -v yay &> /dev/null; then
    echo "-> YAY não encontrado. Clonando e compilando..."
    cd /tmp
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
else
    echo "-> YAY já está instalado no sistema."
fi

# ####################################################################################
# ///// FLATPAK
# ####################################################################################

echo "=== Configurando Flatpak ==="

# 1. Atualiza o sistema e instala o pacote flatpak
echo "-> Instalando o Flatpak..."
sudo pacman -Syu --noconfirm flatpak

# 2. Adiciona o repositório oficial do Flathub
echo "-> Adicionando o repositório Flathub..."
flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo

# ####################################################################################
# ///// NVIDIA DRIVERS
# ####################################################################################

sudo pacman -S --needed --noconfirm libva-nvidia-driver egl-wayland

yay -S --noconfirm nvidia-580xx-dkms nvidia-580xx-utils lib32-nvidia-580xx-utils

# ####################################################################################
# ///// HYPRLAND
# ####################################################################################

## 1. Install Hyprland
sudo pacman -S --noconfirm hyprland kitty

## 2. Install necessary packages
sudo pacman -S --noconfirm mesa \
    lib32-mesa \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk xdg-utils \
    linux-headers \
    linux-lts-headers

# ####################################################################################
# ///// UWSM
# ####################################################################################

sudo pacman -S --needed --noconfirm uwsm

# Adiciona a inicialização do Hyprland via uwsm no ~/.zprofile (evita duplicar)
if ! grep -q "uwsm check may-start" ~/.zprofile 2>/dev/null; then
cat >> ~/.zprofile << 'EOF'
if uwsm check may-start; then
    exec uwsm start hyprland.desktop
fi
EOF
fi

# ####################################################################################
# ///// GERENCIADOR DE LOGIN - GREETD + TUIGREET
# ####################################################################################

## 1. Install required packages
sudo pacman -S --needed --noconfirm greetd greetd-tuigreet

## 2. Configure greetd
sudo tee /etc/greetd/config.toml > /dev/null << 'EOF'
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --remember --asterisks --sessions /usr/share/wayland-sessions --cmd 'uwsm start hyprland.desktop'"
user = "greeter"
EOF

## 3. Set greeter permissions and cache folder
sudo usermod -aG video,input greeter
sudo mkdir -p /var/cache/tuigreet
sudo chown -R greeter:greeter /var/cache/tuigreet

## 4. Configure PAM for GNOME Keyring auto-unlock
sudo tee /etc/pam.d/greetd > /dev/null << 'EOF'
#%PAM-1.0

auth       required     pam_securetty.so
auth       requisite    pam_nologin.so
auth       include      system-local-login
auth       optional     pam_gnome_keyring.so

account    include      system-local-login

session    include      system-local-login
session    optional     pam_gnome_keyring.so auto_start
EOF

## 5. Enable greetd service
sudo systemctl enable greetd

# ####################################################################################
# ///// LOCK SCREEN & SUPENSÃO DE SISTEMA
# ####################################################################################

# EM BREVE...

# ####################################################################################
# ///// WAYBAR
# ####################################################################################

echo "==> Instalando Waybar..."
sudo pacman -S --needed --noconfirm waybar

# Define os caminhos de origem e destino
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WAYBAR_SRC_DIR="$SCRIPT_DIR/waybar"
WAYBAR_DST_DIR="$HOME/.config/waybar"

# Garante que a pasta de destino exista
mkdir -p "$WAYBAR_DST_DIR"

# Checa se o diretório local ./waybar existe antes de prosseguir
if [ -d "$WAYBAR_SRC_DIR" ]; then

    # Checa e copia o arquivo config.jsonc
    if [ -f "$WAYBAR_SRC_DIR/config.jsonc" ]; then
        cp "$WAYBAR_SRC_DIR/config.jsonc" "$WAYBAR_DST_DIR/config.jsonc"
        echo "Arquivo $WAYBAR_DST_DIR/config.jsonc atualizado/sobrescrito com sucesso."
    else
        echo "Aviso: config.jsonc não foi encontrado dentro de $WAYBAR_SRC_DIR/"
    fi

    # Checa e copia o arquivo style.css
    if [ -f "$WAYBAR_SRC_DIR/style.css" ]; then
        cp "$WAYBAR_SRC_DIR/style.css" "$WAYBAR_DST_DIR/style.css"
        echo "Arquivo $WAYBAR_DST_DIR/style.css atualizado/sobrescrito com sucesso."
    else
        echo "Aviso: style.css não foi encontrado dentro de $WAYBAR_SRC_DIR/"
    fi

else
    echo "Erro: A pasta $WAYBAR_SRC_DIR não foi encontrada no mesmo diretório do script."
fi

systemctl --user enable waybar.service

# ####################################################################################
# ///// ROFI
# ####################################################################################

# Instala o Rofi caso ainda não esteja instalado no sistema
if ! command -v rofi &> /dev/null; then
    echo "Instalando Rofi..."
    sudo pacman -S --needed --noconfirm rofi
fi

# Definição dos caminhos de origem e destino
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROFI_SRC_DIR="$SCRIPT_DIR/rofi"
ROFI_DST_DIR="$HOME/.config/rofi"
BIN_DST_DIR="$HOME/.local/bin"

# Garante que as pastas de destino existam
mkdir -p "$ROFI_DST_DIR"
mkdir -p "$BIN_DST_DIR"

# Checa se o diretório local ./rofi existe antes de prosseguir
if [ -d "$ROFI_SRC_DIR" ]; then

    # Checa e copia o arquivo config.rasi
    if [ -f "$ROFI_SRC_DIR/config.rasi" ]; then
        cp "$ROFI_SRC_DIR/config.rasi" "$ROFI_DST_DIR/config.rasi"
        echo "Arquivo $ROFI_DST_DIR/config.rasi atualizado/sobrescrito com sucesso."
    else
        echo "Aviso: config.rasi não foi encontrado dentro de $ROFI_SRC_DIR/"
    fi

    # Checa e copia o arquivo powermenu.rasi
    if [ -f "$ROFI_SRC_DIR/powermenu.rasi" ]; then
        cp "$ROFI_SRC_DIR/powermenu.rasi" "$ROFI_DST_DIR/powermenu.rasi"
        echo "Arquivo $ROFI_DST_DIR/powermenu.rasi atualizado/sobrescrito com sucesso."
    else
        echo "Aviso: powermenu.rasi não foi encontrado dentro de $ROFI_SRC_DIR/"
    fi

    # Checa, copia e dá permissão de execução ao script rofi-powermenu
    if [ -f "$ROFI_SRC_DIR/rofi-powermenu" ]; then
        cp "$ROFI_SRC_DIR/rofi-powermenu" "$BIN_DST_DIR/rofi-powermenu"
        chmod +x "$BIN_DST_DIR/rofi-powermenu"
        echo "Script $BIN_DST_DIR/rofi-powermenu atualizado e tornado executável com sucesso."
    else
        echo "Aviso: rofi-powermenu não foi encontrado dentro de $ROFI_SRC_DIR/"
    fi

else
    echo "Erro: A pasta $ROFI_SRC_DIR não foi encontrada no mesmo diretório do script."
fi

# ####################################################################################
# ///// DARK THEME
# ####################################################################################

# As configurações necessários para aplicar to tema no sistema estão no hyprland.lua

sudo pacman -S --needed --noconfirm materia-gtk-theme

sudo pacman -S --needed --noconfirm qt5ct qt6ct kvantum

gsettings set org.gnome.desktop.interface gtk-theme 'Materia-dark'
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'

# ####################################################################################
# ///// WALLPAPER
# ####################################################################################

# 1. Obtém o diretório exato onde este script está localizado
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 2. Instalação do hyprpaper
sudo pacman -S --needed --noconfirm hyprpaper

# 3. Criação dos diretórios (o -p evita erros se já existirem)
mkdir -p "$HOME/wallpapers"
mkdir -p "$HOME/.config/hypr"

# 4. Copia a imagem wallpaper.jpg local para a pasta ~/wallpapers/
if [ -f "$SCRIPT_DIR/wallpaper.jpg" ]; then
    cp "$SCRIPT_DIR/wallpaper.jpg" "$HOME/wallpapers/wallpaper.jpg"
    echo "Imagem wallpaper.jpg copiada para $HOME/wallpapers/"
else
    echo "Aviso: wallpaper.jpg não foi encontrado no mesmo diretório do script."
fi

# 5. Copia e SOBRESCREVE o arquivo hyprpaper.conf local em ~/.config/hypr/
TARGET_CONFIG="$HOME/.config/hypr/hyprpaper.conf"
SOURCE_CONFIG="$SCRIPT_DIR/hypr/hyprpaper.conf"

if [ -f "$SOURCE_CONFIG" ]; then
    cp "$SOURCE_CONFIG" "$TARGET_CONFIG"
    echo "Arquivo $TARGET_CONFIG atualizado/sobrescrito com sucesso."
else
    echo "Erro: O arquivo hyprpaper.conf não foi encontrado no mesmo diretório do script."
fi

# 6. Ativação e inicialização do serviço via Systemd/UWSM
systemctl --user enable --now hyprpaper.service

# ####################################################################################
# ///// AUDIO
# ####################################################################################

sudo pacman -S --needed --noconfirm \
    pipewire \
    pipewire-alsa \
    pipewire-pulse \
    pipewire-jack \
    wireplumber \
    pavucontrol

# ####################################################################################
# ///// CLIPBOARD
# ####################################################################################

sudo pacman -S --needed --noconfirm wl-clipboard grim slurp

# ####################################################################################
# ///// NODE
# ####################################################################################

#---- Instalação do Node (Eu desenvolvo em TS quando tenho paciência em JS) ----
# 1. Baixa e instala o NVM (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.6/install.sh | bash

# 2. Carrega as variáveis do NVM na sessão atual do terminal (sem precisar reiniciar o shell)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# 3. Baixa e instala a versão especificada do Node.js (ex: versão 24)
nvm install 24

# 4. Ativa o pnpm nativamente via Corepack
corepack enable pnpm

# 5. Validação das instalações no console
echo "Node versão: $(node -v)"
echo "NPM versão: $(npm -v)"
echo "PNPM versão: $(pnpm -v)"

# ####################################################################################
# ///// UV
# ####################################################################################

#---- Instalando o UV da Astral (Também faço bastantes coisas com python) ----
curl -LsSf https://astral.sh/uv/install.sh | sh

# ####################################################################################
# ///// DOCKER
# ####################################################################################

sudo pacman -S --needed --noconfirm docker

# O docker compose vem separado do docker engine no pacote do pacman, então é necessário instalar separadamente
sudo pacman -S --needed --noconfirm docker-compose

# O buildx também vem em outro pacote separado do docker principal
sudo pacman -S --needed --noconfirm docker-buildx

# É necessário abilitar o docker no systemd
sudo systemctl enable --now docker

sudo usermod -aG docker $USER

# ####################################################################################
# ///// CODE EDITOR (ZED)
# ####################################################################################

# 1. Obtém o diretório exato onde este script está localizado
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 2. Instalação do Zed via Flatpak
flatpak install --noninteractive flathub dev.zed.Zed

# 3. Define o diretório de destino das configurações no sandbox do Flatpak
ZED_CONFIG_DIR="$HOME/.var/app/dev.zed.Zed/config/zed"

# 4. Verifica se a pasta do Zed no Flatpak pré-existe
if [ -d "$ZED_CONFIG_DIR" ]; then
    SOURCE_ZED_SETTINGS="$SCRIPT_DIR/zed/settings.json"
    TARGET_ZED_SETTINGS="$ZED_CONFIG_DIR/settings.json"

    if [ -f "$SOURCE_ZED_SETTINGS" ]; then
        cp "$SOURCE_ZED_SETTINGS" "$TARGET_ZED_SETTINGS"
        echo "Configuração do Zed ($TARGET_ZED_SETTINGS) atualizada com sucesso."
    else
        echo "Erro: O arquivo settings.json não foi encontrado em $SOURCE_ZED_SETTINGS"
    fi
else
    echo "Erro: O diretório de destino $ZED_CONFIG_DIR não existe. Abra o Zed ao menos uma vez para gerar a estrutura do Flatpak."
fi

# ####################################################################################
# ///// OBS STUDIO & LOOPBACK
# ####################################################################################

echo ""
echo "=== Instalando OBS Studio ==="
echo "-> Instalando OBS Studio e v4l2loopback (para câmera e áudio virtual)..."
sudo pacman -S --needed --noconfirm obs-studio v4l2loopback-dkms

# ####################################################################################
# ///// THUNAR E FERRAMENTAS DE ARQUIVOS
# ####################################################################################

echo ""
echo "=== Instalando Thunar e utilitários de arquivos ==="
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

# ####################################################################################
# ///// VISUALIZADORES
# ####################################################################################

# MPV - VIDEO VIEWER + FFMPEG
sudo pacman -S --needed --noconfirm mpv ffmpeg

# FEH - IMAGE VIEWER
sudo pacman -S --needed --noconfirm feh

# ####################################################################################
# ///// RCLONE
# ####################################################################################

sudo pacman -S --needed --noconfirm rclone

# ####################################################################################
# ///// NAVEGADORES
# ####################################################################################

echo ""
echo "=== Instalando Google Chrome via Flatpak ==="
flatpak install --assumeyes flathub com.google.Chrome

echo ""
echo "=== Instalando Zen Browser via Flatpak ==="
flatpak install --assumeyes flathub app.zen_browser.zen

echo "-> Aplicando permissões e tema no Zen Browser..."
SHARED_DIR="$HOME/flatpaks-share"
mkdir -p "$SHARED_DIR"

sudo flatpak override --env=GTK_THEME=Materia-dark app.zen_browser.zen
sudo flatpak override --filesystem="$SHARED_DIR" app.zen_browser.zen
sudo flatpak override --filesystem="$SHARED_DIR" com.google.Chrome

####################################################################################
# ///// DBEAVER
####################################################################################

echo ""
echo "=== Instalando DBeaver Community via Flatpak ==="
flatpak install --assumeyes flathub io.dbeaver.DBeaverCommunity

####################################################################################
# ///// DISCORD
####################################################################################

echo ""
echo "=== Instalando Discord via Flatpak ==="
flatpak install --assumeyes flathub com.discordapp.Discord

####################################################################################
# ///// SPOTIFY
####################################################################################

echo ""
echo "=== Instalando Spotify via Flatpak ==="
flatpak install --assumeyes flathub com.spotify.Client

####################################################################################
# ///// ANKI
####################################################################################

echo ""
echo "=== Instalando Anki via Flatpak ==="
flatpak install --assumeyes flathub net.ankiweb.Anki

mkdir -p "$HOME/documents/anki/"

flatpak override --user --filesystem="$HOME/documents/anki" net.ankiweb.Anki
flatpak override --user --env=ANKI_BASE="$HOME/documents/anki" net.ankiweb.Anki

####################################################################################
# ///// OBSIDIAN
####################################################################################

echo ""
echo "=== Instalando Obsidian via Flatpak ==="
flatpak install --assumeyes flathub md.obsidian.Obsidian

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DST_DIR="$HOME/.local/bin"

# Cria diretórios necessários
mkdir -p "$HOME/documents/ocarina-of-time/"
mkdir -p "$HOME/scripts/"
mkdir -p "$HOME/.config/systemd/user"
mkdir -p "$BIN_DST_DIR"

# Concede permissão de acesso à pasta do Vault no Flatpak
flatpak override --user --filesystem="$HOME/documents/ocarina-of-time" md.obsidian.Obsidian

# Copia o script de sincronização do Rclone
if [ -f "$SCRIPT_DIR/obsidian-rclone/sync-obsidian" ]; then
    cp "$SCRIPT_DIR/obsidian-rclone/sync-obsidian" "$BIN_DST_DIR/sync-obsidian"
    chmod +x "$BIN_DST_DIR/sync-obsidian"
    echo "Script de sync do obsidian copiado e configurado em: $BIN_DST_DIR/sync-obsidian"
else
    echo "Aviso: O script 'sync-obsidian' não foi encontrado no diretório do instalador."
fi

# Copia o serviço de usuário do systemd para o UWSM
if [ -f "$SCRIPT_DIR/obsidian-rclone/obsidian-sync.service" ]; then
    cp "$SCRIPT_DIR/obsidian-rclone/obsidian-sync.service" "$HOME/.config/systemd/user/obsidian-sync.service"
    echo "Serviço systemd copiado com sucesso para: $HOME/.config/systemd/user/obsidian-sync.service"
else
    echo "Aviso: O arquivo 'obsidian-sync.service' não foi encontrado no diretório do instalador."
fi

# Recarrega o daemon de usuário do systemd e ativa o serviço
echo "=== Ativando o serviço no SystemD (UWSM) ==="
systemctl --user daemon-reload
systemctl --user enable --now obsidian-sync.service

echo ""
echo "=== Configuração concluída! ==="
