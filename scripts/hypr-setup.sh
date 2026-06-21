#!/bin/bash

## 1. Install Hyprland
sudo pacman -S --noconfirm hyprland kitty

## 2. Install necessary packages
yay -S --noconfirm ninja gcc cmake meson libxcb xcb-proto xcb-util xcb-util-keysyms libxfixes libx11 libxcomposite libxrender libxcursor pixman wayland-protocols cairo pango libxkbcommon xcb-util-wm xorg-xwayland libinput libliftoff libdisplay-info cpio tomlplusplus hyprlang-git hyprcursor-git hyprwayland-scanner-git hyprwire-git xcb-util-errors hyprutils-git glaze hyprgraphics-git aquamarine-git re2 hyprland-qtutils-git muparser
sudo pacman -S --noconfirm mesa lib32-mesa xdg-desktop-portal-hyprland xdg-desktop-portal-gtk xdg-utils egl-wayland linux-headers linux-lts-headers
