# ####################################################################################
# ///// DRIVERS NVIDIA — INSTALL ARCH LINUX + KDE PLASMA
# ####################################################################################
# Instala os drivers NVIDIA 580xx quando a opção "1050ti" é escolhida em
# 00-user-input.sh. Configura KMS/mkinitcpio e o parâmetro nvidia_drm.modeset=1
# no bootloader escolhido em 00-user-input.sh (systemd-boot ou GRUB).
# ####################################################################################

# Garante a biblioteca comum carregada (permite execução isolada do script).
[ -n "${MY_SETUP_COMMON_LOADED:-}" ] || . "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib/common.sh"

# Espaço mínimo livre em /boot (MB) para o mkinitcpio -P gerar as imagens com NVIDIA.
NVIDIA_BOOT_MIN_MB=500

# ---- Funções auxiliares (prefixadas para não colidir com outros scripts) ----

nvidia_backup_file() {
    local file="$1"
    local backup="${file}.bak.$(date +%Y%m%d-%H%M%S)"
    sudo cp -a "$file" "$backup"
    ok "Backup criado: $backup"
}

nvidia_check_boot_space() {
    local free_mb

    # Checado antes de qualquer alteração: sem espaço, o mkinitcpio grava imagens truncadas.
    free_mb="$(df -Pm /boot | awk 'NR==2 {print $4}')"

    if [ "$free_mb" -lt "$NVIDIA_BOOT_MIN_MB" ]; then
        err "Apenas ${free_mb} MB livres em /boot (mínimo ${NVIDIA_BOOT_MIN_MB} MB). Libere espaço (kernels antigos, backups .bak) e rode o script de novo."
        return 1
    fi

    ok "Espaço livre em /boot: ${free_mb} MB."
}

nvidia_install_kernel_headers() {
    local headers=(linux-headers)
    local kernel

    # Instala headers apenas dos kernels presentes na máquina.
    for kernel in linux-lts linux-zen linux-hardened; do
        if pacman -Q "$kernel" &>/dev/null; then
            headers+=("${kernel}-headers")
        fi
    done

    sudo pacman -S --needed --noconfirm "${headers[@]}"
}

nvidia_configure_modprobe() {
    local conf="/etc/modprobe.d/nvidia.conf"

    if [ -f "$conf" ]; then
        nvidia_backup_file "$conf"
    fi

    if ! sudo grep -qE '^[[:space:]]*options[[:space:]]+nvidia_drm([[:space:]]|$)' "$conf" 2>/dev/null; then
        echo 'options nvidia_drm modeset=1' | sudo tee -a "$conf" > /dev/null
    elif ! sudo grep -qE '^[[:space:]]*options[[:space:]]+nvidia_drm.*modeset=' "$conf"; then
        sudo sed -i -E '/^[[:space:]]*options[[:space:]]+nvidia_drm/ s/$/ modeset=1/' "$conf"
    else
        sudo sed -i -E '/^[[:space:]]*options[[:space:]]+nvidia_drm/ s/modeset=[01]/modeset=1/' "$conf"
    fi

    ok "modeset=1 configurado em $conf"
}

nvidia_configure_mkinitcpio() {
    local conf="/etc/mkinitcpio.conf"
    local current module

    if [ ! -f "$conf" ]; then
        warn "$conf não encontrado; módulos NVIDIA não foram adicionados."
        return 0
    fi

    if ! sudo grep -qE '^MODULES=' "$conf"; then
        warn "Linha MODULES= não encontrada em $conf; ajuste manualmente."
        return 0
    fi

    nvidia_backup_file "$conf"
    current="$(sudo sed -n 's/^MODULES=(\(.*\))/\1/p' "$conf" | head -n1)"

    for module in nvidia nvidia_modeset nvidia_uvm nvidia_drm; do
        if ! grep -qw "$module" <<< "$current"; then
            current="${current:+$current }$module"
        fi
    done

    sudo sed -i -E "s/^MODULES=\(.*\)/MODULES=($current)/" "$conf"
    ok "Módulos NVIDIA adicionados em $conf: $current"
}

nvidia_configure_systemd_boot() {
    local cmdline="/etc/kernel/cmdline"
    local entry_dir entry
    local configured=0
    local entries=()

    if [ -s "$cmdline" ]; then
        if ! grep -q 'nvidia_drm\.modeset=1' "$cmdline"; then
            nvidia_backup_file "$cmdline"
            if grep -q 'nvidia_drm\.modeset=0' "$cmdline"; then
                sudo sed -i 's/nvidia_drm\.modeset=0/nvidia_drm.modeset=1/' "$cmdline"
            else
                sudo sed -i '1s/$/ nvidia_drm.modeset=1/' "$cmdline"
            fi
        fi
        ok "Parâmetro nvidia_drm.modeset=1 configurado em $cmdline"
        configured=1
    fi

    for entry_dir in /boot/loader/entries /efi/loader/entries; do
        [ -d "$entry_dir" ] || continue

        shopt -s nullglob
        entries=("$entry_dir"/*.conf)
        shopt -u nullglob

        for entry in "${entries[@]}"; do
            if grep -Eq 'nvidia_drm\.modeset=1' "$entry"; then
                continue
            fi

            nvidia_backup_file "$entry"

            if grep -q 'nvidia_drm\.modeset=0' "$entry"; then
                sudo sed -i 's/nvidia_drm\.modeset=0/nvidia_drm.modeset=1/' "$entry"
            elif grep -qE '^options[[:space:]]' "$entry"; then
                sudo sed -i -E '/^options[[:space:]]/ s/$/ nvidia_drm.modeset=1/' "$entry"
            else
                echo 'options nvidia_drm.modeset=1' | sudo tee -a "$entry" > /dev/null
            fi

            ok "Parâmetro adicionado na entrada do systemd-boot: $entry"
            configured=1
        done
    done

    if [ "$configured" -eq 0 ]; then
        warn "Não foi possível localizar /etc/kernel/cmdline nem entradas do systemd-boot."
        warn "Adicione manualmente nvidia_drm.modeset=1 à linha de comando do kernel."
    fi
}

nvidia_configure_grub() {
    local conf="/etc/default/grub"

    if [ ! -f "$conf" ]; then
        err "$conf não encontrado; o GRUB não parece estar instalado."
        return 1
    fi

    if grep -q 'nvidia_drm\.modeset=1' "$conf"; then
        ok "nvidia_drm.modeset=1 já presente em $conf"
        return 0
    fi

    nvidia_backup_file "$conf"

    if grep -q 'nvidia_drm\.modeset=0' "$conf"; then
        sudo sed -i 's/nvidia_drm\.modeset=0/nvidia_drm.modeset=1/' "$conf"
    elif grep -qE '^GRUB_CMDLINE_LINUX_DEFAULT=' "$conf"; then
        # Acrescenta o parâmetro antes da aspa de fechamento da linha.
        sudo sed -i -E '/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/"$/ nvidia_drm.modeset=1"/' "$conf"
    else
        echo 'GRUB_CMDLINE_LINUX_DEFAULT="nvidia_drm.modeset=1"' | sudo tee -a "$conf" > /dev/null
    fi

    if ! grep -q 'nvidia_drm\.modeset=1' "$conf"; then
        err "Não foi possível adicionar nvidia_drm.modeset=1 em $conf; ajuste manualmente."
        return 1
    fi

    ok "Parâmetro nvidia_drm.modeset=1 configurado em $conf"
}

nvidia_regenerate_initramfs() {
    step "Regenerando o initramfs..."
    sudo mkinitcpio -P

    if [ "${BOOTLOADER_CHOICE}" = "systemd-boot" ]; then
        if command -v reinstall-kernels &>/dev/null; then
            step "Atualizando kernels/entradas do systemd-boot..."
            sudo reinstall-kernels || warn "Falha ao executar reinstall-kernels."
        fi
    else
        step "Regenerando /boot/grub/grub.cfg..."
        if command -v grub-mkconfig &>/dev/null; then
            sudo grub-mkconfig -o /boot/grub/grub.cfg
        else
            err "grub-mkconfig não encontrado; rode manualmente: sudo grub-mkconfig -o /boot/grub/grub.cfg"
        fi
    fi
}

nvidia_check_modeset() {
    local modeset_file="/sys/module/nvidia_drm/parameters/modeset"

    if [ -r "$modeset_file" ] && [ "$(cat "$modeset_file")" = "Y" ]; then
        ok "nvidia_drm.modeset está ativo."
    else
        warn "nvidia_drm.modeset ainda não está ativo; confirme após reiniciar."
    fi
}

# ####################################################################################
# ///// DRIVERS NVIDIA (1050ti)
# ####################################################################################

if [ "${NVIDIA_CHOICE:-}" = "1050ti" ]; then
    log "Drivers NVIDIA (1050ti)"

    if [ -z "${BOOTLOADER_CHOICE:-}" ]; then
        err "BOOTLOADER_CHOICE não definido; a escolha do bootloader é feita em 00-user-input.sh."
        exit 1
    fi

    step "Verificando espaço em /boot..."
    if ! nvidia_check_boot_space; then
        exit 1
    fi

    step "Instalando headers dos kernels instalados..."
    nvidia_install_kernel_headers

    step "Instalando suporte NVIDIA..."
    sudo pacman -S --needed --noconfirm libva-nvidia-driver egl-wayland

    step "Instalando drivers NVIDIA 580xx via YAY..."
    yay -S --needed --noconfirm nvidia-580xx-dkms nvidia-580xx-utils lib32-nvidia-580xx-utils

    step "Configurando modeset no modprobe..."
    nvidia_configure_modprobe

    step "Adicionando módulos NVIDIA ao mkinitcpio..."
    nvidia_configure_mkinitcpio

    if [ "${BOOTLOADER_CHOICE}" = "systemd-boot" ]; then
        step "Configurando systemd-boot..."
        nvidia_configure_systemd_boot
    else
        step "Configurando GRUB..."
        nvidia_configure_grub
    fi

    nvidia_regenerate_initramfs

    ok "Drivers NVIDIA 1050ti instalados (bootloader: ${BOOTLOADER_CHOICE})."
    warn "Reinicie o sistema para carregar os drivers e aplicar o modeset."
    nvidia_check_modeset
else
    log "Drivers NVIDIA"

    ok "Opção 'Sem NVIDIA' selecionada. Pulando a instalação de drivers."
fi
