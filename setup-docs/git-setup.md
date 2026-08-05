# Algumas ideias para usar no git

```bash
#!/bin/bash

# --- CONFIGURAÇÕES BÁSICAS (OBRIGATÓRIAS) ---
# Substitua pelos seus dados do GitHub/GitLab
git config --global user.name "Seu Nome"
git config --global user.email "seu.email@exemplo.com"

# --- PREFERÊNCIAS DE BRANCH E BRANCHES REMOTAS ---
# Define 'main' como o nome padrão para a branch principal de novos repositórios
git config --global init.defaultBranch main

# --- COMPORTAMENTO DE PULL E REBASE ---
# Faz o 'git pull' aplicar rebase por padrão (evita commits de merge desnecessários)
git config --global pull.rebase true

# Auto-setup de rastreamento remoto ao criar novas branches
git config --global push.autoSetupRemote true

# --- EDITOR E FERRAMENTAS ---
# Define o VS Code como editor padrão do Git (mude para "kitty -e nvim" ou "nano" se preferir)
git config --global core.editor "code --wait"

# --- CREDENCIAIS E SEGURANÇA ---
# Salva suas credenciais em memória/disco para não pedir senha toda hora
git config --global credential.helper store

# --- MELHORIAS VISUAIS E UTILITÁRIAS ---
# Ativa cores na saída do terminal
git config --global color.ui auto

# Converte quebras de linha de forma inteligente (Crucial para Linux)
git config --global core.autocrlf input

# --- ATALHOS (ALIASES) ÚTEIS ---
git config --global alias.s "status -s"
git config --global alias.c "commit -m"
git config --global alias.l "log --oneline --graph --decorate --all"
```

# Salvar chaves ssh na memória RAM

Como salvar a senha da chave SSH na memória?

Para não ter que digitar a senha da sua chave SSH toda vez que fizer um push ou pull, você deve usar o ssh-agent (que guarda a chave desbloqueada na memória RAM enquanto o PC estiver ligado).

Você pode adicionar estes comandos ao arquivo de configuração do seu shell (~/.bashrc ou ~/.zshrc) para que ele gerencie isso automaticamente:

```Bash
# Inicia o agente SSH se ele ainda não estiver rodando
if [ -z "$SSH_AUTH_SOCK" ] ; then
  eval "$(ssh-agent -s)"
fi

# Adiciona a sua chave privada ao agente (substitua id_ed25519 pelo nome da sua chave se for diferente)
ssh-add ~/.ssh/id_ed25519 2>/dev/null
```
