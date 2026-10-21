#!/bin/bash

# Lista de serviços de usuário para verificar
SERVICES=(
    "pipewire.service"
    "pipewire-pulse.service"
    "wireplumber.service"
    "obs-v4l2loopback.service"
    "obsidian-sync.service"
)

# Cores para facilitar a leitura no terminal
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # Sem cor (Reset)

echo "=== Verificando Status dos Serviços de Usuário ==="
echo ""

for SERVICE in "${SERVICES[@]}"; do
    if systemctl --user is-active --quiet "$SERVICE"; then
        echo -e "[ ${GREEN}OK${NC} ] $SERVICE está rodando."
    else
        echo -e "[ ${RED}FALHA${NC} ] $SERVICE NÃO está rodando."
    fi
done

echo ""