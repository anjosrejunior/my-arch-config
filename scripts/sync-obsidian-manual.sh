#!/bin/bash
# Salva manualmente as alterações do vault do Obsidian no Google Drive (rclone).
# Uso: ./sync-obsidian-manual.sh

set -euo pipefail

LOCAL_DIR="$HOME/Documents/ocarina-of-time/"
REMOTE="mydrive:OCARINA OF TIME/VAULT"
BACKUP_DIR="mydrive:OCARINA OF TIME/BACKUP/$(date +%Y-%m-%d_%H-%M-%S)"

REMOTES="$(rclone listremotes)"
if ! grep -q "^mydrive:" <<< "$REMOTES"; then
    echo "ERRO: remoto 'mydrive' não configurado no rclone." >&2
    exit 1
fi

# Não envia nada se as pastas essenciais não existirem localmente (evita apagar o Drive)
if [ ! -d "$LOCAL_DIR/.obsidian" ] || [ ! -d "$LOCAL_DIR/Notes" ]; then
    echo "ERRO: '.obsidian' ou 'Notes' não encontrados em '$LOCAL_DIR'. Nada foi enviado." >&2
    exit 1
fi

echo "Enviando alterações do PC para o Drive..."
# Arquivos alterados ou apagados localmente vão para BACKUP_DIR antes de serem substituídos no Drive
rclone sync "$LOCAL_DIR" "$REMOTE" \
    --backup-dir "$BACKUP_DIR" \
    --create-empty-src-dirs \
    --transfers=4 \
    --checkers=8 \
    --progress

echo "Pronto. Versões substituídas (se houver) ficam em: $BACKUP_DIR"
