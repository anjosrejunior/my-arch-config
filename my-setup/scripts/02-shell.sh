# ####################################################################################
# ///// SHELL — INSTALL ARCH LINUX
# ####################################################################################
# Origem: my-setup/bootstrap.sh (bloco "ZSH").
# ####################################################################################

# Garante a biblioteca comum carregada (permite execução isolada do script).
[ -n "${MY_SETUP_COMMON_LOADED:-}" ] || . "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

# ####################################################################################
# ///// ZSH
# ####################################################################################

log "Configuração do ZSH"

step "Instalando ZSH e plugins..."
sudo pacman -S --needed --noconfirm \
    zsh \
    starship \
    zsh-autosuggestions \
    zsh-syntax-highlighting \
    fzf

step "Criando arquivos de configuração..."
touch ~/.zshrc ~/.zprofile

step "Adicionando configurações ao ~/.zshrc..."
if ! grep -q "zsh-autosuggestions.zsh" ~/.zshrc 2>/dev/null; then
    cat >> ~/.zshrc << 'EOF'
# Plugins
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Fuzzy Find
source <(fzf --zsh)

# Starship Prompt
eval "$(starship init zsh)"

# Inicia o ssh-agent se ainda não estiver rodando na sessão
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)" > /dev/null
fi

# Alias do Zed
alias zeditor='flatpak run dev.zed.Zed'
EOF
    ok "Configurações adicionadas ao ~/.zshrc."
else
    ok "~/.zshrc já contém as configurações."
fi

step "Definindo ZSH como shell padrão..."
ZSH_PATH="$(command -v zsh || echo /usr/bin/zsh)"

# Detecta o usuário real (caso o script esteja rodando via sudo)
REAL_USER="${SUDO_USER:-$USER}"

if grep -q "$ZSH_PATH" /etc/shells 2>/dev/null; then
    # Usa sudo chsh especificando o usuário explicitamente
    if sudo chsh -s "$ZSH_PATH" "$REAL_USER"; then
        ok "ZSH definido como shell padrão para $REAL_USER."
        warn "Faça logout/login (ou reinicie a sessão) para a mudança ter efeito."
    else
        warn "Falha ao definir zsh. Tente manualmente: chsh -s $ZSH_PATH"
    fi
else
    warn "$ZSH_PATH não está em /etc/shells; shell padrão não alterado."
fi

step "Criando a pasta ~/.config e configurando o Starship..."

# Garante que o diretório ~/.config existe
mkdir -p ~/.config

# Verifica se o arquivo já possui a configuração do scan_timeout
if ! grep -q "scan_timeout" ~/.config/starship.toml 2>/dev/null; then
    cat >> ~/.config/starship.toml << 'EOF'
# Aumenta o tempo limite de varredura para máquinas mais antigas
scan_timeout = 500
command_timeout = 500

# Otimizações de desempenho para o Git em máquinas mais fracas
# [git_status]
# untracked = false
# modified = false
EOF
    ok "Configurações do Starship salvas em ~/.config/starship.toml."
else
    ok "~/.config/starship.toml já está configurado."
fi