#!/bin/bash
# Gera a ISO instaladora do Woddoles (Debian 13 + live-build).
# Rode num Debian/Ubuntu (ou máquina virtual), como root:   sudo bash build-iso.sh
# Resultado: woddoles.iso (grave no pendrive com Rufus em "modo DD" ou balenaEtcher).
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
[ "$(id -u)" = 0 ] || { echo "Rode como root: sudo bash build-iso.sh"; exit 1; }
command -v lb >/dev/null || { echo "Instale antes: apt install live-build debootstrap xorriso squashfs-tools"; exit 1; }

WORK="${WORK:-/var/tmp/woddoles-build}"
rm -rf "$WORK"
mkdir -p "$WORK"
cd "$WORK"

lb config \
  --distribution trixie \
  --architectures amd64 \
  --binary-images iso-hybrid \
  --archive-areas "main contrib non-free non-free-firmware" \
  --apt-recommends false \
  --debian-installer live \
  --debian-installer-gui true \
  --bootappend-live "boot=live components quiet locales=pt_BR.UTF-8 keyboard-layouts=br" \
  --iso-application "Woddoles" \
  --iso-volume "WODDOLES" \
  --memtest none

# Pacotes: tira comentários/linhas vazias da lista e acrescenta o que o instalador precisa
{ grep -vE '^\s*(#|$)' "$HERE/packages.list"; echo "locales"; } > config/package-lists/woddoles.list.chroot

# Arquivos do sistema (scripts, menus, ajustes de RAM, política do navegador...)
mkdir -p config/includes.chroot_after_packages
cp -a "$HERE/overlay/." config/includes.chroot_after_packages/

# Hook de build e respostas pré-definidas do instalador
mkdir -p config/hooks/live config/includes.installer
install -m 755 "$HERE/iso/0100-woddoles.hook.chroot" config/hooks/live/0100-woddoles.hook.chroot
install -m 644 "$HERE/iso/preseed.cfg" config/includes.installer/preseed.cfg

lb build

ISO="$(ls -1 ./*.iso | head -n1)"
cp "$ISO" "$HERE/woddoles.iso"
echo
echo "Pronto: $HERE/woddoles.iso"
