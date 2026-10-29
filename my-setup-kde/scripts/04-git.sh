# ####################################################################################
# ///// GIT E AUR — INSTALL ARCH LINUX + KDE PLASMA
# ####################################################################################
# Utiliza GIT_NAME/GIT_EMAIL e as escolhas de chaves GPG/SSH coletadas em 00-user-input.sh.
# ####################################################################################

# Garante a biblioteca comum carregada (permite execução isolada do script).
[ -n "${MY_SETUP_COMMON_LOADED:-}" ] || . "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

# ####################################################################################
# ///// GIT CONFIG
# ####################################################################################

log "Configuração do Git"

step "Instalando git, openssh, gnupg e pinentry..."
sudo pacman -S --needed --noconfirm git less openssh gnupg pinentry

step "Aplicando configurações globais..."
git config --global user.name "$GIT_NAME"
git config --global user.email "$GIT_EMAIL"
git config --global init.defaultBranch master
git config --global pull.rebase true
git config --global push.autoSetupRemote true
git config --global color.ui auto
git config --global core.autocrlf input
git config --global core.editor micro

step "Definindo aliases..."
git config --global alias.s "status -s"
git config --global alias.c "commit -m"
git config --global alias.l "log --oneline --graph --decorate --all"
git config --global alias.status-all '!f() { find "${1:-.}" -maxdepth 3 -name ".git" -type d | while read dir; do repo=$(dirname "$dir"); dirty=$(git -C "$repo" status --porcelain); unpushed=$(git -C "$repo" cherry 2>/dev/null); if [ -n "$dirty" ] || [ -n "$unpushed" ]; then msg=""; [ -n "$dirty" ] && msg="$msg ⚠️  (Sem commit)"; [ -n "$unpushed" ] && msg="$msg 🚀 (Sem push)"; echo "$repo ->$msg"; fi; done; }; f'

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

# ####################################################################################
# ///// CHAVE GPG
# ####################################################################################

log "Chave GPG"

if [ "$GPG_CHOICE" = "yes" ]; then
    if gpg --list-secret-keys "$GPG_EMAIL" &>/dev/null; then
        warn "Já existe uma chave GPG para $GPG_EMAIL. Pulando a geração."
    else
        # Sem GPG_TTY o pinentry de terminal não consegue pedir a senha da chave.
        if [ -t 0 ]; then
            export GPG_TTY="$(tty)"
        fi

        step "Criando chave GPG ed25519 (sem expiração). O pinentry pedirá a senha..."
        if gpg --quick-generate-key "$GPG_NAME <$GPG_EMAIL>" ed25519 cert,sign 0 \
            && gpg --quick-add-key "$(gpg --with-colons --list-secret-keys "$GPG_EMAIL" | awk -F: '/^fpr:/ {print $10; exit}')" cv25519 encr 0; then
            ok "Chave GPG criada."
        else
            warn "Não foi possível criar a chave GPG. Crie manualmente com: gpg --full-generate-key"
        fi
    fi

    gpg --list-secret-keys --keyid-format=long "$GPG_EMAIL" 2>/dev/null || true
else
    ok "Chave GPG não solicitada. Pulando etapa..."
fi

# ####################################################################################
# ///// CHAVE SSH (GITHUB)
# ####################################################################################

log "Chave SSH (GitHub)"

if [ "$SSH_CHOICE" = "yes" ]; then
    SSH_DIR="$HOME/.ssh"
    SSH_KEY="$SSH_DIR/github_key"
    SSH_CONFIG="$SSH_DIR/config"
    PUBLIC_KEY_TXT="$HOME/chave_publica_github.txt"

    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"

    if [ -f "$SSH_KEY" ]; then
        warn "Já existe uma chave SSH em $SSH_KEY. Pulando a geração."
    else
        step "Gerando chave SSH ed25519 para o GitHub. O ssh-keygen pedirá a senha..."
        if ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$SSH_KEY"; then
            chmod 600 "$SSH_KEY"
            chmod 644 "${SSH_KEY}.pub"

            if ! grep -q "Host github.com" "$SSH_CONFIG" 2>/dev/null; then
                cat << EOF >> "$SSH_CONFIG"

# Configuração da chave SSH para o GitHub
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/github_key
    IdentitiesOnly yes
    AddKeysToAgent yes
EOF
                chmod 600 "$SSH_CONFIG"
                ok "Arquivo ~/.ssh/config atualizado com as regras do GitHub."
            fi

            cp "${SSH_KEY}.pub" "$PUBLIC_KEY_TXT"
            chmod 644 "$PUBLIC_KEY_TXT"

            ok "Chave SSH gerada. Cópia da chave pública em: $PUBLIC_KEY_TXT"
        else
            warn "Não foi possível gerar a chave SSH. Gere manualmente com: ssh-keygen -t ed25519 -C \"$GIT_EMAIL\""
        fi
    fi

    if [ -f "${SSH_KEY}.pub" ]; then
        warn "Adicione a chave PÚBLICA abaixo em https://github.com/settings/keys:"
        cat "${SSH_KEY}.pub"
    fi
else
    ok "Chave SSH não solicitada. Pulando etapa..."
fi
