#!/bin/bash

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

##---- Adiciona as configurações no ~/.zshrc (evita duplicar se o script rodar mais de uma vez) ----
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
# ///// KEYRING
# ####################################################################################

sudo pacman -S gnome-keyring libsecret --noconfirm

# ####################################################################################
# ///// GIT
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

# --- MELHORIAS VISUAIS E UTILITÁRIAS ---
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

echo ""
echo "=== Configuração concluída! ==="

# ####################################################################################
# ///// HYPRLAND
# ####################################################################################

## 1. Install Hyprland
sudo pacman -S --noconfirm hyprland kitty

## 2. Install necessary packages
sudo pacman -S --noconfirm mesa lib32-mesa xdg-desktop-portal-hyprland xdg-desktop-portal-gtk xdg-utils egl-wayland linux-headers linux-lts-headers

#---- Configuração do USWM ----
sudo pacman -S uwsm

# Adiciona a inicialização do Hyprland via uwsm no ~/.zprofile (evita duplicar)
if ! grep -q "uwsm check may-start" ~/.zprofile 2>/dev/null; then
cat >> ~/.zprofile << 'EOF'
if uwsm check may-start; then
    exec uwsm start hyprland.desktop
fi
EOF
fi

# ####################################################################################
# ///// DARK THEME
# ####################################################################################

# As configurações necessários para aplicar to tema no sistema estão no hyprland.lua

sudo pacman -S materia-gtk-theme

sudo pacman -S qt5ct qt6ct kvantum

# ####################################################################################
# ///// AUDIO
# ####################################################################################

sudo pacman -S pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber pavucontrol

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

sudo pacman -S docker

# O docker compose vem separado do docker engine no pacote do pacman, então é necessário instalar separadamente
sudo pacman -S docker-compose

# O buildx também vem em outro pacote separado do docker principal
sudo pacman -S docker-buildx

# É necessário abilitar o docker no systemd
sudo systemctl enable --now docker

sudo usermod -aG docker $USER

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
# ///// GOOGLE CHROME
# ####################################################################################

echo ""
echo "=== Instalando Google Chrome via YAY ==="
yay -S --needed --noconfirm google-chrome

# ####################################################################################
# ///// ZEN BROWSER
# ####################################################################################

echo ""
echo "=== Fazendo Download do ZenBrowser ==="

flatpak install flathub app.zen_browser.zen

echo "-> Aplicando permissões e tema no Zen Browser..."

SHARED_DIR="$HOME/flatpaks-share"
mkdir -p "$SHARED_DIR"

sudo flatpak override --env=GTK_THEME=Materia-dark app.zen_browser.zen
sudo flatpak override --filesystem="$SHARED_DIR" app.zen_browser.zen
