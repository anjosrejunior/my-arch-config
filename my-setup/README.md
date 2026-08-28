Com uma máquina recém instalada com o arch linux e as configurações contidas no my-arch (Tanto faz qualquer uma das línguas), e você ja sabendo o que fazer nas configurações do pacman (Eu recomendo ter duas máquinas uma que você esta configurando e outra para consultar caso precise, se não puder saiba ao menos baixar o micro ou nano para ler os arquivos enquanto configura):

1. Faça as mudanças no `pacman.conf` de acordo com `setup-docs/pacman-config.md`, essa parte vai ajudar a os downloads a terminarem mais rápido.
2. Instale o Git
2. Faça o clone do repositório na máquina
3. De permissão de executável usando o `chmod +x my-arch-config/my-setup/install.sh`
4. Execute o script `./my-arch-config/my-setup/install.sh`
5. Escreva seu nome e seu email do git-hub

E Voilà está pronto o script vai configurar a máquina sozinho, e dar reboot, após isso você pode utilizar, trazer seu backup do navegador, seus baralhos do anki ou sei lá o que que tu vai fazer. Pode utilizar os post install scripts para completar a configuração do sistema.

O `install.sh` é apenas um orquestrador: ele ativa, em ordem, os scripts temáticos localizados na pasta `scripts/` (um por área: sistema base, shell, rede, git, flatpak, display, desktop, mídia, arquivos, desenvolvimento e aplicativos).