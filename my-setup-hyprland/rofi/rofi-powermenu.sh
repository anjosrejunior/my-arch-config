#!/usr/bin/env bash

# Toggle: se o Rofi já estiver aberto, fecha e sai
if pkill -x rofi; then
    exit 0
fi

options="󰐥 Shutdown\n󰜉 Reboot\n󰌾 Lock\n󰍃 Logout\n󰅖 Cancel"

chosen=$(echo -e "$options" | rofi -dmenu -i -p "Power" -theme ~/.config/rofi/powermenu.rasi)

case "$chosen" in
    "󰐥 Shutdown") poweroff ;;
    "󰜉 Reboot") reboot ;;
    "󰌾 Lock") hyprlock ;;
    "󰍃 Logout") hyprctl dispatch exit ;;
    "󰅖 Cancel") exit 0 ;;
esac