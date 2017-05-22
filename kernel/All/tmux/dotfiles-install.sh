#!/usr/bin/env bash

[ -r ~/.dotfiles/bin/dotfiles ] && source  ~/.dotfiles/bin/dotfiles || exit 5

dotfiles_info "tmux plugin manager: install/update"


if [ ! -d ~/.tmux/plugins/tpm ];
then
  mkdir -p ~/.tmux/plugins
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
else
  pushd ~/.tmux/plugins/tpm &>/dev/null
  git pull
  popd &>/dev/null
fi
