#!/bin/bash

# Espera da Internet
timeout 15s bash -c 'until ping -c 1 1.1.1.1 &>/dev/null; do sleep 1; done'

LOCAL_DIR="$HOME/documents/ocarina-of-time/"
REMOTE="mydrive:OCARINA OF TIME/VAULT"
LOG_FILE="$HOME/rclone_sync.log"

# --- TESTE 1: O REMOTO 'mydrive' EXISTE NO RCLONE? ---
if ! rclone listremotes 2>/dev/null | grep -q "^mydrive:"; then
    echo "$(date '+%Y/%m/%d %H:%M:%S') WARNING: Remoto 'mydrive' nao configurado no Rclone. Abortando sync silenciosamente." >> "$LOG_FILE"
    exit 0
fi

# --- TESTE 2: TEM CONEXÃO COM A INTERNET? ---
if ! ping -q -c 1 -W 3 8.8.8.8 >/dev/null 2>&1; then
    echo "$(date '+%Y/%m/%d %H:%M:%S') ERROR: Sem conexao com a internet. Abortando sync." >> "$LOG_FILE"
    exit 0
fi

ACTION="${1:-stop}" # Se não passar parâmetro, o padrão é stop (push)

if [ "$ACTION" = "start" ]; then
    echo "$(date '+%Y/%m/%d %H:%M:%S') INFO: [START] Baixando atualizações do Drive para o PC..." >> "$LOG_FILE"
    # Puxa as alterações do Google Drive para a máquina local
    rclone sync "$REMOTE" "$LOCAL_DIR" \
      --create-empty-src-dirs \
      --transfers=4 \
      --checkers=8 \
      --log-file="$LOG_FILE" \
      --log-level=INFO

elif [ "$ACTION" = "stop" ]; then
    # --- TESTE 3: VALIDAÇÃO DE SEGURANÇA LOCAL ---
    # Verifica se os diretórios essenciais do Obsidian existem localmente antes de enviar
    if [ ! -d "$LOCAL_DIR/.obsidian" ] || [ ! -d "$LOCAL_DIR/Notes" ]; then
        echo "$(date '+%Y/%m/%d %H:%M:%S') ERROR: [STOP] Pastas essenciais (.obsidian ou Notes) nao foram encontradas em '$LOCAL_DIR'. Abortando sync para evitar sobrescrita/deletar dados no Drive." >> "$LOG_FILE"
        exit 1
    fi

    echo "$(date '+%Y/%m/%d %H:%M:%S') INFO: [STOP] Enviando atualizações do PC para o Drive..." >> "$LOG_FILE"
    BACKUP_DIR="mydrive:OCARINA OF TIME/BACKUP/$(date +%Y-%m-%d_%H-%M-%S)"
    
    # Envia as alterações da máquina local para o Google Drive com backup
    rclone sync "$LOCAL_DIR" "$REMOTE" \
      --backup-dir "$BACKUP_DIR" \
      --create-empty-src-dirs \
      --transfers=4 \
      --checkers=8 \
      --log-file="$LOG_FILE" \
      --log-level=INFO
fi