#!/usr/bin/env bash
#
# secure-boot-setup.sh
#
# Ativa o Secure Boot no Arch Linux com sbctl, seguindo setup-docs/secure-boot.md.
# Você escolhe o bootloader em um menu: GRUB (mesmo fluxo do tutorial) ou systemd-boot.
#
# Antes de rodar, coloque a BIOS em Setup Mode (limpe as chaves do Secure Boot).
# O script:
#   1. Confere UEFI, instala o sbctl e confere se a BIOS está em Setup Mode.
#   2. Cria as chaves do sbctl (se ainda não existirem).
#   3. Reinstala/atualiza o bootloader escolhido.
#   4. Assina o bootloader e os kernels.
#   5. Grava as chaves na BIOS com as chaves da Microsoft (-m), para o Windows continuar bootando.
#
# Tudo é feito ANTES de gravar as chaves: depois do enroll a BIOS sai do Setup Mode.
#
# Uso:
#   sudo ./secure-boot-setup.sh
#
# Depois de rodar, ative o Secure Boot na BIOS (F10 para salvar) e confira com:
#   sbctl status

set -Eeuo pipefail

# Pasta padrão do sbctl para as chaves.
SBCTL_KEY_FILE="/var/lib/sbctl/keys/PK/PK.key"

# Arquivos assinados no fluxo do GRUB (lista do setup-docs/secure-boot.md).
# O glob pega qualquer UKI em /boot/EFI/Linux, não só os nomes fixos do tutorial.
ARQUIVOS_GRUB=(
    /boot/EFI/BOOT/BOOTX64.EFI
    /boot/EFI/BOOT/grubx64.efi
    /boot/grub/x86_64-efi/core.efi
    /boot/grub/x86_64-efi/grub.efi
    /boot/EFI/Linux/*.efi
    /boot/vmlinuz-linux
    /boot/vmlinuz-linux-lts
)

# Arquivos assinados no fluxo do systemd-boot. O glob pega as UKIs, se existirem.
ARQUIVOS_SYSTEMD_BOOT=(
    /boot/EFI/systemd/systemd-bootx64.efi
    /boot/EFI/BOOT/BOOTX64.EFI
    /boot/vmlinuz-linux
    /boot/vmlinuz-linux-lts
    /boot/EFI/Linux/*.efi
)

BOOTLOADER=""

# ---- Funções de saída (mesmo formato de scripts/lib/common.sh) ----
log()  { printf '\n==> %s\n' "$*"; }
step() { printf '  -> %s\n' "$*"; }
ok()   { printf '  [ok] %s\n' "$*"; }
warn() { printf '  [aviso] %s\n' "$*" >&2; }
err()  { printf '  [erro] %s\n' "$*" >&2; }

trap 'err "Falha na linha $LINENO (comando: $BASH_COMMAND)"' ERR

verificar_ambiente() {
    log "Verificando o ambiente"

    if [ "$EUID" -ne 0 ]; then
        err "Rode como root: sudo $0"
        exit 1
    fi

    if [ ! -d /sys/firmware/efi ]; then
        err "O sistema não está em modo UEFI. Secure Boot exige UEFI."
        exit 1
    fi

    if [ ! -d /boot/EFI ]; then
        err "/boot/EFI não encontrado. A partição EFI precisa estar montada em /boot."
        exit 1
    fi

    ok "UEFI e partição EFI encontrados."
}

instalar_sbctl() {
    log "Instalando o sbctl"

    if command -v sbctl &>/dev/null; then
        ok "sbctl já instalado."
        return 0
    fi

    pacman -S --needed --noconfirm sbctl
    ok "sbctl instalado."
}

confirmar_setup_mode() {
    log "Conferindo o Setup Mode da BIOS"

    local status
    status="$(sbctl status 2>/dev/null || true)"

    # Só a linha "Setup Mode:" interessa; "Secure Boot: ✓ Enabled" não pode confundir a checagem.
    if grep -q 'Setup Mode:.*Enabled' <<< "$status"; then
        ok "BIOS em Setup Mode."
        return 0
    fi

    err "A BIOS não está em Setup Mode."
    err "Entre na BIOS, vá em Key Management e escolha 'Clear Secure Boot Keys' (ou 'Delete All Keys'), salve e rode o script de novo."
    exit 1
}

escolher_bootloader() {
    log "Escolha do bootloader"

    local opcao

    while [ -z "$BOOTLOADER" ]; do
        echo "1) GRUB"
        echo "2) systemd-boot"
        read -rp "Qual bootloader está sendo usado? [1 ou 2]: " opcao

        case "$opcao" in
            1) BOOTLOADER="grub";         ok "Opção selecionada: GRUB" ;;
            2) BOOTLOADER="systemd-boot"; ok "Opção selecionada: systemd-boot" ;;
            *) warn "Opção inválida: '$opcao'" ;;
        esac
    done
}

criar_chaves() {
    log "Chaves do sbctl"

    if [ -f "$SBCTL_KEY_FILE" ]; then
        ok "Chaves já existem em $SBCTL_KEY_FILE."
        return 0
    fi

    step "Criando as chaves de Secure Boot..."
    sbctl create-keys
    ok "Chaves criadas."
}

preparar_grub() {
    log "Reinstalando o GRUB (com --disable-shim-lock, como no tutorial)"

    if ! command -v grub-install &>/dev/null; then
        err "grub-install não encontrado. Instale o pacote grub."
        exit 1
    fi

    # Sem --disable-shim-lock o GRUB tenta usar o shim e dá "prohibited by secure boot policy".
    grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=BOOT --modules="tpm" --disable-shim-lock
    grub-mkconfig -o /boot/grub/grub.cfg
    ok "GRUB reinstalado e grub.cfg regenerado."
}

preparar_systemd_boot() {
    log "Instalando/atualizando o systemd-boot"

    if ! command -v bootctl &>/dev/null; then
        err "bootctl não encontrado. Ele vem com o pacote systemd."
        exit 1
    fi

    bootctl install
    ok "systemd-boot instalado na ESP."
}

assinar() {
    local arquivo="$1"

    if [ ! -f "$arquivo" ]; then
        step "Pulado (não existe): $arquivo"
        return 0
    fi

    # -s salva o arquivo no banco do sbctl, para o hook do pacman re-assinar nas atualizações.
    sbctl sign -s "$arquivo"
    ok "Assinado: $arquivo"
}

assinar_arquivos() {
    log "Assinando o bootloader e os kernels"

    local arquivos arquivo

    if [ "$BOOTLOADER" = "grub" ]; then
        arquivos=("${ARQUIVOS_GRUB[@]}")
    else
        arquivos=("${ARQUIVOS_SYSTEMD_BOOT[@]}")
    fi

    for arquivo in "${arquivos[@]}"; do
        assinar "$arquivo"
    done
}

conferir_assinaturas() {
    log "Conferindo as assinaturas"

    # Gravar as chaves com um kernel sem assinatura deixa o sistema sem boot.
    if sbctl verify | grep -q 'not signed'; then
        err "Há arquivos sem assinatura (listados acima). Corrija antes de gravar as chaves."
        exit 1
    fi

    ok "Todos os arquivos registrados estão assinados."
}

gravar_chaves() {
    log "Gravando as chaves na BIOS"

    # -m inclui as chaves da Microsoft, necessárias para o Windows continuar bootando com Secure Boot.
    sbctl enroll-keys -m
    ok "Chaves gravadas na BIOS."
}

proximos_passos() {
    log "Próximos passos"

    echo "1. Reinicie e entre na BIOS (Delete ou F2)."
    echo "2. Advanced Mode (F7) -> Boot -> Secure Boot -> Enabled."
    echo "3. Aperte F10 para salvar e reinicie."
    echo "4. Depois de iniciar o Linux, rode: sbctl status"
    echo "   Resultado esperado: Setup Mode: Disabled e Secure Boot: Enabled."
}

verificar_ambiente
instalar_sbctl
confirmar_setup_mode
escolher_bootloader
criar_chaves

if [ "$BOOTLOADER" = "grub" ]; then
    preparar_grub
else
    preparar_systemd_boot
fi

assinar_arquivos
conferir_assinaturas
gravar_chaves
proximos_passos
