# ####################################################################################
# ///// ENTRADA DO USUÁRIO — INSTALL ARCH LINUX
# ####################################################################################
# Origem: my-setup/bootstrap.sh (blocos "GIT — PERFIL DO USUÁRIO" e
# "SELEÇÃO DE DRIVERS DE VÍDEO").
# Coleta interativa (nome/email do Git e driver NVIDIA) usada pelos demais
# scripts, que são ativados no mesmo processo por install.sh.
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

NVIDIA_CHOICE=""

while [ -z "${NVIDIA_CHOICE}" ]; do
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