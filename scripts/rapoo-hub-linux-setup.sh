#!/usr/bin/env bash
#
# rapoo-hub-linux-setup.sh
#
# Permite que o navegador (Chromium/Chrome nativo, sem Flatpak) acesse os
# dispositivos HID da Rapoo via WebHID, para usar o Rapoo Hub
# (https://hub.rapoo.com/) no Arch Linux.
#
# O que este script faz:
#   1. Cria o grupo "rapoo" (se não existir).
#   2. Adiciona o seu usuário a esse grupo.
#   3. Cria a regra udev que dá ao grupo "rapoo" acesso aos
#      dispositivos /dev/hidraw* do fabricante (vendor ID 24ae).
#   4. Recarrega as regras udev e reaplica aos dispositivos HID.
#
# Uso:
#   sudo ./rapoo-hub-linux-setup.sh
#
# Depois de rodar, faça LOGOUT e LOGIN (ou reinicie). A troca de grupo
# só vale numa sessão nova. Reconectar o receptor não basta.
#
# Para verificar depois do login:
#   ls -l /dev/hidraw*     -> dispositivos da Rapoo com grupo "rapoo"
#   groups                 -> "rapoo" deve aparecer na lista
#
# Para desfazer:
#   sudo rm /etc/udev/rules.d/99-rapoo.rules
#   sudo gpasswd -d <seu-usuario> rapoo
#   sudo udevadm control --reload-rules && sudo udevadm trigger

set -euo pipefail

VENDOR_ID="24ae"          # vendor ID da Rapoo (confirmado com udevadm)
GROUP_NAME="rapoo"
RULE_FILE="/etc/udev/rules.d/99-rapoo.rules"

# Usuário real que chamou o sudo (e não "root")
TARGET_USER="${SUDO_USER:-}"

if [[ "$EUID" -ne 0 ]]; then
    echo "Erro: rode este script com sudo." >&2
    echo "Exemplo: sudo $0" >&2
    exit 1
fi

if [[ -z "$TARGET_USER" || "$TARGET_USER" == "root" ]]; then
    echo "Erro: não foi possível identificar o usuário. Rode com sudo a partir do seu usuário normal." >&2
    exit 1
fi

echo "==> Criando grupo '$GROUP_NAME' (se não existir)"
groupadd -f "$GROUP_NAME"

echo "==> Adicionando '$TARGET_USER' ao grupo '$GROUP_NAME'"
usermod -aG "$GROUP_NAME" "$TARGET_USER"

echo "==> Escrevendo regra udev em $RULE_FILE"
cat > "$RULE_FILE" <<EOF
SUBSYSTEM=="hidraw", ATTRS{idVendor}=="$VENDOR_ID", MODE="0660", GROUP="$GROUP_NAME", TAG-="uaccess"
EOF

echo "==> Recarregando regras udev"
udevadm control --reload-rules

echo "==> Reaplicando regras aos dispositivos HID"
udevadm trigger --action=add --subsystem-match=hidraw

echo
echo "Pronto. Agora faça LOGOUT e LOGIN (ou reinicie)."
echo "Depois, confira com: ls -l /dev/hidraw*  e  groups"