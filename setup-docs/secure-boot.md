# Secure Boot no Arch Linux
> **Configuração:** Dual Boot (Arch Linux + Windows) | GRUB | sbctl | Kernels (Normal + LTS) | Placas ASUS / UEFI | Btrfs | Hyprland

## 📌 Visão Geral
Este guia utiliza a ferramenta **`sbctl`** (disponível no repositório oficial do Arch) para assinar o GRUB e o Kernel Linux sem depender do AUR. Ele mantém as chaves oficiais da Microsoft registradas para garantir a inicialização perfeita do **Windows 10/11** e seus anti-cheats (como Riot Vanguard / Valorant).

## ⚙️ Etapa 1: Colocar a BIOS no "Setup Mode" (Placa-mãe ASUS)

Para que o `sbctl` consiga gravar as chaves na memória da placa-mãe, ela precisa estar destravada:

1. Reinicie o computador e aperte **`Delete`** ou **`F2`** para entrar na BIOS.
2. Pressione **`F7`** para abrir o **Advanced Mode**.
3. Vá para a aba **Boot** -> **Secure Boot**.
4. Acesse **Key Management** (Gerenciamento de Chaves) e selecione **Clear Secure Boot Keys** (ou *Delete All Keys*).
5. Aperte **`F10`** para salvar e reiniciar no Arch Linux.

> **Verificação:** Ao iniciar o Arch, o comando `sbctl status` deve exibir `Setup Mode: ✓ Enabled`.

## ⚠️ Etapa 2: Reinstalação Obrigatória do GRUB (--disable-shim-lock)

> **CRÍTICO:** O GRUB tenta usar o protocolo *Shim* por padrão se detectar o Secure Boot ativo. Como usamos o `sbctl`, a falta desse parâmetro gera o erro `prohibited by secure boot policy (grub rescue)`.

Execute no terminal do Arch Linux:

```bash
# 1. Reinstalar o GRUB desativando a trava do Shim
sudo grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=BOOT --modules="tpm" --disable-shim-lock

# 2. Atualizar o arquivo de configuração do GRUB (snapshots do Btrfs e Dual Boot mantidos)
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

## 🔑 Etapa 3: Instalar o sbctl, Criar e Assinar os Arquivos

Instale a ferramenta do repositório oficial e assine todos os binários do GRUB e dos Kernels (Normal + LTS):

```bash
# 1. Instalar o sbctl via pacman
sudo pacman -S sbctl

# 2. Gerar as chaves de assinatura do sistema
sudo sbctl create-keys

# 3. Assinar os executáveis do GRUB e Kernels no /boot
sudo sbctl sign -s /boot/EFI/BOOT/BOOTX64.EFI
sudo sbctl sign -s /boot/EFI/BOOT/grubx64.efi
sudo sbctl sign -s /boot/grub/x86_64-efi/core.efi
sudo sbctl sign -s /boot/grub/x86_64-efi/grub.efi
sudo sbctl sign -s /boot/EFI/Linux/arch-linux.efi
sudo sbctl sign -s /boot/EFI/Linux/arch-linux-lts.efi
sudo sbctl sign -s /boot/vmlinuz-linux
sudo sbctl sign -s /boot/vmlinuz-linux-lts

# 4. Confirmar que TODOS os arquivos foram assinados
sudo sbctl verify
```

*(Certifique-se de que a saída do `sbctl verify` exibe `✓ is signed` em todas as linhas).*

## 💾 Etapa 4: Gravar as Chaves na BIOS (Com suporte ao Windows)

Envie a sua chave do Arch Linux + as chaves oficiais da Microsoft (`-m`) para a memória NVRAM da placa-mãe:

```bash
sudo sbctl enroll-keys -m
```

## 🔒 Etapa 5: Ativar o Secure Boot na BIOS

1. Reinicie e entre na BIOS (**`Delete`** / **`F2`**).
2. Vá em **Advanced Mode (F7)** -> **Boot** -> **Secure Boot**.
3. Mude a opção **Secure Boot** para **`Enabled`**.
4. Pressione **`F10`** para salvar e reiniciar.

## ✅ Etapa 6: Verificação do Status Final

Após iniciar o Arch Linux, confirme no terminal:

```bash
sbctl status
```

**Resultado esperado:**

* `Installed: ✓ sbctl is installed`
* `Setup Mode: ✗ Disabled`
* `Secure Boot: ✓ Enabled`

### 💡 Nota sobre Atualizações Futuras

O `sbctl` configura um *pacman hook* nativo. Quando você atualizar o Kernel (`linux` ou `linux-lts`) ou o `grub` futuramente via `pacman -Syu`, os novos arquivos serão **assinados automaticamente** sem necessidade de intervenção manual.