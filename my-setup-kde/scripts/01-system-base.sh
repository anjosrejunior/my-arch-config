# ####################################################################################
# ///// SISTEMA BASE — INSTALL ARCH LINUX + KDE PLASMA
# ####################################################################################
# Atualiza o sistema e instala pacotes base usados no desktop: editor de
# terminal, Kitty, fontes, bibliotecas de compatibilidade (FUSE 2/3 e GTK 3),
# senhas SSH no KWallet, monitor de sistema e NetworkManager.
# ####################################################################################

# Garante a biblioteca comum carregada (permite execução isolada do script).
[ -n "${MY_SETUP_COMMON_LOADED:-}" ] || . "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

# ####################################################################################
# ///// INIT — ATUALIZAÇÃO DO SISTEMA E PACOTES BASE
# ####################################################################################

log "Atualização do Sistema e Pacotes Base"

step "Atualizando lista de mirrors (Brasil)..."
curl -s "https://archlinux.org/mirrorlist/?country=BR&protocol=https&use_mirror_status=on" | sed 's/^#Server/Server/' | sudo tee /etc/pacman.d/mirrorlist > /dev/null

step "Atualizando o sistema e bases de dados..."
sudo pacman -Syyu --noconfirm

step "Instalando editor de terminal, Kitty e fontes..."
sudo pacman -S --needed --noconfirm \
    micro \
    kitty \
    noto-fonts \
    noto-fonts-cjk \
    noto-fonts-emoji \
    ttf-nerd-fonts-symbols-common \
    ttf-jetbrains-mono-nerd

# FUSE 2 e 3 para AppImages e programas que ainda pedem libfuse.so.2 ou .so.3.
# GTK 3 para aplicativos que ainda não usam GTK 4 (compatibilidade).
step "Instalando bibliotecas de compatibilidade (FUSE 2/3 e GTK 3)..."
sudo pacman -S --needed --noconfirm \
    fuse2 \
    fuse3 \
    gtk3

ok "Pacotes base instalados."

# ####################################################################################
# ///// SENHAS SSH (KWALLET)
# ####################################################################################
# ksshaskpass guarda a passphrase da chave SSH no KWallet; kwallet-pam desbloqueia o
# cofre no login pelo SDDM. É o equivalente ao GNOME Keyring usado no Hyprland.
# Requisito do KWallet: a carteira precisa se chamar kdewallet e ter a mesma senha do
# usuário, por isso ela não pode ter sido criada antes com outra senha.

log "Senhas SSH (KWallet)"

step "Instalando ksshaskpass e kwallet-pam..."
sudo pacman -S --needed --noconfirm ksshaskpass kwallet-pam

step "Configurando desbloqueio do KWallet no login (SDDM)..."
if [ ! -f /etc/pam.d/sddm ]; then
    warn "/etc/pam.d/sddm não encontrado. Configure o desbloqueio do KWallet manualmente."
elif grep -q "pam_kwallet5.so" /etc/pam.d/sddm; then
    ok "/etc/pam.d/sddm já contém o pam_kwallet5.so."
else
    # "optional": se o módulo falhar, o login não é bloqueado.
    printf '%s\n' \
        'auth       optional   pam_kwallet5.so' \
        'session    optional   pam_kwallet5.so auto_start' \
        | sudo tee -a /etc/pam.d/sddm > /dev/null
    ok "Linhas do pam_kwallet5.so adicionadas ao /etc/pam.d/sddm."
fi

step "Definindo ksshaskpass como askpass do SSH..."
# environment.d é lido pelo systemd --user na sessão gráfica. O SSH_ASKPASS_REQUIRE=prefer
# faz o ssh usar o ksshaskpass também dentro do terminal, em vez de pedir no próprio terminal.
mkdir -p "$HOME/.config/environment.d"
cat > "$HOME/.config/environment.d/ssh-askpass.conf" << EOF
SSH_ASKPASS=$(command -v ksshaskpass || echo /usr/bin/ksshaskpass)
SSH_ASKPASS_REQUIRE=prefer
EOF

ok "ksshaskpass e kwallet-pam instalados e configurados. Reinicie a sessão para aplicar."

# ####################################################################################
# ///// SYSTEM MONITOR
# ####################################################################################

log "System Monitor (Btop)"

step "Instalando btop..."
sudo pacman -S --needed --noconfirm btop

ok "btop instalado."

# ####################################################################################
# ///// REDE (NETWORKMANAGER)
# ####################################################################################

log "Rede (NetworkManager)"

step "Instalando NetworkManager, applet do Plasma e suporte a modem e Wi-Fi..."
sudo pacman -S --needed --noconfirm networkmanager plasma-nm modemmanager usb_modeswitch wpa_supplicant

# O "enable --now" já inicia o serviço; um restart logo depois derrubaria a conexão atual.
step "Ativando NetworkManager no Systemd..."
sudo systemctl enable --now NetworkManager

ok "NetworkManager instalado e ativado."
