# ####################################################################################
# ///// DESENVOLVIMENTO — INSTALL ARCH LINUX
# ####################################################################################
# Origem: my-setup/bootstrap.sh (blocos "NODE (NVM)", "UV (Astral)" e "DOCKER").
# ####################################################################################

# Garante a biblioteca comum carregada (permite execução isolada do script).
[ -n "${MY_SETUP_COMMON_LOADED:-}" ] || . "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

# ---- Versões e checksums de instaladores remotos (atualizar ao mudar versão) ----
NVM_VERSION="0.40.6"
NVM_SHA256="2ef7e8d4373c1ffd70daa55f919f629e98a619543ffc0a8d892d77a5247e50e4"   # SHA-256 do install.sh do NVM; vazio = apenas exibir e prosseguir
UV_VERSION="0.12.5"
UV_SHA256="504511fbbbd811aeaba6738abc79408956b6c7da0ca35437b3dcc24a41efc111"    # SHA-256 do install.sh do UV; vazio = apenas exibir e prosseguir

# ####################################################################################
# ///// NODE (NVM)
# ####################################################################################

log "Node.js (NVM)"

export NVM_DIR="$HOME/.nvm"

if [ -s "$NVM_DIR/nvm.sh" ]; then
    \. "$NVM_DIR/nvm.sh"
fi

if command -v node &>/dev/null; then
    ok "Node.js já está instalado na máquina. Pulando etapa..."
else
    NVM_INSTALLER="/tmp/nvm-install-${NVM_VERSION}.sh"

    step "Baixando instalador do NVM v${NVM_VERSION}..."
    curl -fsSLo "$NVM_INSTALLER" "https://raw.githubusercontent.com/nvm-sh/nvm/v${NVM_VERSION}/install.sh"

    NVM_ACTUAL_SHA256="$(sha256sum "$NVM_INSTALLER" | awk '{print $1}')"
    if [ -n "$NVM_SHA256" ]; then
        if [ "$NVM_ACTUAL_SHA256" != "$NVM_SHA256" ]; then
            err "Checksum do NVM não confere. Esperado: $NVM_SHA256 | Obtido: $NVM_ACTUAL_SHA256"
            rm -f "$NVM_INSTALLER"
            exit 1
        fi
        ok "Checksum do NVM verificado."
    else
        warn "NVM_SHA256 não definido. Hash obtido: $NVM_ACTUAL_SHA256"
    fi

    step "Executando instalador do NVM..."
    bash "$NVM_INSTALLER"
    rm -f "$NVM_INSTALLER"

    step "Carregando NVM na sessão atual..."
    if [ -s "$NVM_DIR/nvm.sh" ]; then
        \. "$NVM_DIR/nvm.sh"
        ok "NVM carregado."
    else
        err "nvm.sh não encontrado em $NVM_DIR. Instalação do NVM pode ter falhado."
        exit 1
    fi

    step "Instalando Node.js 24..."
    nvm install 24 || { err "Falha ao instalar Node.js 24 via NVM."; exit 1; }

    step "Ativando pnpm via Corepack..."
    if command -v corepack &>/dev/null; then
        export COREPACK_ENABLE_DOWNLOAD_PROMPT=0
        corepack enable pnpm
        ok "pnpm ativado via Corepack."
    else
        warn "Corepack não encontrado; pnpm não ativado."
    fi

    ok "Node.js instalado com sucesso."
fi

# ####################################################################################
# ///// UV (Astral)
# ####################################################################################

log "UV (Astral) v${UV_VERSION}"

UV_INSTALLER="/tmp/uv-install-${UV_VERSION}.sh"

step "Baixando instalador do UV v${UV_VERSION}..."
curl -fsSLo "$UV_INSTALLER" "https://releases.astral.sh/github/uv/releases/download/${UV_VERSION}/uv-installer.sh"

UV_ACTUAL_SHA256="$(sha256sum "$UV_INSTALLER" | awk '{print $1}')"
if [ -n "$UV_SHA256" ]; then
    if [ "$UV_ACTUAL_SHA256" != "$UV_SHA256" ]; then
        err "Checksum do UV não confere. Esperado: $UV_SHA256 | Obtido: $UV_ACTUAL_SHA256"
        rm -f "$UV_INSTALLER"
        exit 1
    fi
    ok "Checksum do UV verificado."
else
    warn "UV_SHA256 não definido. Hash obtido: $UV_ACTUAL_SHA256"
fi

step "Executando instalador do UV..."
sh "$UV_INSTALLER"
rm -f "$UV_INSTALLER"

ok "UV v${UV_VERSION} instalado."

# ####################################################################################
# ///// DOCKER
# ####################################################################################

log "Docker"

step "Instalando Docker e complementos..."
sudo pacman -S --needed --noconfirm \
    docker \
    docker-compose \
    docker-buildx

step "Habilitando serviço Docker no Systemd..."
sudo systemctl enable --now docker

step "Adicionando usuário atual ao grupo docker..."
sudo usermod -aG docker "$USER" || warn "Não foi possível adicionar $USER ao grupo docker."
warn "Reinicie a sessão (logout/login) para o grupo docker ter efeito."

ok "Docker configurado."