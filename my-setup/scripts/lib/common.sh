# ####################################################################################
# ///// BIBLIOTECA COMUM — INSTALL ARCH LINUX
# ####################################################################################
# Infraestrutura compartilhada entre o orquestrador (install.sh) e os scripts
# temáticos em my-setup/scripts/. Extraída do antigo bootstrap.sh.
# Carrega: funções de saída formatada, checklist em TXT, pré-autenticação do
# sudo (com refrescador em background) e traps de limpeza.
# ####################################################################################

# Garante que o bloco seja carregado apenas uma vez.
if [ -n "${MY_SETUP_COMMON_LOADED:-}" ]; then
    return 0 2>/dev/null || exit 0
fi
MY_SETUP_COMMON_LOADED=1

# ---- Diretórios base (definidos uma única vez) ----
# common.sh fica em <my-setup>/scripts/lib/; SCRIPT_DIR é a pasta my-setup.
COMMON_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="$(cd "$COMMON_LIB_DIR/../.." && pwd)"
BIN_DST_DIR="$HOME/.local/bin"

# ---- Funções de saída formatada ----
log()  {
    flush_section
    CURRENT_SECTION="$*"
    SECTION_STATUS="OK"
    SECTION_ISSUES=()
    printf '\n==> %s\n' "$*"
}
step() { printf '  -> %s\n' "$*"; }
ok()   { printf '  [ok] %s\n' "$*"; }
warn() {
    printf '  [aviso] %s\n' "$*" >&2
    [ "$SECTION_STATUS" = "OK" ] && SECTION_STATUS="AVISO"
    SECTION_ISSUES+=("- $*")
}
err()  {
    printf '  [erro] %s\n' "$*" >&2
    SECTION_STATUS="ERRO"
    SECTION_ISSUES+=("- $*")
}

# ---- Checklist em arquivo TXT ----
CHECKLIST_FILE="$HOME/install-checklist-$(date +%Y%m%d-%H%M%S).txt"
CHECKLIST_START="$(date '+%Y-%m-%d %H:%M:%S')"
CURRENT_SECTION=""
SECTION_STATUS="OK"
SECTION_ISSUES=()
TOTAL_OK=0
TOTAL_WARN=0
TOTAL_ERR=0

# Escreve o cabeçalho do checklist imediatamente.
{
    printf '==========================================\n'
    printf '  INSTALL ARCH LINUX — Checklist\n'
    printf '  Iniciado em: %s\n' "$CHECKLIST_START"
    printf '==========================================\n\n'
} > "$CHECKLIST_FILE"

# Registra (ou não) a seção atual no arquivo e reinicia o estado.
flush_section() {
    [ -z "$CURRENT_SECTION" ] && return 0
    local tag
    case "$SECTION_STATUS" in
        OK)    tag="[OK]";    TOTAL_OK=$((TOTAL_OK + 1))   ;;
        AVISO) tag="[AVISO]"; TOTAL_WARN=$((TOTAL_WARN + 1)) ;;
        ERRO)  tag="[ERRO]";  TOTAL_ERR=$((TOTAL_ERR + 1))  ;;
        *)     tag="[OK]";    TOTAL_OK=$((TOTAL_OK + 1))   ;;
    esac
    printf '%-8s %s\n' "$tag" "$CURRENT_SECTION" >> "$CHECKLIST_FILE"
    local issue
    for issue in "${SECTION_ISSUES[@]:-}"; do
        [ -n "$issue" ] && printf '        %s\n' "$issue" >> "$CHECKLIST_FILE"
    done
    CURRENT_SECTION=""
    SECTION_STATUS="OK"
    SECTION_ISSUES=()
}

# Finaliza o checklist escrevendo o rodapé com resumo e timestamp.
finish_checklist() {
    flush_section
    {
        printf '\n==========================================\n'
        printf '  Resumo: %d OK | %d AVISO | %d ERRO\n' "$TOTAL_OK" "$TOTAL_WARN" "$TOTAL_ERR"
        printf '  Finalizado em: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')"
        printf '==========================================\n'
    } >> "$CHECKLIST_FILE"
}

# ---- Pré-autenticação do sudo + refrescador em background ----
sudo -v
( while true; do sudo -v; sleep 50; done 2>/dev/null ) &
SUDO_REFRESH_PID=$!

cleanup() {
    if [ -n "${SUDO_REFRESH_PID:-}" ]; then
        kill -- "$SUDO_REFRESH_PID" 2>/dev/null || true
    fi
}
_CHECKLIST_FINISHED=0
finish_checklist_safe() {
    [ "$_CHECKLIST_FINISHED" -eq 0 ] || return 0
    _CHECKLIST_FINISHED=1
    finish_checklist
}
trap 'cleanup; finish_checklist_safe' EXIT INT TERM
trap 'flush_section; err "Falha na linha $LINENO (comando: $BASH_COMMAND)"; finish_checklist_safe' ERR