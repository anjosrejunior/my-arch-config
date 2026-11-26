#!/usr/bin/env bash
# ####################################################################################
# ///// MENU DE VPN (WIREGUARD VIA NETWORKMANAGER)
# ####################################################################################
# Lista as conexões WireGuard do NetworkManager e alterna a escolhida:
#   - desligada -> sobe (nmcli connection up)
#   - ligada    -> desce (nmcli connection down)
# Instalado como ~/.local/bin/vpn-menu. Atalho: SUPER + W (hyprland.lua).
# ####################################################################################

# Toggle: se o Rofi já estiver aberto, fecha e sai (mesmo comportamento do powermenu)
if pkill -x rofi; then
    exit 0
fi

notificar() { notify-send "VPN" "$1" 2>/dev/null || true; }

# Conexões WireGuard cadastradas e as que estão ativas agora (campo TYPE no fim da linha).
mapfile -t cadastradas < <(nmcli -t -f NAME,TYPE connection show | grep ':wireguard$' | sed 's/:wireguard$//')
mapfile -t ativas < <(nmcli -t -f NAME,TYPE connection show --active | grep ':wireguard$' | sed 's/:wireguard$//')

if [ "${#cadastradas[@]}" -eq 0 ]; then
    notificar "Nenhuma conexão WireGuard cadastrada no NetworkManager."
    exit 1
fi

# Monta as opções: rótulo visível -> nome da conexão
declare -A NOME_DA_OPCAO=()
opcoes=""
for nome in "${cadastradas[@]}"; do
    if printf '%s\n' "${ativas[@]}" | grep -qxF "$nome"; then
        rotulo="● $nome (ligada)"
    else
        rotulo="○ $nome (desligada)"
    fi
    NOME_DA_OPCAO["$rotulo"]="$nome"
    opcoes+="$rotulo"$'\n'
done

escolha=$(printf '%s' "$opcoes" | rofi -dmenu -i -p "VPN" -theme ~/.config/rofi/powermenu.rasi)
[ -n "$escolha" ] || exit 0

nome="${NOME_DA_OPCAO[$escolha]:-}"
if [ -z "$nome" ]; then
    exit 0
fi

case "$escolha" in
    "● "*)
        if nmcli connection down id "$nome" >/dev/null 2>&1; then
            notificar "$nome desligada."
        else
            notificar "Falha ao desligar $nome."
        fi
        ;;
    *)
        if nmcli connection up id "$nome" >/dev/null 2>&1; then
            notificar "$nome ligada."
        else
            notificar "Falha ao ligar $nome."
        fi
        ;;
esac
