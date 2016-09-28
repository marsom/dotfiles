#!/usr/bin/env bash

[ -r ~/.dotfiles/bin/dotfiles ] && source  ~/.dotfiles/bin/dotfiles || exit 5

dotfiles_link_file $(dirname $0)/netstatcmd.sh ~/bin/netstatcmd
