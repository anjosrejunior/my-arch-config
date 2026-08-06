#!/bin/bash

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
git config --global user.name "Seu Nome"
git config --global user.email "seu.email@exemplo.com"

# --- PREFERÊNCIAS DE BRANCH E BRANCHES REMOTAS ---
# Define 'main' como o nome padrão para a branch principal de novos repositórios
git config --global init.defaultBranch main

# --- COMPORTAMENTO DE PULL E REBASE ---
# Faz o 'git pull' aplicar rebase por padrão (evita commits de merge desnecessários)
git config --global pull.rebase true

# Auto-setup de rastreamento remoto ao criar novas branches
git config --global push.autoSetupRemote true

# --- EDITOR E FERRAMENTAS ---
# Define o VS Code como editor padrão do Git (mude para "kitty -e nvim" ou "nano" se preferir)
git config --global core.editor "code --wait"

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
# ///// YAY
# ####################################################################################

## 1. Instala as ferramentas de compilação necessárias
sudo pacman -S --needed --noconfirm base-devel
## 2. Entra no diretório temporário
cd /tmp
## 3. Clona o repositório do YAY
git clone https://aur.archlinux.org/yay.git
## 4. Entra na pasta do YAY
cd yay
## 5. Compila e instala (sem o --noconfirm para garantir que o pacman instale as dependências com segurança)
makepkg -si

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
