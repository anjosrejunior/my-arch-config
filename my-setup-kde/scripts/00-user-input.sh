# ####################################################################################
# ///// ENTRADA DO USUÁRIO — INSTALL ARCH LINUX + KDE PLASMA
# ####################################################################################
# Coleta o perfil do Git e a escolha de drivers NVIDIA (1050ti ou sem NVIDIA).
# Esses valores são usados pelos scripts seguintes, ativados no mesmo processo
# pelo install.sh. Também aceita GIT_NAME, GIT_EMAIL e NVIDIA_CHOICE via ambiente.
# ####################################################################################

# Garante a biblioteca comum carregada (permite execução isolada do script).
[ -n "${MY_SETUP_COMMON_LOADED:-}" ] || . "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

# ####################################################################################
# ///// GIT — PERFIL DO USUÁRIO
# ####################################################################################

log "Configuração do Perfil do Git"

while [ -z "${GIT_NAME:-}" ]; do
    read -rp "Digite o seu Nome para o Git: " GIT_NAME
    if [ -z "${GIT_NAME:-}" ]; then
        warn "O nome não pode ficar em branco."
    elif [[ "${GIT_NAME}" =~ [[:cntrl:]] ]]; then
        warn "O nome contém caracteres de controle inválidos."
        GIT_NAME=""
    fi
done

while [ -z "${GIT_EMAIL:-}" ] || [[ "${GIT_EMAIL}" != *@* ]]; do
    read -rp "Digite o seu E-mail para o Git: " GIT_EMAIL
    if [ -z "${GIT_EMAIL:-}" ]; then
        warn "O e-mail não pode ficar em branco."
    elif [[ "${GIT_EMAIL}" != *@* ]]; then
        warn "E-mail inválido (deve conter '@')."
        GIT_EMAIL=""
    fi
done

ok "Perfil do Git coletado: $GIT_NAME <$GIT_EMAIL>"

# ####################################################################################
# ///// SELEÇÃO DE DRIVERS DE VÍDEO
# ####################################################################################

log "Seleção de perfil de drivers"

# Valida um valor pré-selecionado via ambiente (NVIDIA_CHOICE).
if [ -n "${NVIDIA_CHOICE:-}" ]; then
    case "${NVIDIA_CHOICE}" in
        1050ti|no_nvidia)
            ok "Opção pré-selecionada: ${NVIDIA_CHOICE}"
            ;;
        *)
            warn "NVIDIA_CHOICE inválido ('${NVIDIA_CHOICE}'). Escolha manualmente."
            NVIDIA_CHOICE=""
            ;;
    esac
fi

while [ -z "${NVIDIA_CHOICE:-}" ]; do
    echo "---------------------------------"
    echo "1) Sem drivers NVIDIA"
    echo "2) 1050ti (Drivers NVIDIA)"
    echo "---------------------------------"
    read -rp "Escolha uma opção [1 ou 2]: " OPTION

    case "${OPTION}" in
        1)
            NVIDIA_CHOICE="no_nvidia"
            ok "Opção selecionada: Sem drivers NVIDIA"
            ;;
        2)
            NVIDIA_CHOICE="1050ti"
            ok "Opção selecionada: Drivers NVIDIA (1050ti)"
            ;;
        *)
            warn "Opção inválida. Digite 1 ou 2."
            ;;
    esac
done
