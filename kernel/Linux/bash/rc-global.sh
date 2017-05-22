# https://github.com/Linuxbrew/legacy-linuxbrew/issues/46
if [ -f /usr/share/pkgconfig/bash-completion.pc ]; then
  export PKG_CONFIG_PATH=/usr/share/pkgconfig:$PKG_CONFIG_PATH
fi
