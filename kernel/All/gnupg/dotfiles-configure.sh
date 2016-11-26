#!/usr/bin/env bash

[ -r ~/.dotfiles/bin/dotfiles ] && source  ~/.dotfiles/bin/dotfiles || exit 5

dotfiles_link_module_file gnupg/gpg.conf ~/.gnupg/gpg.conf