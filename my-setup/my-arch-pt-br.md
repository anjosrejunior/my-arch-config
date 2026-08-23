# Meu Setup Arch Linux + Hyprland

Este repositório contém meu setup pessoal de Arch Linux com Hyprland, incluindo um script de instalação automatizada (`bootstrap.sh`) e minhas configurações
(dotfiles). O objetivo é reproduzir todo o ambiente de desenvolvimento e uso diário em uma máquina nova de forma rápida e consistente.

## Stack / Componentes

### Sistema e Compositor
| Componente | Ferramenta |
|------------|------------|
| Compositor | Hyprland |
| Gerenciador de Sessão | UWSM |
| Gerenciador de Login | Greetd + Tuigreet |
| Firewall | UFW |
| Gerenciador de Rede | NetworkManager + WireGuard |

### Terminal e Shell
| Componente | Ferramenta |
|------------|------------|
| Terminal | Kitty |
| Shell | ZSH |
| Prompt | Starship |
| Plugins | zsh-autosuggestions, zsh-syntax-highlighting, fzf |
| Fontes | JetBrains Mono Nerd, Noto Fonts |

### Interface e Tema
| Componente | Ferramenta |
|------------|------------|
| Barra de Tarefas | Waybar |
| App Launcher | Rofi (+ powermenu) |
| Wallpaper | Hyprpaper |
| Tema GTK | Materia-dark |
| Tema Qt | qt5ct, qt6ct, Kvantum |
| Keyring | GNOME Keyring + libsecret |

### Áudio e Mídia
| Componente | Ferramenta |
|------------|------------|
| Serviço de Áudio | Pipewire (alsa, pulse, jack) + Wireplumber |
| Controle de Áudio | Pavucontrol |
| Player de Vídeo | MPV + FFmpeg |
| Visualizador de Imagem | FEH |
| Gravador de Tela | OBS Studio + v4l2loopback |

### Arquivos e Discos
| Componente | Ferramenta |
|------------|------------|
| Gerenciador de Arquivos | Thunar (+ plugins, tumbler, gvfs) |
| Sincronização | Rclone |
| Compactação | xarchiver, unzip, p7zip, unrar, tar, gzip, bzip2 |

### Desenvolvimento
| Componente | Ferramenta |
|------------|------------|
| Editor de Código | Zed (Flatpak) |
| Versionamento | Git |
| Runtime JS/TS | Node.js (NVM v24) + pnpm |
| Runtime Python | UV (Astral) |
| Containers | Docker + Docker Compose + Docker Buildx |

### Aplicativos
| Aplicativo | Instalação |
|------------|------------|
| Zen Browser | Flatpak |
| Google Chrome | Flatpak |
| Obsidian | Flatpak (+ sync via Rclone e systemd) |
| Spotify | Flatpak |
| Discord | Flatpak |
| DBeaver | Flatpak |
| Anki | Flatpak |
| Monitor do Sistema | BTOP (pacman) |
| Editor de Terminal | micro (pacman) |
| Clipboard | wl-clipboard |
| Screenshot | grim + slurp |

## Pré-requisitos

- **Arch Linux** recém-instalado com:
  - Sistema de arquivos **BTRFS** com compressão ZSTD
  - Subvolumes: `@`, `@home`, `@log`, `@pkg`
  - Partições: `/boot/efi` (EFI), `/boot` (kernels), `/` (raiz)
- **Conexão com internet** ativa
- **Git** instalado no sistema base

## Instalação

Execute os comandos abaixo em um terminal após a instalação base do Arch Linux:

```bash
# 1. Clone o repositório
git clone https://github.com/anjosrejunior/my-arch-config
cd my-arch-config

# 2. Execute o script principal
./bootstrap.sh
```

> **Nota:** O script solicitará seu nome e e-mail para configurar o Git. Tenha esses dados prontos.

### Pós-instalação

1. **ZSH** — Faça logout e login novamente (ou reinicie o terminal) para o ZSH se tornar o shell padrão.
2. **Zed** — Abra o Zed ao menos uma vez para que o Flatpak gere a estrutura de diretórios de configuração.
3. **Obsidian** — Configure o Rclone para sincronização (o script copia o binário `sync-obsidian` para `~/.local/bin/` e ativa o serviço systemd).
4. **Docker** — Faça logout e login para que o grupo `docker` tenha efeito (ou execute `newgrp docker`).

## Serviços Systemd Habilitados

| Serviço | Escopo | Descrição |
|---------|--------|-----------|
| `NetworkManager` | Sistema | Gerenciamento de rede |
| `greetd` | Sistema | Tela de login (Tuigreet) |
| `docker` | Sistema | Docker Engine |
| `ufw` | Sistema | Firewall |
| `hyprpaper.service` | Usuário | Gerenciamento de wallpaper |
| `waybar.service` | Usuário | Barra de tarefas |
| `obsidian-sync.service` | Usuário | Sincronização do Obsidian via Rclone |

## Notas

- O script utiliza **pré-autenticação do sudo** (`sudo -v`) para evitar múltiplos prompts de senha.
- O driver NVIDIA instalado é o `nvidia-580xx` (DKMS), compatível com Wayland.
- O tema escuro é aplicado globalmente via `gsettings` (Materia-dark).
- O lock screen (**Hyprlock**) ainda não está configurado no script (pendente).
- O suporte a Flatpak inclui os repositórios Flathub e permissões específicas para Zen Browser, Chrome, Obsidian e Anki.