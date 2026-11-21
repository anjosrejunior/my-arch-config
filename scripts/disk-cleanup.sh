#!/bin/bash
# Libera espaço em disco no Arch Linux (btrfs + Snapper, Docker, Flatpak e caches).
# Uso: ./disk-cleanup.sh
#   JOURNAL_MAX=100M ./disk-cleanup.sh   # limite do journal (padrão: 200M)
#
# Passos seguros rodam direto. Passos que podem apagar dados úteis (containers
# parados, imagens locais, snapshots) pedem confirmação, com resposta padrão "não".
# Sem terminal interativo, esses passos são pulados.
# Explicação completa: setup-docs/disk-cleanup.md

set -euo pipefail

JOURNAL_MAX="${JOURNAL_MAX:-200M}"

log()  { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
ok()   { printf '    \033[1;32mOK\033[0m %s\n' "$*"; }
warn() { printf '    \033[1;33mAVISO\033[0m %s\n' "$*"; }
err()  { printf '\033[1;31mERRO\033[0m %s\n' "$*" >&2; }

have() { command -v "$1" >/dev/null 2>&1; }

# Espaço livre em bytes e uso (%) da raiz
espaco_livre() { df --output=avail -B1 / | tail -n 1 | tr -d ' '; }
uso_disco()    { df --output=pcent / | tail -n 1 | tr -d ' '; }
legivel()      { numfmt --to=iec "$1"; }

# Pergunta s/N. Sem terminal (stdin não é tty), responde "não" sem perguntar.
pergunta() {
    [[ -t 0 ]] || return 1
    local resposta
    read -r -p "    $1 [s/N] " resposta
    [[ "$resposta" =~ ^[sSyY]$ ]]
}

# Roda uma limpeza. Se falhar, avisa e segue para o próximo passo.
passo() {
    local descricao="$1"
    shift
    log "$descricao"
    if "$@"; then
        ok "concluído"
    else
        warn "falhou: $descricao (continuando)"
    fi
}

# --- Limpezas seguras (não apagam dados úteis) ---

limpar_journal() {
    sudo journalctl --vacuum-size="$JOURNAL_MAX" | tail -n 1
}

limpar_flatpak() {
    # Remove só runtimes e extensões que nenhum app usa
    flatpak uninstall --unused -y
}

limpar_docker_sem_tag() {
    # Cache de build sem referência e imagens "dangling" (sem tag)
    docker builder prune -f | tail -n 1
    docker image prune -f | tail -n 1
}

limpar_aur() {
    # Cache do pacman (versões antigas), repositórios não usados e builds antigos do AUR
    yay -Sc --noconfirm | tail -n 3
}

limpar_go() {
    go clean -cache
}

limpar_pnpm() {
    pnpm store prune
}

# --- Limpezas que apagam dados (só com confirmação) ---

limpar_docker_parados() {
    # Dados gravados só dentro do container (fora de volumes) são perdidos
    docker container prune -f | tail -n 1
}

limpar_docker_imagens() {
    # Imagens construídas localmente precisam ser reconstruídas depois
    docker image prune -a -f | tail -n 1
}

limpar_docker_cache_completo() {
    # Próximos builds ficam mais lentos
    docker builder prune -a -f | tail -n 1
}

limpar_snapshots() {
    # Apaga snapshots acima dos limites de retenção atuais de cada config do Snapper
    local config
    for config in root home; do
        sudo snapper -c "$config" cleanup timeline
    done
}

# ---------------------------------------------------------------------------

if [[ $EUID -eq 0 ]]; then
    err "não rode como root. O script usa sudo quando precisa."
    exit 1
fi

DOCKER_OK=0
if have docker; then
    if docker info >/dev/null 2>&1; then
        DOCKER_OK=1
    else
        warn "Docker instalado, mas inacessível (daemon parado ou sem permissão). Docker será pulado."
    fi
fi

sudo -v

ANTES=$(espaco_livre)
log "Situação inicial"
df -h /

# Passos seguros
if have journalctl; then
    passo "Journal do systemd (mantém no máximo $JOURNAL_MAX)" limpar_journal
fi

if have flatpak; then
    passo "Flatpak: runtimes não usados" limpar_flatpak
fi

if [[ $DOCKER_OK -eq 1 ]]; then
    passo "Docker: cache de build e imagens sem tag" limpar_docker_sem_tag
fi

if have yay; then
    passo "AUR e cache do pacman (yay)" limpar_aur
else
    warn "yay não encontrado. Cache do pacman/AUR não foi limpo."
fi

if have go; then
    passo "Cache de compilação do Go" limpar_go
fi

if have pnpm; then
    passo "Store do pnpm" limpar_pnpm
fi

# Passos que apagam dados
log "Limpezas que apagam dados (pedem confirmação)"

if [[ $DOCKER_OK -eq 1 ]]; then
    if pergunta "Docker: remover containers parados? (dados fora de volumes serão perdidos)"; then
        passo "Docker: containers parados" limpar_docker_parados
    fi
    if pergunta "Docker: remover TODAS as imagens sem container? (imagens construídas localmente precisam ser reconstruídas)"; then
        passo "Docker: imagens sem container" limpar_docker_imagens
    fi
    if pergunta "Docker: remover TODO o cache de build? (próximos builds ficam mais lentos)"; then
        passo "Docker: cache de build completo" limpar_docker_cache_completo
    fi
fi

if have snapper; then
    if pergunta "Snapper: aplicar a retenção atual e apagar snapshots excedentes? (irreversível)"; then
        passo "Snapper: cleanup timeline (root e home)" limpar_snapshots
    fi
fi

# Resultado
DEPOIS=$(espaco_livre)
log "Resultado"
df -h /

if (( DEPOIS > ANTES )); then
    ok "Liberado: $(legivel $((DEPOIS - ANTES)))"
else
    warn "Nenhum espaço novo aparente. Em btrfs, apagar snapshots pode levar alguns minutos para refletir. Rode 'df -h /' de novo depois."
fi

USO=$(uso_disco)
if (( ${USO%\%} > 85 )); then
    warn "Disco com ${USO} de uso. Acima de 85% o btrfs pode ficar lento. Considere revisar snapshots e imagens Docker."
fi
