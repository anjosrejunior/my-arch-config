# ####################################################################################
# ///// GIT — CONFIGURAÇÃO E CHAVE SSH (GITHUB)
# ####################################################################################

[ -n "${MY_SETUP_COMMON_LOADED:-}" ] || . "$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)/scripts/lib/common.sh"

log "Verificando dependências de SSH..."
if ! command -v ssh-keygen &> /dev/null; then
    log "Instalando OpenSSH..."
    sudo pacman -S --noconfirm openssh
fi

log "Configuração de Chave SSH para o GitHub"

SSH_DIR="$HOME/.ssh"
SSH_KEY="$SSH_DIR/github_key"
SSH_CONFIG="$SSH_DIR/config"
PUBLIC_KEY_TXT="$HOME/chave_publica_github.txt"

mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

if [ -f "$SSH_KEY" ]; then
    warn "Já existe uma chave SSH em $SSH_KEY. Pulando a geração."
else
    while [ -z "${SSH_PASSPHRASE:-}" ]; do
        read -rsp "Digite uma senha (passphrase) para a chave SSH do GitHub: " SSH_PASSPHRASE
        echo ""
        [ -z "${SSH_PASSPHRASE:-}" ] && warn "A senha não pode ficar em branco."
    done

    ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$SSH_KEY" -N "$SSH_PASSPHRASE" > /dev/null 2>&1
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

    ok "Chave SSH gerada com sucesso!"
    ok "Chave privada: $SSH_KEY"
    ok "Cópia da chave pública pronta em: $PUBLIC_KEY_TXT"
fi

echo ""
warn "Sua chave PÚBLICA do GitHub está pronta abaixo e em '$PUBLIC_KEY_TXT':"
echo "--------------------------------------------------------------------------------"
cat "${SSH_KEY}.pub"
echo "--------------------------------------------------------------------------------"