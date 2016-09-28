#!/usr/bin/env bash

[ -r ~/.dotfiles/bin/dotfiles ] && source  ~/.dotfiles/bin/dotfiles || exit 5

dotfiles_link_module_file bash/bash_profile.symlink ~/.bash_profile
dotfiles_link_module_file bash/bashrc.symlink ~/.bashrc

