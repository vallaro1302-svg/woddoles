#!/bin/bash
# Plano B: transforma um Debian 13 recém-instalado em Woddoles (sem usar a ISO).
# Rode como root, SOMENTE no notebook do Woddoles:   sudo bash install-woddoles.sh
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
[ "$(id -u)" = 0 ] || { echo "Rode como root: sudo bash install-woddoles.sh"; exit 1; }
. /etc/os-release

cat <<'EOF'
==============================  WODDOLES  ==============================
Este script MUDA o sistema desta máquina: instala pacotes, cria o usuário
"woddoles", ativa login automático e troca a interface por um desktop mínimo.
Use apenas numa instalação limpa de Debian 13 no notebook dedicado.
=========================================================================
EOF
read -r -p "Digite SIM para continuar: " ok
[ "$ok" = "SIM" ] || { echo "Cancelado. Nada foi alterado."; exit 1; }

if [ "${VERSION_CODENAME:-}" != "trixie" ]; then
  echo "Aviso: este script foi feito para Debian 13 (trixie); você está em ${PRETTY_NAME:-desconhecido}."
  read -r -p "Continuar mesmo assim? (SIM/n): " ok2
  [ "$ok2" = "SIM" ] || exit 1
fi

echo "==> Habilitando firmware não-livre (Wi-Fi etc.)"
if ! grep -rqs "non-free-firmware" /etc/apt/sources.list /etc/apt/sources.list.d/; then
  if [ -f /etc/apt/sources.list.d/debian.sources ]; then
    sed -i 's/^Components: main.*$/Components: main non-free-firmware/' /etc/apt/sources.list.d/debian.sources
  fi
  if [ -f /etc/apt/sources.list ]; then
    sed -i -E '/^deb / s/ main( |$)/ main non-free-firmware\1/' /etc/apt/sources.list
  fi
fi

echo "==> Instalando pacotes"
apt-get update
mapfile -t PKGS < <(grep -vE '^\s*(#|$)' "$HERE/packages.list" | grep -v '^firmware-')
mapfile -t FW   < <(grep -E '^firmware-' "$HERE/packages.list" || true)
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "${PKGS[@]}"
for p in "${FW[@]}"; do
  DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends "$p" || echo "Pulando $p (não disponível)"
done

echo "==> Copiando arquivos do Woddoles"
cp -a "$HERE/overlay/." /
chmod 755 /usr/local/bin/woddoles-*
chmod 440 /etc/sudoers.d/woddoles
chmod 644 /etc/systemd/system/woddoles-setup-games.service

echo "==> Usuário woddoles"
if ! id woddoles >/dev/null 2>&1; then
  useradd -m -s /bin/bash woddoles
  passwd woddoles
fi
for g in audio video plugdev netdev input render sudo; do
  getent group "$g" >/dev/null && usermod -aG "$g" woddoles || true
done
install -o woddoles -g woddoles -m 644 /etc/skel/.xinitrc /home/woddoles/.xinitrc
install -o woddoles -g woddoles -m 644 /etc/skel/.bash_profile /home/woddoles/.bash_profile
install -D -m 644 /usr/share/woddoles/autologin.conf /etc/systemd/system/getty@tty1.service.d/woddoles-autologin.conf

echo "==> Serviços e ajustes de memória"
sysctl --system >/dev/null || true
systemctl enable NetworkManager zramswap earlyoom thermald woddoles-setup-games.service || true
systemctl disable --now ModemManager.service bluetooth.service cups.service avahi-daemon.service 2>/dev/null || true
if [ -f /etc/default/grub ]; then
  sed -i 's/^GRUB_TIMEOUT=.*/GRUB_TIMEOUT=2/' /etc/default/grub
  update-grub || true
fi

echo "==> Sober (Roblox) e TLauncher (precisa de internet)"
/usr/local/bin/woddoles-setup-games || echo "Não deu agora; será tentado de novo no próximo boot com internet."

echo
echo "Pronto! Reinicie com:  reboot"
