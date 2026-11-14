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

### Conectando ao Wi-Fi com `nmtui` (interface em texto)

Existe também a forma de conexão e gestão via terminal usando o TUI (interface de texto com menus) `nmtui`. Ele usa o mesmo NetworkManager do `nmcli`, mas com navegação por menus, sem precisar decorar comandos.

> **Pré-requisito:** o serviço do NetworkManager precisa estar ativo. Caso não esteja:
>
> ```bash
> sudo systemctl enable --now NetworkManager
> ```

1. **Abrir o nmtui:**

```bash
nmtui
```

2. **Navegar pelos menus:**
- Use as **setas** para mover o cursor.
- Use **Tab** ou **Shift+Tab** para alternar entre botões e campos.
- Use **Enter** para selecionar.
- Use **Esc** para voltar ao menu anterior ou sair.

3. **Conectar a uma rede Wi-Fi:**
Na tela inicial, selecione **Activate a connection**. Na lista, escolha a rede desejada e pressione **Enter**. Quando o campo de senha (*Passphrase*) aparecer, digite a senha (ela não é exibida na tela) e selecione **Activate**.

Uma conexão ativa aparece marcada com `*` na lista.

4. **Testar a conexão:**
Volte ao menu principal com **Esc**, saia do `nmtui` e teste:

```bash
ping -c 3 archlinux.org
```

> **Dica:** para trocar de rede, basta repetir o passo 3 com outra rede disponível. Para editar ou remover uma rede salva, use **Edit a connection** no menu inicial.

Se precisar ajustar mais algum comando para o seu guia do Arch, só avisar!