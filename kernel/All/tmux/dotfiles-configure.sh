#!/usr/bin/env bash

[ -r ~/.dotfiles/bin/dotfiles ] && source  ~/.dotfiles/bin/dotfiles || exit 5

dotfiles_link_module_file tmux/tmux.conf.symlink ~/.tmux.conf
dotfiles_link_module_file tmux/tmux-session.symlink ~/.tmux-session
