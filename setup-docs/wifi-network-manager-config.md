Aqui está um trecho pronto no formato **Markdown**, limpo e direto ao ponto, para você copiar e colar na sua documentação:

### Conectando ao Wi-Fi via Terminal (`nmcli`)

O utilitário `nmcli` (NetworkManager) permite listar e conectar a redes sem fio diretamente pela linha de comando.

#### 1. Listar redes disponíveis
```bash
nmcli device wifi list
```

#### 2. Conectar à rede (Modo Interativo com `--ask`)

Utilize a flag `--ask` para evitar falhas ao processar senhas com caracteres especiais (`@`, `$`, `!`) e impedir que a senha fique registrada no histórico do terminal:

```bash
nmcli --ask device wifi connect 'NOME_DA_REDE'
```

> **Nota:** O terminal solicitará a senha de forma oculta. Digite-a e pressione `Enter`.

#### 3. Testar a conexão

```bash
ping -c 3 archlinux.org
```

Se precisar ajustar mais algum comando para o seu guia do Arch, só avisar!