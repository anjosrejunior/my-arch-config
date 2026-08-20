# 1. Pacotes Necessários

Instale o gerenciador de login, o greeter e o daemon de senhas:

```bash
sudo pacman -S --needed --noconfirm greetd greetd-tuigreet gnome-keyring uwsm
```

# 2. Configuração do `greetd` (`/etc/greetd/config.toml`)

Edite o arquivo `/etc/greetd/config.toml` e deixe o bloco principal exatamente assim:

```toml
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --remember --asterisks --sessions /usr/share/wayland-sessions --cmd 'uwsm start hyprland.desktop'"
user = "greeter"
```

## Ajustes de Permissão do Usuário `greeter`:

```bash
# Permissão para acessar dispositivos de vídeo/entrada no TTY
sudo usermod -aG video,input greeter

# Criar pasta de cache para salvar o último usuário logado
sudo mkdir -p /var/cache/tuigreet
sudo chown greeter:greeter /var/cache/tuigreet
```

# 3. Desbloqueio Automático do GNOME Keyring via PAM (`/etc/pam.d/greetd`)

Para que o keyring seja desbloqueado automaticamente ao digitar sua senha de login no `tuigreet`, edite o arquivo `/etc/pam.d/greetd`:

```text
#%PAM-1.0

auth       required     pam_securetty.so
auth       requisite    pam_nologin.so
auth       include      system-local-login
auth       optional     pam_gnome_keyring.so

account    include      system-local-login

session    include      system-local-login
session    optional     pam_gnome_keyring.so auto_start

```

> **Nota:** A senha do seu usuário no sistema precisa ser a mesma senha do cofre de senhas do GNOME Keyring.

# 4. Integração no Script do Hyprland (Lua)

No seu arquivo de inicialização do Hyprland (script Lua), adicione as chamadas para atualizar as variáveis de ambiente e disparar o daemon do keyring encapsulado no `uwsm
app --`:

```lua
hl.on("hyprland.start", function () 
    hl.exec_cmd("uwsm app -- gnome-keyring-daemon --start --components=secrets,ssh,pkcs11")  -- Adicione essa função de start com as outras que ja estão no seu hyprland.lua
end)

```

# 5. Remoção de Conflitos (`~/.zprofile` ou `~/.zshrc`)

Remova ou comente qualquer inicialização manual do `uwsm` ou `Hyprland` que estivesse presente no seu perfil do shell para evitar execuções duplicadas e telas pretas no
login:

```bash
# Remova ou comente blocos do tipo:
# if [ -z "$DISPLAY" ] && [ "$XDG_VTNR" -eq 1 ]; then
#     exec uwsm start hyprland.desktop
# fi
```

# 6. Ativar o Serviço

Desative outros Display Managers e ative o `greetd`:

```bash
sudo systemctl disable sddm lightdm gdm
sudo systemctl enable greetd
```

Reinicie o sistema:

```bash
sudo reboot

```

O arquivo Markdown com o resumo completo do passo a passo da instalação e configuração foi criado.

# Conteúdo resumido do arquivo:

1. **Instalação dos pacotes necessários:** `greetd`, `greetd-tuigreet`, `gnome-keyring` e `seahorse`.
2. **Configuração limpa do `greetd`:** `/etc/greetd/config.toml` chamando `tuigreet` com `uwsm start hyprland.desktop`.
3. **Ajustes de permissão do usuário `greeter`:** Adição aos grupos de vídeo/entrada e permissão no `/var/cache/tuigreet`.
4. **Configuração do PAM:** `/etc/pam.d/greetd` com `pam_gnome_keyring.so` para desbloqueio automático no login.
5. **Ajuste no script Lua do Hyprland:** Chamadas diretas para `gsettings`/`dbus` e uso de `uwsm app --` para daemons persistentes (`gnome-keyring-daemon` e
`hyprpolkitagent`).
6. **Remoção de auto-start redundante:** Limpeza no `~/.zprofile` para evitar conflito de inicializações do UWSM.
7. **Ativação do serviço via systemd.**