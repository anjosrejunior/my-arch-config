# Audio

```bash
sudo pacman -S pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber pavucontrol
```

## qwgraph (Controle de canais de áudio)

```bash
sudo pacman -S qpwgraph
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

# Key Ring

Vou usar aqui o do Gnome ele é simples e mais fácil de usar, muitos programadas necessitam dele para fazer login no desktop.

```bash
sudo pacman -S gnome-keyring libsecret seahorse
```

# Keybord Setup (Configurar Teclado internacional US)

1. Altere a Env do Hyprland

Coloque essa variáveis de ambiente dentro do arquivo de configuracao `hyprland.lua`, acessando com o comando `micro .config/hypr/hyprland.lua`

Nas configurações do teclado:

```lua
hl.config({
    input = {
        kb_layout  = "us",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0, -- -1.0 - 1.0, 0 means no modification.

        touchpad = {
            natural_scroll = false,
        },
    },
})
```

E preciso por isso daqui na config.

```lua
kb_variant = "intl",
```

# My look and feel

```lua
-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
    general = {
        gaps_in  = 3,
        gaps_out = 3,

        border_size = 1,

        col = {
            active_border   = { colors = {"rgba(f7d83bee)", "rgba(b89e22ee)"}, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },

        -- Set to true to enable resizing windows by clicking and dragging on borders and gaps
        resize_on_border = false,

        -- Please see https://wiki.hypr.land/Configuring/Advanced-and-Cool/Tearing/ before you turn this on
        allow_tearing = false,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 1,
        rounding_power = 2,

        -- Change transparency of focused and unfocused windows
        active_opacity   = 0.9,
        inactive_opacity = 0.7,

        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
            enabled   = true,
            size      = 3,
            passes    = 1,
            vibrancy  = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },
})
```
