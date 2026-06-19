# Setup Arch
## Necessary Packages

## System Utilities
- **Terminal**: Kitty
	- **ZSH**: Shell do terminal
		- **Starship**: Prompt para o terminal
		- **Syntax Hilight**:  Marcar comandos corretos ou errado
		- **Autosuggestions**: Plugin para mostrar sugestões de comandos recentes
		- **Fuzzy Finder**: Plugin para buscar arquivos e pastas no terminal
	- **Font**:  JetBrains Mono Nerd
- **File Explorer**: Nautilus
- **System Monitor**: BTOP (Terminal)
- **Gestor de Disco**: GNOME Disks, GParted
- **Barra de Tarefas**: Waybar
- **Wallpapper Manager**: Hyprpaper
- **Menu de Apps**: Wofi 
- **Gestor de Notificações**: Mako
- **Tela de Bloqueio**: Hyprlock
- **Librarys**: Pacman, AUR(YAY), Flatpak
- **Audio**: Pipiwire, Pavucontrol

## Apps
- **Navegador**: Zen Browser (Flatpak)
- **Notion**: Notion app chromium based
- **Editor de Código**: VS Code (Pacote Nativo)
- **Docker**: Pacote Nativo
- **Screen Recorder**: OBS
- **Calculadora**: Galculator
- **Relógio/Calendário**: WayBar (Config)
- **ScreenShot**: Hyprshot

## Instalation Guide
Caso o computador funcione apenas por internet cabeado não é necessário fazer essa configuração do wifi.

### Caso seja via Wifi
Utilize o IWCTL
1. Comando `iw dev` para listar dispositos de lan que computador identificou.
2. Comando `iwctl` para entrar dentro bash do utilitário
3. Comando `device list` para listar dispositos de LAN, dentro do utilitário.
4. Comando `station nome-do-dispositvo get-networks`
5. Comando `station wlan0 connect nome-da-rede-wifi`. Vai aparecer um pedido no terminal escrito `passphrase`, digite a senha e aperte enter.
6. Comando `exit` para sair do bash do utilitário. 
> Na teoria a internet deve estar conectada.

###Particionamento
Partição do windows ou EFI de 200mb -> /boot/efi
Partição onde vai ficar os kernels  -> /boot
Partição raiz -> /

### Subvolumes

@ -> /
@home -> /home
@log -> /var/log
@pkg -> /var/cache/pacman/pkg

FileSystem : BTRFS
Com compressão ZSTD 

A configuraćão dos snapshots sao feitas diretamente pelo archinstall

### Prossiga com a instalação

1. Verifique a internet faça um ping, caso necessário faća
2. Faca um git clone do meu repo de configuracao do arch ``.
3. Use o script `hypr-fast-setup.sh`.
4. Entre no arquivo de configuração `micro /etc/pacman.conf`
	```bash
	# Descoment o Color
	Color
	ILoveCandy # Escreva o ILoveCandy
	ParallelDownloads = 10 # Coloque o ParallelDownloads para 10
	```
	
# Source
[Como ficou meu Arch Linux: Descubra os aplicativos que uso no meu dia a dia!](https://www.youtube.com/watch?v=7bt1L43y6oo&list=PL1KsXytEKnV7otDeQBbjLKqY-eIFDJpGM&index=9)
[How I Setup Hyprland For An Incredible Arch Linux Experience](https://www.youtube.com/watch?v=PEgDssV0nW0)
[My New Arch + Hyprland Setup For Software Development](https://www.youtube.com/watch?v=IOsJr5EB2zc)
[O Melhor Setup de Desenvolvimento de Software com Arch Linux + Hyprland | Guia de Instalação](https://www.youtube.com/watch?v=CpUUTC68rLA&t=1504s)
[Arch Linux and Hyprland Install Guide](https://www.youtube.com/watch?v=mwQcLWqu8lo)