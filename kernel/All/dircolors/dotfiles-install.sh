#!/usr/bin/env bash

[ -r ~/.dotfiles/bin/dotfiles ] && source  ~/.dotfiles/bin/dotfiles || exit 5

info "dircolors-solarized: install/update"

if [ ! -d ~/.dircolors-solarized ];
then
  git clone https://github.com/seebi/dircolors-solarized ~/.dircolors-solarized
else
  pushd ~/.dircolors-solarized &>/dev/null
  git pull
  popd &>/dev/null
fi

