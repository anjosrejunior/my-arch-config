# Zen Browser

## Tema da Dark
```bash
sudo flatpak override --env=GTK_THEME=Materia-dark app.zen_browser.zen
```

## Configurar uma pasta válida para o navegador compartilhar com o sistema
```bash
sudo flatpak override --filesystem=/home/ghost/flatpaks-share app.zen_browser.zen
```

# Google Chrome

Apenas faça o download:
```bash
yay -S google-chrome
```

# Thunar

Comando para instalar o thunar
```bash
sudo pacman -S thunar thunar-archive-plugin thunar-volman tumbler 
```

Pacotes do gerenciador de arquivos virtual e ferramentas para lidar com arquivos compactados.

```bash
# Pacote necessário
sudo pacman -S gvfs xarchiver unzip
```

# OBS

Primeiramente sempre mantenha o sistema atualizado o OBS tem rusga com Arch linux desatualizado. Erros ao instalar o OBS normalmente se resolve de primeira com um `sudo pacman -Syu`

Comando para instalar o OBS Studio

```bash
sudo pacman -S obs-studio
```

Para termos um setup completo do obs, pensado para reuniões aonde é necessário da camera virtual, o audio do seu microfone e o audio do dektop combinado com o do microfone, é necessário do `v4l2loopback` o loopback é utilizado para criar canais de audio, os headers do kernel, dependendo do seu kernel, pipewire pacotes do próprio instalados e o UWSM que é o gestor de wayland sessions, sem ele o pipewire não consegue ver o hyprland no systemd assim ele não é considerado um processo real, fazendo com que ele não tenha como ser capturado pelo pipewire.

```bash
sudo pacman -S v4l2loopback-dkms
```

Caso va utilizar o droid cam que é uma ajuda e tanto utilizar o celular como câmera, aqui esta o link do git hub com as releases, e so baixar ele via zip e executar o arquivo `install.sh` que vem dentro do pacote: https://github.com/dev47apps/droidcam-obs-plugin/releases. Sempre busque a versão mais nova quando o assunto é arch linux.