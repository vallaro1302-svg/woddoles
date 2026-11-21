# Woddoles

Sistema operacional leve, feito para **Minecraft (TLauncher)** e **Roblox**, pensado para
um notebook antigo (i7-3517U, Intel HD 4000, 4 GB de RAM). Base: Debian 13, desktop mínimo
(Openbox), RAM compactada (zram), navegador Firefox ESR com uBlock Origin e sem restrições.

> Importante: eu não consegui gerar nem testar a ISO aqui. Os arquivos foram escritos com
> base na documentação do Debian/live-build, mas a primeira geração pode precisar de ajustes.
> Teste sempre numa máquina virtual antes de instalar no notebook.

## Como instalar (igual ao Windows: pelo pendrive)

### 1. Gerar a ISO

**Opção A, sem Linux (recomendada para quem usa Windows):**
1. Crie uma conta gratuita no GitHub e um repositório privado.
2. Envie o conteúdo desta pasta para ele (inclusive a pasta oculta `.github`).
3. Aba **Actions** > **Build Woddoles ISO** > **Run workflow**.
4. Quando terminar, baixe `woddoles-iso` em **Artifacts** e extraia o `woddoles.iso`.

**Opção B, com Debian/Ubuntu (ou VM):**
```
sudo apt install live-build debootstrap xorriso squashfs-tools
sudo bash build-iso.sh
```
Isso cria `woddoles.iso` nesta pasta.

### 2. Testar (opcional, mas recomendado)
Abra a ISO no VirtualBox com 4 GB de RAM e um disco virtual de 30 GB.

### 3. Gravar no pendrive (4 GB ou mais)
Use **Rufus** (escolha "Modo imagem DD" quando perguntar) ou **balenaEtcher**.
Atenção: o pendrive será apagado.

### 4. Instalar no notebook
1. Faça backup do que importa: a instalação apaga o disco escolhido.
2. Ligue com o pendrive e abra o menu de boot (F12, F10, Esc ou F2, depende da marca).
3. Escolha **Graphical Install** (instalador gráfico).
4. O idioma, o teclado ABNT2 e o fuso de São Paulo já vêm configurados. Você escolhe só o disco,
   a senha do usuário `woddoles` e a rede.
5. Reinicie sem o pendrive. O Woddoles entra direto na tela inicial.
6. No primeiro boot com internet, ele instala sozinho o Sober (Roblox) e baixa o TLauncher.
   Pode levar alguns minutos.

## Plano B: sem ISO
Instale um Debian 13 normal (só "utilitários padrão do sistema", sem desktop), copie esta
pasta para o notebook e rode `sudo bash install-woddoles.sh`. O script pede que você digite SIM
antes de mudar qualquer coisa. Rode somente no notebook do Woddoles.

## Limites que você precisa saber

- **Roblox é o ponto de maior risco.** Só roda no Linux pelo Sober, que executa o app Android do
  Roblox. O Wine foi bloqueado pelo anti-cheat do Roblox. Relatos mostram que o Sober em GPUs Intel
  antigas (Ivy Bridge, como o HD 4000) pode falhar ou rodar com poucos FPS. O Woddoles já força o
  modo OpenGL, o mais indicado para essa geração. Se o Roblox não abrir, não é erro do instalador.
  Se isso acontecer, me avise com a mensagem que aparecer.
- **Minecraft:** o TLauncher baixa as versões do jogo. Nesse hardware, prefira versões antigas
  (1.8.9 a 1.12.2) ou 1.16+ com Fabric + Sodium. Em Configurações do TLauncher, limite a RAM do
  jogo a cerca de 1536 MB. O TLauncher é fechado e tem anúncios. O Prism Launcher é uma alternativa
  livre, se um dia quiser trocar.
- **Navegador:** Firefox ESR com uBlock Origin, sem bloqueio de sites. Se quiser um navegador 100%
  "livre" no sentido de software, me avise que adapto.
- 4 GB de RAM é pouco para Roblox: não deixe o navegador aberto com várias abas durante o jogo.

## O que tem na pasta

| Arquivo | Função |
|---|---|
| `build-iso.sh` | Gera a ISO instaladora |
| `.github/workflows/build-iso.yml` | Gera a ISO na nuvem do GitHub |
| `iso/preseed.cfg` | Respostas automáticas do instalador (idioma, teclado, usuário) |
| `install-woddoles.sh` | Plano B, instala sobre um Debian existente |
| `packages.list` | Lista de pacotes do sistema |
| `overlay/` | Arquivos copiados para o sistema (menus, scripts, ajustes de RAM, navegador) |
