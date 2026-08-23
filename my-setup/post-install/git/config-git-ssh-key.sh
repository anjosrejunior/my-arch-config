# ####################################################################################
# ///// GIT — CONFIGURAÇÃO E CHAVE SSH (GITHUB)
# ####################################################################################

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

# Garante que o diretório ~/.ssh existe com as permissões corretas
mkdir -p "$SSH_DIR"
chmod 700 "$SSH_DIR"

if [ -f "$SSH_KEY" ]; then
    warn "Já existe uma chave SSH em $SSH_KEY. Pulando a geração."
else
    # Pede a passphrase para proteger a chave privada (sem salvar em arquivo)
    while [ -z "${SSH_PASSPHRASE:-}" ]; do
        read -rsp "Digite uma senha (passphrase) para a chave SSH do GitHub: " SSH_PASSPHRASE
        echo ""
        [ -z "${SSH_PASSPHRASE:-}" ] && warn "A senha não pode ficar em branco."
    done

    # 1. Gera o par de chaves (github_key e github_key.pub)
    ssh-keygen -t ed25519 -C "$GIT_EMAIL" -f "$SSH_KEY" -N "$SSH_PASSPHRASE" > /dev/null 2>&1
    chmod 600 "$SSH_KEY"
    chmod 644 "${SSH_KEY}.pub"

    # 2. Inicia o ssh-agent e adiciona a chave na memória RAM
    eval "$(ssh-agent -s)" > /dev/null
    echo "$SSH_PASSPHRASE" | ssh-add "$SSH_KEY" > /dev/null 2>&1

    # 3. Configura o ~/.ssh/config para mapear o github.com a esta chave
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

    # 4. Cria o arquivo TXT na Home contendo APENAS a chave pública
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