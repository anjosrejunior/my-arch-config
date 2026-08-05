# Passo 1: Instalar as ferramentas

Abra o terminal no Arch e instale o os-prober (que detecta 
outros sistemas) e o ntfs-3g (que permite o Linux ler partições 
do Windows):

```Bash
sudo pacman -S os-prober ntfs-3g
```

# Passo 2: Ativar o detector no arquivo do GRUB

Abra o arquivo de configuração geral do GRUB com privilégios de 
administrador:

```Bash
sudo nano /etc/default/grub
```

Vá até o final do arquivo e adicione a linha:

```Plaintext
GRUB_DISABLE_OS_PROBER=false
```

Salve o arquivo pressionando Ctrl + O, depois Enter, e saia com 
Ctrl + X.

# Passo 3: Atualizar o GRUB

Agora, execute o comando para o GRUB refazer o menu de boot. 
Como você está com a partição de 1 GB montada em /boot e a de 
200 MB em /boot/efi, o sistema já sabe exatamente onde salvar 
tudo automaticamente:

```Bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

Fique atento à saída desse comando no terminal. Você verá 
algumas linhas passando e, entre elas, uma mensagem parecida com:

```Plaintext
Found Windows Boot Manager on /dev/nvme0n1p1@/EFI/Microsoft/Boot/
bootmgfw.efi
```
