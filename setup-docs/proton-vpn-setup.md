# Proton VPN via WireGuard no Arch Linux**

**1. Instalar dependências necessárias**

```bash
sudo pacman -S wireguard-tools openresolv
```

**3. Baixar o perfil `.conf**`

1. Acesse `account.protonvpn.com` > **Downloads** > **WireGuard configuration**.
2. Baixe o arquivo do servidor desejado (ex: Brasil).

**2. Mover e configurar o arquivo**

```bash
sudo cp ~/Downloads/*.conf /etc/wireguard/proton.conf
sudo chmod 600 /etc/wireguard/proton.conf
```

**3. Corrigir permissão de DNS (Se necessário)**

```bash
sudo resolvconf -u
```

*(Se o erro persistir: `sudo rm -f /etc/resolv.conf && sudo touch /etc/resolv.conf`)*

**Comandos do Dia a Dia:**

**Ligar VPN:** 
```bash
sudo wg-quick up proton
```

**Desligar VPN:** 
```bash
sudo wg-quick down proton
```

**Ver Status:** 
```bash
sudo wg
```

**Checar IP:** 
```bash
curl ifconfig.me
```

# Proton VPN via WireGuard com NetworkManager no Arch Linux**

**1. Instalar o NetworkManager e ferramentas do WireGuard**

```bash
sudo pacman -S networkmanager wireguard-tools
```

**2. Ativar e iniciar o serviço do NetworkManager**

```bash
sudo systemctl enable --now NetworkManager
```

**3. Baixar o perfil `.conf`**

1. Acesse `account.protonvpn.com` > **Downloads** > **WireGuard configuration**.
2. Baixe o arquivo do servidor desejado (ex: Brasil).

**4. Importar o arquivo `.conf` para o NetworkManager**

```bash
cd ~/Downloads
sudo nmcli connection import type wireguard file *.conf
```

**Comandos do Dia a Dia:**

**Ver conexões salvas:**
```bash
nmcli connection show
```

**Ligar VPN:**

```bash
nmcli connection up NOME_DA_CONEXAO
```

**Desligar VPN:**

```bash
nmcli connection down NOME_DA_CONEXAO
```

**Checar IP:**

```bash
curl ifconfig.me
```