# Zen Browser

## Tema da Dark
```bash
sudo flatpak override --env=GTK_THEME=Materia-dark app.zen_browser.zen
```

## Configurar uma pasta válida para o navegador compartilhar com o sistema
```bash
sudo flatpak override --filesystem=/home/ghost/flatpaks-share app.zen_browser.zen
```

# Google

Apenas faça o download:
```bash
yay -S google-chrome
```

# Key Ring

Vou usar aqui o do Gnome ele é simples e mais fácil de usar, muitos programadas necessitam dele para fazer login no desktop.

```bash
sudo pacman -S gnome-keyring libsecret seahorse
```

# Wallpaper

O Hyprpaper precisa de um arquivo de configuração para saber qual imagem carregar.

```bash
sudo pacman -S hyprpaper
```

Crie a pasta de configuração (caso não exista):

```bash
mkdir -p ~/.config/hypr
```

2. Crie e abra o arquivo `hyprpaper.conf`:
```bash
micro ~/.config/hypr/hyprpaper.conf
```

Cole o seguinte modelo básico (ajuste o caminho /caminho/para/sua/imagem.jpg para uma imagem real no seu PC):

```conf
# --- Configurações Gerais (Opções Extras) ---
splash = false         # Desativa o texto de splash que aparece na tela
ipc = true             # Mantém o IPC ativado caso queira mudar o wallpaper via terminal/scripts

# --- Configuração do Wallpaper ---

# Exemplo para o Monitor Principal (Substitua DP-1 pelo nome do seu monitor se preferir)
wallpaper {
    monitor = DP-1
    path = $HOME/wallpapers/nome-imagem.jpg
    fit_mode = cover   # Opções: contain | cover | tile | fill
}

# Exemplo apontando para uma PASTA (Muda de wallpaper automaticamente!)
# wallpaper {
#     monitor = DP-2
#     path = /home/seu_usuario/Imagens/MeusWallpapers/
#     fit_mode = cover
#     timeout = 60      # Tempo em segundos para trocar de imagem (padrão é 30)
#     order = random    # Escolhe imagens aleatórias da pasta
#     recursive = false # Se true, procura dentro de subpastas também
# }

# CONFIGURAÇÃO DE FALLBACK (Obrigatório caso você não queira especificar monitores)
# Se deixar o "monitor =" vazio, ele aplica esse wallpaper para qualquer monitor conectado
wallpaper {
    monitor =
    path = $HOME/wallpapers/nome-imagem.jpg
    fit_mode = cover   # Opções: contain | cover | tile | fill
}
```

💡 Dica: Para descobrir o nome exato do seu monitor se precisar especificar, rode hyprctl monitors no terminal.

3. Iniciar junto com o Hyprland

Para que o papel de parede mude automaticamente toda vez que você ligar o PC, adicione a linha de inicialização no seu hyprland.lua:

Abra o seu hyprland.lua:

```bash
micro ~/.config/hypr/hyprland.lua
```

2. Adicione a seguinte linha no final do arquivo (ou na seção de `exec-once`):

```conf
exec-once = hyprpaper

# Ou em formato Lua
hl.exec_cmd("hyprpaper &")
```

Agora é só reiniciar o Hyprland (ou rodar hyprpaper no terminal pela primeira vez) para ver o seu novo wallpaper rodando!

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

# Audio

Apenas faça o download

```bash
sudo pacman -S pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber pavucontrol
```

# Dark Theme

Pacotes necessários:

```bash
sudo pacman -S materia-gtk-theme

sudo pacman -S qt5ct qt6ct kvantum
```

Config do `hyprland.lua`, na função de inicialização.

```bash
hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=Hyprland")
hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme 'Materia-dark'")
hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
```

Config do `hyprland.lua`, nas envs.

```bash
----- DARK THEME -----
hl.env("GDK_BACKEND", "wayland,x11")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
```

# OBS

Primeiramente sempre mantenha o sistema atualizado o OBS tem rusga com Arch linux desatualizado. Erros ao instalar o OBS normalmente se resolve de primeira com um `sudo pacman -Syu`

Comando para instalar o OBS Studio

```bash
sudo pacman -S obs-studio
```

Para termos um setup completo do obs, pensado para reuniões aonde é necessário da camera virtual, o audio do seu microfone e o audio do dektop combinado com o do microfone, é necessário do `v4l2loopback`, os headers do kernel, dependendo do seu kernel, e o pipewire instalado.

```bash
sudo pacman -S v4l2loopback-dkms
```

Caso va utilizar o droid cam que é uma ajuda e tanto utilizar o celular como câmera, aqui esta o link do git hub com as releases, e so baixar ele via zip e executar o arquivo `install.sh` que vem dentro do pacote: https://github.com/dev47apps/droidcam-obs-plugin/releases. Sempre busque a versão mais nova quando o assunto é arch linux.
