# Wiki

Caso tenha dúvidas: 
1. Hyprland Master Tutorial: https://wiki.hypr.land/Getting-Started/Master-Tutorial/
2. Nvidia Hyprland (Para as placas da Nvidia funcionarem corretamente no Hyprland são necessários alguns passos a mais.): https://wiki.hypr.land/Nvidia/
3. Wiki do Arch Linux: https://wiki.archlinux.org/title/NVIDIA#Unsupported_drivers.

# Base necessária

É obrigatório que tenham os headeras do kernel, e vai depender do seu kernel.

```bash
sudo pacman -S linux-headers
```

```bash
sudo pacman -S linux-zen-headers
```

```bash
sudo pacman -S linux-lts-headers
```

# Nvidia Drivers 1050ti

## 1. Instalar Drivers

A GTX 1050 Ti (arquitetura Pascal) ainda possui suporte nos drivers da série 580. Em alguns cenários pode ser necessário utilizar os pacotes da série 580 disponíveis no AUR.

```bash
sudo pacman -S libva-nvidia-driver

# Drivers da Placa de vídeo
yay -S nvidia-580xx-dkms nvidia-580xx-utils lib32-nvidia-580xx-utils
```

## 2. Config do hyprland.lua

Agora é necessário fazer alguns passos a mais que a wiki do Hyprland pede.

1. Entre no arquivo `~/.config/hypr/hyprland.lua`

```bash
sudo micro ~/.config/hypr/hyprland.lua
```

2. Procure a área de variáveis de ambiente e insira as variáveis

```lua
-- -----------------------------------------------------
-- CONFIGURAÇÕES DA NVIDIA (GTX 1050 Ti)
-- -----------------------------------------------------

hl.env("GBM_BACKEND", "nvidia-drm")
hl.env("LIBVA_DRIVER_NAME", "nvidia")
hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")

hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")

hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
hl.env("MOZ_ENABLE_WAYLAND", "1")
```

## 3. Configurar DRM KMS (Initramfs)
Isso garante que o Arch carregue os drivers da NVIDIA logo no primeiro segundo do boot, evitando telas pretas antes do Hyprland iniciar.

1. Abra o arquivo de configuração do mkinitcpio:

```bash
sudo micro /etc/mkinitcpio.conf
```

2. Procure pela linha que começa com MODULES=() e adicione os drivers lá dentro. Deve ficar assim:
```text
MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
```

3. Salve e saia do arquivo (`Ctrl + S`, `Enter`, `Ctrl + Q`).

4. Abra o arquivo de config do modprobe:
```bash
sudo micro /etc/modprobe.d/nvidia.conf
```

5. Adicione:
```text
options nvidia_drm modeset=1
```

6. Recrie a imagem do Kernel rodando:
```bash
sudo mkinitcpio -P
```

7. Verifique se o modeset ficou ativo:
```bash
cat /sys/module/nvidia_drm/parameters/modeset
```
Se não aparecer "Y", o Hyprland provavelmente não iniciará corretamente.

## 4. Variáveis no grub
Precisamos dizer ao sistema para carregar o modo de vídeo da NVIDIA e aplicar o ajuste do firmware que desativa as funções problemáticas.

Abra o arquivo do GRUB:

```bash
sudo micro /etc/default/grub
```

1. Procure pela linha `GRUB_CMDLINE_LINUX_DEFAULT` e adicione os parâmetros `nvidia-drm.modeset=1 nvidia.NVreg_EnableGpuFirmware=0` dentro das aspas. Ela deve ficar parecida com isso:
```text
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet nvidia_drm.modeset=1"
```

```text
# Opcional para algumas GPUs modernas
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet nvidia_drm.modeset=1 nvidia.NVreg_EnableGpuFirmware=0"
```

2. Salve o arquivo (no Micro: Pressione Ctrl + S).

Atualize a configuração do GRUB para aplicar as mudanças:
```Bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

## 5. Reboot do sistema
```bash
sudo reboot
```