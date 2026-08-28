# ####################################################################################
# ///// GIT E AUR — INSTALL ARCH LINUX
# ####################################################################################
# Origem: my-setup/bootstrap.sh (blocos "GIT CONFIG" e "YAY (AUR HELPER)").
# Utiliza GIT_NAME/GIT_EMAIL coletados em 00-user-input.sh.
# ####################################################################################

# Garante a biblioteca comum carregada (permite execução isolada do script).
[ -n "${MY_SETUP_COMMON_LOADED:-}" ] || . "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

# ####################################################################################
# ///// GIT CONFIG
# ####################################################################################

log "Configuração do Git"

step "Instalando git..."
sudo pacman -S --needed --noconfirm git less # Git and Less Terminal Pager

step "Aplicando configurações globais..."
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global init.defaultBranch master
git config --global pull.rebase true
git config --global push.autoSetupRemote true
git config --global color.ui auto
git config --global core.autocrlf input
git config --global core.editor micro

step "Configurando credential helper..."
if command -v git-credential-libsecret &>/dev/null || [ -x /usr/lib/git-core/git-credential-libsecret ]; then
    git config --global credential.helper libsecret
    ok "credential.helper definido como libsecret."
else
    warn "git-credential-libsecret não encontrado; credential.helper não configurado."
fi

step "Definindo aliases..."
git config --global alias.s "status -s"
git config --global alias.c "commit -m"
git config --global alias.l "log --oneline --graph --decorate --all"

ok "Configuração do Git aplicada com sucesso!"
step "Nome:  $(git config --global user.name)"
step "Email: $(git config --global user.email)"

# ####################################################################################
# ///// YAY (AUR HELPER)
# ####################################################################################

log "YAY (AUR Helper)"

step "Instalando base-devel e git..."
sudo pacman -S --needed --noconfirm base-devel git

if ! command -v yay &>/dev/null; then
    step "YAY não encontrado. Clonando e compilando a versão mais recente..."
    (
        cd /tmp && rm -rf yay && git clone --depth 1 https://aur.archlinux.org/yay.git && cd yay
        makepkg -s --noconfirm --needed
        sudo pacman -U --noconfirm yay-*.pkg.tar.zst
    )
    ok "YAY instalado com sucesso."
else
    ok "YAY já está instalado."
fi