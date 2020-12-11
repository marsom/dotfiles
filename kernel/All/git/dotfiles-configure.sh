#!/usr/bin/env bash

[ -r ~/.dotfiles/bin/dotfiles ] && source  ~/.dotfiles/bin/dotfiles || exit 5

dotfiles_link_module_file git/gitmessage.txt ~/.gitmessage
dotfiles_link_module_file git/gitconfig.symlink ~/.gitconfig

