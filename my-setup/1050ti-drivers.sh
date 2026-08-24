# ####################################################################################
# ///// NVIDIA DRIVERS
# ####################################################################################

echo "Drivers NVIDIA"

echo "Instalando pacotes de suporte (libva, egl-wayland)..."
sudo pacman -S --needed --noconfirm libva-nvidia-driver egl-wayland

echo "Instalando drivers NVIDIA 580xx via YAY..."
yay -S --noconfirm nvidia-580xx-dkms nvidia-580xx-utils lib32-nvidia-580xx-utils

echo "Drivers NVIDIA instalados."