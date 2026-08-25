O `iwctl` é a interface de linha de comando do `iwd` (iNet wireless daemon). Você vai precisar dele caso tenha um wifi na sua máquina e queira ja configurar o wifi durante a instalação. Com internet cabeada você tem a facilidade de so pular essa etapa.

1. **Iniciar o utilitário interativo:**
Abra a interface do `iwctl`:

```bash
iwctl
```

Você entrará em um prompt interativo iniciado por `[iwd]#`.

2. **Identificar a sua interface Wi-Fi:**
Listar todas as placas de rede sem fio detectadas no sistema:

```bash
device list
```
Anote o nome da sua interface (geralmente algo como `wlan0` ou `wlp2s0`).

3. **Escanear e listar as redes disponíveis:**
Ative a busca por redes Wi-Fi e em seguida exiba o resultado (substitua `wlan0` pelo nome da sua interface):

```bash
station wlan0 scan
station wlan0 get-networks
```

4. **Conectar à sua rede:**
Conecte-se à rede desejada digitando o SSID (nome do Wi-Fi):

```bash
station wlan0 connect "NOME_DA_SUA_REDE"
```

O utilitário pedirá a senha. Digite-a e pressione **Enter**.

5. **Sair do iwctl e testar a conexão:**
Saia do prompt interativo do `iwctl`:

```bash
exit
```

Em seguida, verifique se o seu computador recebeu um endereço IP e se consegue navegar na internet:

```bash
ping -c 3 archlinux.org
```

---

> **Nota de resolução de problemas:** Se o comando `ping` falhar por erro de resolução de nome mesmo após conectar, certifique-se de que o cliente DHCP do live ISO atribuiu um IP executando `systemctl restart systemd-networkd`.