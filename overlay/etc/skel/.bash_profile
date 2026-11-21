# Inicia o X automaticamente no primeiro terminal (autologin no tty1).
if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then
  exec startx -- -nolisten tcp
fi
