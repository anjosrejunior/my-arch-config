#!/bin/bash

# Update System
sudo pacman -Syu --noconfirm
# Install terminal editor
sudo pacman -S micro
# Install Basic Fonts
sudo pacman -S noto-fonts
# Install Nerd Fonts
sudo pacman -S ttf-nerd-fonts-symbols-common ttf-jetbrains-mono-nerd

#### YAY ####

# 1. Instala as ferramentas de compilação necessárias
sudo pacman -S --needed --noconfirm base-devel git
# 2. Entra no diretório temporário
cd /tmp
# 3. Clona o repositório do YAY
git clone https://aur.archlinux.org/yay.git
# 4. Entra na pasta do YAY
cd yay
# 5. Compila e instala (sem o --noconfirm para garantir que o pacman instale as dependências com segurança)
makepkg -si

#### Hyprland ####

sudo pacman -S hyprland kitty

## Install necessery packages
yay -S ninja gcc cmake meson libxcb xcb-proto xcb-util xcb-util-keysyms libxfixes libx11 libxcomposite libxrender libxcursor pixman wayland-protocols cairo pango libxkbcommon xcb-util-wm xorg-xwayland libinput libliftoff libdisplay-info cpio tomlplusplus hyprlang-git hyprcursor-git hyprwayland-scanner-git hyprwire-git xcb-util-errors hyprutils-git glaze hyprgraphics-git aquamarine-git re2 hyprland-qtutils-git muparser

sudo pacman -S mesa lib32-mesa xdg-desktop-portal-hyprland xdg-desktop-portal-gtk xdg-utils egl-wayland linux-headers linux-lts-headers