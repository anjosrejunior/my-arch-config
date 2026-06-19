# Configurar Teclado internacional US

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