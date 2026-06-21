#!/bin/bash

#---- Packages ----
# Update System
# Micro
# Noto Fonts (Basic Fonts)
# Nerd Fonts
# YAY

#---- Update System ----
sudo pacman -Syu --noconfirm

#---- Install terminal editor ----
sudo pacman -S micro

#---- Install Basic Fonts ----
sudo pacman -S noto-fonts

#---- Install Nerd Fonts ----
sudo pacman -S ttf-nerd-fonts-symbols-common ttf-jetbrains-mono-nerd

##---- Instala o Zsh ----
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

#---- YAY ----

## 1. Instala as ferramentas de compilação necessárias
sudo pacman -S --needed --noconfirm base-devel git
## 2. Entra no diretório temporário
cd /tmp
## 3. Clona o repositório do YAY
git clone https://aur.archlinux.org/yay.git
## 4. Entra na pasta do YAY
cd yay
## 5. Compila e instala (sem o --noconfirm para garantir que o pacman instale as dependências com segurança)
makepkg -si

#---- Hyprland ----

## 1. Install Hyprland
sudo pacman -S --noconfirm hyprland kitty

## 2. Install necessary packages
yay -S --noconfirm ninja gcc cmake meson libxcb xcb-proto xcb-util xcb-util-keysyms libxfixes libx11 libxcomposite libxrender libxcursor pixman wayland-protocols cairo pango libxkbcommon xcb-util-wm xorg-xwayland libinput libliftoff libdisplay-info cpio tomlplusplus hyprlang-git hyprcursor-git hyprwayland-scanner-git hyprwire-git xcb-util-errors hyprutils-git glaze hyprgraphics-git aquamarine-git re2 hyprland-qtutils-git muparser
sudo pacman -S --noconfirm mesa lib32-mesa xdg-desktop-portal-hyprland xdg-desktop-portal-gtk xdg-utils egl-wayland linux-headers linux-lts-headers