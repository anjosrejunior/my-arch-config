# ####################################################################################
# ///// ENTRADA DO USUÁRIO — INSTALL ARCH LINUX + KDE PLASMA
# ####################################################################################
# Coleta o perfil do Git, a escolha de drivers NVIDIA (1050ti ou sem NVIDIA), o
# bootloader (systemd-boot ou GRUB) e os dados das chaves GPG e SSH. Esses valores
# são usados pelos scripts seguintes, ativados no mesmo processo pelo install.sh.
# Também aceita GIT_NAME, GIT_EMAIL, NVIDIA_CHOICE, BOOTLOADER_CHOICE, GPG_CHOICE e
# SSH_CHOICE (yes|no) via ambiente.
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

# ####################################################################################
# ///// SELEÇÃO DE BOOTLOADER
# ####################################################################################

log "Seleção de bootloader"

# Valida um valor pré-selecionado via ambiente (BOOTLOADER_CHOICE).
if [ -n "${BOOTLOADER_CHOICE:-}" ]; then
    case "${BOOTLOADER_CHOICE}" in
        systemd-boot|grub)
            ok "Opção pré-selecionada: ${BOOTLOADER_CHOICE}"
            ;;
        *)
            warn "BOOTLOADER_CHOICE inválido ('${BOOTLOADER_CHOICE}'). Escolha manualmente."
            BOOTLOADER_CHOICE=""
            ;;
    esac
fi

while [ -z "${BOOTLOADER_CHOICE:-}" ]; do
    echo "---------------------------------"
    echo "1) systemd-boot"
    echo "2) GRUB"
    echo "---------------------------------"
    read -rp "Escolha o bootloader [1 ou 2]: " OPTION

    case "${OPTION}" in
        1)
            BOOTLOADER_CHOICE="systemd-boot"
            ok "Opção selecionada: systemd-boot"
            ;;
        2)
            BOOTLOADER_CHOICE="grub"
            ok "Opção selecionada: GRUB"
            ;;
        *)
            warn "Opção inválida. Digite 1 ou 2."
            ;;
    esac
done

# ####################################################################################
# ///// CHAVES GPG E SSH
# ####################################################################################

log "Seleção de chaves GPG e SSH"

# Pergunta sim/não e grava "yes" ou "no" na variável cujo nome é o segundo argumento.
ask_yes_no() {
    local pergunta="$1"
    local resposta

    while true; do
        read -rp "$pergunta [s/N]: " resposta
        case "${resposta:-}" in
            [sS]|[sS][iI][mM])
                printf -v "$2" '%s' "yes"
                return 0
                ;;
            [nN]|[nN][aAãÃ][oO]|"")
                printf -v "$2" '%s' "no"
                return 0
                ;;
            *)
                warn "Resposta inválida. Use 's' (sim) ou 'n' (não)."
                ;;
        esac
    done
}

# Pergunta só se o valor não veio pré-selecionado via ambiente (GPG_CHOICE).
[ -n "${GPG_CHOICE:-}" ] || ask_yes_no "Criar chave GPG?" GPG_CHOICE

if [ "$GPG_CHOICE" = "yes" ]; then
    read -rp "Nome para a chave GPG [$GIT_NAME]: " GPG_NAME
    GPG_NAME="${GPG_NAME:-$GIT_NAME}"

    read -rp "E-mail para a chave GPG [$GIT_EMAIL]: " GPG_EMAIL
    GPG_EMAIL="${GPG_EMAIL:-$GIT_EMAIL}"

    ok "Chave GPG será criada para: $GPG_NAME <$GPG_EMAIL>"
fi

[ -n "${SSH_CHOICE:-}" ] || ask_yes_no "Gerar chave SSH para o GitHub?" SSH_CHOICE

if [ "$SSH_CHOICE" = "yes" ]; then
    ok "Chave SSH para o GitHub será gerada com o e-mail do Git: $GIT_EMAIL"
fi
