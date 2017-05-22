#!/usr/bin/env bash

[ -r ~/.dotfiles/bin/dotfiles ] && source  ~/.dotfiles/bin/dotfiles || exit 5

dotfiles_link_module_file tmux/tmux.conf.symlink ~/.tmux.conf

# manage tmux sessions
dotfiles_link_file $(dirname $0)/tmux-session.sh ~/bin/tmux-session
dotfiles_link_module_file tmux/tmux-session.symlink ~/.tmux-session
