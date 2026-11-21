# Limpeza de disco no Arch Linux

> **Aplica-se a:** Arch Linux com btrfs (a seção de Snapper vale só se você usa Snapper), Docker e/ou Flatpak.
>
> **Script de rotina:** [`scripts/disk-cleanup.sh`](../scripts/disk-cleanup.sh). Rode com `./scripts/disk-cleanup.sh` quando o disco estiver cheio.

Este documento explica por que o espaço em disco diminui com o uso normal, quais comandos liberam espaço e quais são os riscos de cada um.

---

## 1. Por que o espaço some

Mesmo sem instalar nada novo, alguns lugares crescem com o tempo:

| Local | Motivo |
|---|---|
| `/var/lib/docker` e `/var/lib/containerd` | Imagens, camadas de containers e cache de build. Cada `docker build` e cada imagem nova acumula. |
| `/var/lib/flatpak` | Runtimes e extensões dos apps Flatpak. Versões antigas ficam guardadas. |
| `~/.var/app` | Dados dos apps Flatpak, incluindo caches e perfis de navegador. |
| `~/.cache` | Caches de ferramentas: `yay` (AUR), `go-build`, `pnpm`, entre outros. |
| Snapshots btrfs | Snapshots periódicos (Snapper) preservam blocos de arquivos já apagados. Por isso apagar arquivos não devolve o espaço enquanto o snapshot existir. |
| Journal (`/var/log/journal`) | Logs do systemd, que crescem com o tempo. |

### Por que o `du` não mostra tudo

`du -x` não atravessa subvolumes do btrfs, e snapshots são subvolumes. O espaço que eles ocupam não entra na soma das pastas. Por isso o `du` pode mostrar bem menos espaço usado do que o `df`. Para ver o uso real do btrfs, use `btrfs filesystem usage`.

---

## 2. Comandos de diagnóstico

### `df -h /`
Espaço total, usado e livre do filesystem. Use como referência antes e depois de qualquer limpeza.

### `sudo du -xh / --max-depth=2 | sort -h | tail -25`
Mostra as maiores pastas. `-x` não atravessa outros filesystems. Não inclui o espaço dos snapshots.

### `sudo du -xh /var/lib --max-depth=1 | sort -h | tail`
Mesmo princípio, focado em `/var/lib`, onde costumam estar os maiores consumidores.

### `sudo find / -xdev -type f -size +200M -mtime -7 2>/dev/null`
Procura arquivos maiores que 200 MB modificados nos últimos 7 dias.
- `-xdev`: não atravessa outros filesystems.
- `-type f`: só arquivos.
- `-size +200M`: maiores que 200 MB.
- `-mtime -7`: modificados nos últimos 7 dias.

### `sudo btrfs filesystem usage /`
Uso real do btrfs:
- **Data**: espaço de dados alocado e usado.
- **Metadata**: espaço de metadados.
- **Unallocated**: espaço ainda não alocado para o btrfs. Se estiver perto de zero, o disco está praticamente cheio.

### `sudo btrfs subvolume list -s /`
Lista os snapshots do btrfs (`-s` mostra só os snapshots).

### `sudo snapper list-configs` e `sudo snapper -c <config> list`
- `list-configs`: mostra as configurações do Snapper (geralmente `root` e `home`).
- `-c <config> list`: lista os snapshots de uma config.
- Atenção: `sudo snapper list` sem `-c` dá erro (`Command 'list' does not take arguments`).

### `docker system df`
Espaço de imagens, containers, volumes e cache de build, com o valor recuperável de cada um.

### `journalctl --disk-usage`
Quanto os logs do journal ocupam.

### `flatpak list --app --columns=application,size | sort -k2 -h`
Apps Flatpak com o tamanho de cada um. Para runtimes, use `--runtime` no lugar de `--app`.

---

## 3. Limpezas

Para cada item: o comando, o que faz e o risco.

### 3.1 Journal do systemd

```bash
sudo journalctl --vacuum-size=200M
```

- **O que faz:** apaga logs arquivados até o journal ficar com no máximo o tamanho informado.
- **Risco:** baixo. Você perde logs antigos, úteis para investigar problemas passados.

### 3.2 Containers Docker parados

```bash
docker container prune
```

- **O que faz:** remove containers parados. Containers ativos não são afetados.
- **Risco:** dados gravados só dentro do container (fora de volumes) são perdidos.

### 3.3 Cache de build e imagens "dangling"

```bash
docker builder prune
docker image prune
```

- **O que fazem:** removem o cache de build sem referência e as imagens sem tag e sem uso.
- **Risco:** nenhum relevante.

### 3.4 Todo o cache de build

```bash
docker builder prune -a
```

- **O que faz:** remove todo o cache de build, não só o sem referência. Pode liberar bastante espaço em máquinas que fazem muitos builds.
- **Risco:** o próximo build demora mais, porque precisa refazer as camadas.

### 3.5 Imagens sem container associado

```bash
docker image prune -a
```

- **O que faz:** remove todas as imagens que não estão associadas a nenhum container, ativo ou parado.
- **Risco:** imagens baixadas de um registry são baixadas de novo quando precisar. **Atenção:** imagens construídas localmente (`docker build`) não estão em nenhum registry. Sem o Dockerfile e o contexto, elas não podem ser reconstruídas da mesma forma. Antes de rodar, confira com `docker images` quais imagens locais você ainda precisa.

### 3.6 Cache de pacotes e builds do AUR

```bash
yay -Sc
```

- **O que faz:** remove pacotes antigos do cache do pacman (`/var/cache/pacman/pkg`), repositórios de sincronização não usados e builds antigos do AUR em `~/.cache/yay`.
- **Risco:** se precisar fazer downgrade de um pacote, ele será baixado de novo.

Alternativa para manter só as versões mais recentes do pacman, sem mexer no AUR:

```bash
sudo pacman -S pacman-contrib
sudo paccache -rk2     # mantém só as 2 últimas versões de cada pacote
```

### 3.7 Cache de compilação Go

```bash
go clean -cache
```

- **O que faz:** apaga o cache de compilação do Go (`~/.cache/go-build`).
- **Risco:** a próxima compilação é mais lenta.

### 3.8 Store do pnpm

```bash
pnpm store prune
```

- **O que faz:** remove pacotes do store global do pnpm que nenhum projeto usa mais.
- **Risco:** projetos que usam esses pacotes baixam de novo na próxima instalação.

### 3.9 Runtimes Flatpak não usados

```bash
flatpak uninstall --unused
```

- **O que faz:** remove runtimes e extensões que nenhum app usa.
- **Risco:** nenhum, porque só remove o que não está em uso.

### 3.10 Runtimes Flatpak antigos

```bash
flatpak list --runtime --columns=application,version,size
flatpak uninstall <application>/<arch>/<branch>
```

- **O que faz:** remove uma versão específica de runtime. Use quando houver mais de uma versão do mesmo runtime.
- **Risco:** se algum app ainda depender dessa versão, o Flatpak avisa e lista os apps afetados. Responda `n` nesse caso.

### 3.11 SDK de desenvolvimento do Flatpak

```bash
flatpak uninstall org.freedesktop.Sdk
```

- **O que faz:** remove o SDK, que é grande e normalmente só é necessário para desenvolver.
- **Risco:** se algum app instalado depender dele (por exemplo, um editor que compila extensões), o Flatpak recusa. Nesse caso, mantenha.

### 3.12 Caches dos apps Flatpak

- Procure a opção de limpar cache dentro do próprio app (em geral em Configurações → Armazenamento ou similar).
- Se precisar apagar manualmente, apague **só a pasta de cache** dentro de `~/.var/app/<app-id>/`.
- **Não apague o perfil inteiro** de navegadores ou apps (histórico, logins, configurações ficam ali).

### 3.13 Retenção de snapshots do Snapper

O Snapper cria snapshots por tempo (horário, diário, mensal, anual), e cada tipo tem um limite de quantos manter. Para ver os valores atuais:

```bash
grep TIMELINE_LIMIT /etc/snapper/configs/root
```

Para reduzir os limites, edite o arquivo da config (por exemplo, com `sudo nano /etc/snapper/configs/root`) e escolha valores que façam sentido para você. Exemplo de `sed` que muda vários valores de uma vez:

```bash
sudo sed -i \
  's/^TIMELINE_LIMIT_HOURLY=.*/TIMELINE_LIMIT_HOURLY="5"/; s/^TIMELINE_LIMIT_DAILY=.*/TIMELINE_LIMIT_DAILY="7"/; s/^TIMELINE_LIMIT_MONTHLY=.*/TIMELINE_LIMIT_MONTHLY="2"/; s/^TIMELINE_LIMIT_YEARLY=.*/TIMELINE_LIMIT_YEARLY="0"/' \
  /etc/snapper/configs/root /etc/snapper/configs/home
```

Explicação:
- `sudo`: necessário para editar `/etc`.
- `sed -i`: edita o arquivo no lugar.
- `s/padrão/substituição/`: troca o texto que casa com o padrão.
- `^`: âncora de início de linha, para não trocar outras ocorrências.
- `.*`: qualquer texto até o fim da linha.

Depois, aplique a nova retenção. Isso **apaga** os snapshots que passam do limite:

```bash
sudo snapper -c root cleanup timeline
sudo snapper -c home cleanup timeline
```

- **Risco:** snapshots apagados não podem ser recuperados. Você só pode voltar no tempo para os que sobraram.
- **Para reverter os limites:** rode o `sed` de novo com os valores anteriores. Isso não restaura snapshots já apagados.

### 3.14 Journal com limite menor

Se o journal estiver ocupando muito espaço, vale manter um limite fixo. Em `/etc/systemd/journald.conf`, defina `SystemMaxUse=200M` e reinicie o `systemd-journald`. Mesmo assim, o `--vacuum-size` continua útil para limpar agora.

---

## 4. Script de rotina

O `scripts/disk-cleanup.sh` roda as limpezas acima, com dois grupos de passos:

**Automáticos** (não apagam dados úteis):
1. Journal do systemd, limitado a `JOURNAL_MAX` (padrão `200M`).
2. Flatpak: runtimes não usados.
3. Docker: cache de build sem referência e imagens sem tag.
4. AUR e cache do pacman (`yay -Sc`).
5. Cache do Go e store do pnpm.

**Com confirmação** (a resposta padrão é "não"):
1. Docker: containers parados.
2. Docker: imagens sem container (`image prune -a`).
3. Docker: todo o cache de build (`builder prune -a`).
4. Snapper: `cleanup timeline` para `root` e `home`.

Uso:

```bash
cd <caminho-do-repo>
./scripts/disk-cleanup.sh

# Limite do journal diferente:
JOURNAL_MAX=100M ./scripts/disk-cleanup.sh
```

- Não rode como root. O `yay` recusa, e o script usa `sudo` só quando precisa.
- O script pede a senha do `sudo` uma vez, no início.
- Quando não há terminal interativo (por exemplo, rodando em um cron), as perguntas são puladas e nada é apagado nesses passos.
- Ao final, mostra o `df -h /` antes e depois e o espaço liberado.

### Quando agir

- Abaixo de **15% de espaço livre**, rode o script.
- Acima de **85% de uso**, o btrfs pode ficar lento e ter problemas de escrita. Priorize limpar imagens Docker e snapshots.

---

## 5. Riscos e cuidados

| Ação | Consequência | Como reverter |
|---|---|---|
| `snapper ... cleanup timeline` | Snapshots apagados são irreversíveis. | Não é possível. |
| `docker image prune -a` | Imagens locais sem registry não podem ser baixadas de novo. | Reconstruir a partir dos Dockerfiles. |
| `docker builder prune -a` | Próximos builds são mais lentos. | Não precisa reverter. |
| `docker container prune` | Dados fora de volumes em containers parados são perdidos. | Não é possível. |
| `yay -Sc` / `paccache` | Downgrades exigem novo download. | Baixar a versão de novo. |
| `journalctl --vacuum-size` | Logs antigos somem. | Não é possível. |
| `flatpak uninstall` de runtime | Apps que dependem dele deixam de funcionar. | Reinstalar o runtime. |

---

## 6. Observação sobre btrfs

Apagar snapshots ou subvolumes não libera espaço na hora. O btrfs recupera os blocos de forma assíncrona, o que pode levar alguns minutos. Se o `df` não mudar logo depois da limpeza, espere e rode `df -h /` de novo.
