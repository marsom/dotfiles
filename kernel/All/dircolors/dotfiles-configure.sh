#!/usr/bin/env bash

[ -r ~/.dotfiles/bin/dotfiles ] && source  ~/.dotfiles/bin/dotfiles || exit 5

dotfiles_link_file ~/.dircolors-solarized/dircolors.ansi-dark ~/.dircolors 
