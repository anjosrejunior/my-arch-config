# Aonde localizar

Primeiramente o arquivo `pacman.conf` fica localizado no filesystem abaixo do seu usuário, no exato caminho `etc/pacman.conf`.

Utilize este comando para acessar:

```bash
micro ../../etc/pacman.conf
```

# Config

Existem três configurações que eu faço no meu pacman.conf:

1. **Color**: Caso ele venha comentado descomente e caso você não encontre escreva `Color`
2. **IloveCandy**: Caso ele venha comentado descomente e caso você não encontre escreva `IloveCandy`
3. **ParallelDownloads**: Ele sempre vem escrito por padrão 5 mantenha por que esse é o Sspot.

Exemplo:

```conf
Color
ILoveCandy
ParallelDownloads=5
```

# Exemplo de `pacman.conf`

É sempre na área `options` que você encontra o `Color`, `IloveCandy` e o `ParallelDownloads`

```bash
[options]
# The following paths are commented out with their default values listed.
# If you wish to use different paths, uncomment and update the paths.
#RootDir     = /
#DBPath      = /var/lib/pacman/
#CacheDir    = /var/cache/pacman/pkg/
#LogFile     = /var/log/pacman.log
#GPGDir      = /etc/pacman.d/gnupg/
#HookDir     = /etc/pacman.d/hooks/
HoldPkg     = pacman glibc
#XferCommand = /usr/bin/curl -L -C - -f -o %o %u
#XferCommand = /usr/bin/wget --passive-ftp -c -O %o %u
#CleanMethod = KeepInstalled
Architecture = auto

# Pacman won't upgrade packages listed in IgnorePkg and members of IgnoreGroup
#IgnorePkg   =
#IgnoreGroup =

#NoUpgrade   =
#NoExtract   =

# Misc options
#UseSyslog
Color
ILoveCandy
#NoProgressBar
CheckSpace
#VerbosePkgLists
ParallelDownloads = 5
DownloadUser = alpm
#DisableSandboxFilesystem
#DisableSandboxSyscalls
```